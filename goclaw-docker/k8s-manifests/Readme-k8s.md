# GoClaw on Kubernetes

Complete Kubernetes manifests with **1:1 parity** to `docker-compose.yaml`.
Same images, same env var values, same ports, same storage layout.

## What maps to what

| docker-compose service | Kubernetes object | File |
|---|---|---|
| *(implicit project namespace)* | `Namespace/goclaw` | `00-namespace.yaml` |
| `./config.json` bind-mount | `ConfigMap/goclaw-config` | `01-config.yaml` |
| env secrets (postgres/pgadmin/goclaw creds) | `Secret/goclaw-secrets` | `01-config.yaml` |
| `postgres` (`pgvector/pgvector:pg18`) | `Deployment/postgres` + `Service/postgres` + `PVC/postgres-data` | `02-postgres.yaml` |
| `pgadmin` (`dpage/pgadmin4`, uid 5050) | `Deployment/pgadmin` + `Service/pgadmin` + `PVC/pgadmin-data` | `03-pgadmin.yaml` |
| `goclaw-init` (one-shot chown 1000:1000) | **initContainer** `goclaw-init` inside the goclaw Pod | `04-goclaw.yaml` |
| `depends_on: postgres (service_healthy)` | **initContainer** `wait-for-postgres` (pg_isready loop) | `04-goclaw.yaml` |
| `goclaw` (gateway on 18790) | `Deployment/goclaw` + `Service/goclaw` (**ClusterIP**, exposed via HTTPRoute) | `04-goclaw.yaml` |
| *(HTTPS ingress via Envoy Gateway)* | `HTTPRoute/goclaw-http` + `Backend/goclaw-backend` → `https://goclaw.k8s-dev.bankingcircle.net` | `06-httproute.yaml` |
| *(HTTPS ingress via Envoy Gateway)* | `HTTPRoute/pgadmin-http` + `Backend/pgadmin-backend` → `https://pgadmin.k8s-dev.bankingcircle.net` | `07-httproute-pgadmin.yaml` |
| `kubernetes-mcp` (read-only, port 8081) | `Deployment/kubernetes-mcp` + `Service` (kubeconfig mounted from Secret `kubernetes-mcp-kubeconfig`) | `05-kubernetes-mcp.yaml` |
| volume `./postgres_data` | `PVC/postgres-data` (10Gi) | `02-postgres.yaml` |
| volume `./pgadmin_data` | `PVC/pgadmin-data` (2Gi) | `03-pgadmin.yaml` |
| volumes `./data`, `./workspace` | `PVC/goclaw-data`, `PVC/goclaw-workspace` (10Gi each) | `04-goclaw.yaml` |
| network `goclaw-network` | in-cluster DNS (`postgres`, `kubernetes-mcp` resolve inside namespace `goclaw`) | — |

### Identical env var values

Everything in the compose `environment:` blocks is preserved **verbatim**:

- **postgres**: `POSTGRES_USER=goclaw`, `POSTGRES_PASSWORD=goclaw`, `POSTGRES_DB=goclaw`
- **pgadmin**: `PGADMIN_DEFAULT_EMAIL=admin@example.com`, `PGADMIN_DEFAULT_PASSWORD=admin`, `PGADMIN_CONFIG_SERVER_MODE=False`
- **goclaw**: `GOCLAW_POSTGRES_DSN=postgres://goclaw:goclaw@postgres:5432/goclaw?sslmode=disable` (works unchanged — the k8s Service is also named `postgres`), `GOCLAW_GATEWAY_TOKEN=ed21ff...`, `GOCLAW_ENCRYPTION_KEY=b2ce07...`, `GOCLAW_ALLOW_PRIVATE_PROVIDER_URLS=true`, `GOCLAW_MCP_ALLOWED_HOSTS=kubernetes-mcp`, `GOCLAW_DEFAULT_TENANT_ID=0193a5b0-...`, `GOCLAW_CONFIG=/app/config.json`, `GOCLAW_WORKSPACE=/app/workspace`, `GOCLAW_DATA_DIR=/app/data`

Secret values live in `01-config.yaml` as `stringData` (plain text in the file, base64-encoded by Kubernetes on apply). **Do not commit real production credentials — rotate these defaults before exposing the cluster.**

## Prerequisites

- A working cluster (k3d, kind, minikube, or any real cluster) and `kubectl` configured
- A default `StorageClass` that can provision `ReadWriteOnce` PVCs (k3d/minikube ship one by default; on bare clusters install e.g. `local-path-provisioner`)

Check:

```bash
kubectl get nodes
kubectl get sc            # at least one should be marked (default)
```

## Deploy

From the repo root:

```bash
# 1. apply namespace + config + core workloads
kubectl apply -f k8s-manifests/00-namespace.yaml
kubectl apply -f k8s-manifests/01-config.yaml
kubectl apply -f k8s-manifests/02-postgres.yaml
kubectl apply -f k8s-manifests/03-pgadmin.yaml
kubectl apply -f k8s-manifests/04-goclaw.yaml

# 2. create the kubeconfig Secret for kubernetes-mcp (RBAC created separately
#    per ../Readme.md -> ../roles-examples/goclaw-mcp-rbac.yaml, which also
#    produces the ./kubeconfig file)
kubectl -n goclaw create secret generic kubernetes-mcp-kubeconfig \
  --from-file=config=./kubeconfig

# 3. deploy kubernetes-mcp
kubectl apply -f k8s-manifests/05-kubernetes-mcp.yaml

# 4. (optional) expose goclaw and pgadmin via Envoy Gateway HTTPRoutes
kubectl apply -f k8s-manifests/06-httproute.yaml
kubectl apply -f k8s-manifests/07-httproute-pgadmin.yaml
```

Wait for rollout:

```bash
kubectl -n goclaw rollout status deploy/postgres
kubectl -n goclaw rollout status deploy/goclaw
kubectl -n goclaw rollout status deploy/pgadmin
kubectl -n goclaw rollout status deploy/kubernetes-mcp
```

Verify:

```bash
kubectl -n goclaw get pods,svc,pvc
```

Expected: `postgres`, `pgadmin`, `kubernetes-mcp` and `goclaw` all `Running`, all PVCs `Bound`.

## Access the services

### GoClaw gateway (port 18790)

The Service is **ClusterIP** — external access goes through **Envoy Gateway**
(`06-httproute.yaml`) at **`https://goclaw.k8s-dev.bankingcircle.net`**.

For quick local access without the gateway:

```bash
kubectl -n goclaw port-forward svc/goclaw 18790:18790
# open http://localhost:18790
```

Gateway token (same as compose): `ed21ff609cc51f534a69d8c9a92f5c49`

### GoClaw via Envoy Gateway (optional, `06-httproute.yaml`)

If the cluster runs Envoy Gateway (Gateway API), `06-httproute.yaml` exposes
goclaw at **`https://goclaw.k8s-dev.bankingcircle.net`** via the existing
`default-envoy-gw` Gateway in `envoy-gateway-system` — same pattern as the
argocd route (`HTTPRoute → Backend → Service`). Adjust `hostnames` to your
domain before applying. Check status with:

```bash
kubectl -n goclaw get httproute goclaw-http
kubectl -n goclaw describe httproute goclaw-http   # Accepted/ResolvedRefs conditions
```

### pgAdmin (port 5050 in compose → port-forward in k8s)

```bash
kubectl -n goclaw port-forward svc/pgadmin 5050:80
# open http://localhost:5050  (admin@example.com / admin)
```

Or via Envoy Gateway (optional, `07-httproute-pgadmin.yaml`):
**`https://pgadmin.k8s-dev.bankingcircle.net`** — same pattern as the goclaw
route above (`HTTPRoute → Backend → pgadmin Service:80`). Adjust
`hostnames` to your domain before applying.

### PostgreSQL (port 5432 in compose → port-forward in k8s)

```bash
kubectl -n goclaw port-forward svc/postgres 5432:5432
psql "postgres://goclaw:goclaw@localhost:5432/goclaw?sslmode=disable"
```

## kubernetes-mcp: kubeconfig Secret (exact compose parity)

The MCP server runs **exactly like docker-compose**: same flags
(`--port=8081 --read-only --toolsets=core --kubeconfig=/home/nonroot/.kube/config`),
same `KUBECONFIG` env var, and the kubeconfig file mounted into the pod.

**RBAC is created separately** (not part of these manifests) — follow
[`../Readme.md`](../Readme.md), which applies
[`../roles-examples/goclaw-mcp-rbac.yaml`](../roles-examples/goclaw-mcp-rbac.yaml)
(ServiceAccount `goclaw-k8s-viewer` + extended read-only ClusterRole
`goclaw-k8s-observer` + ClusterRoleBinding + long-lived token Secret),
then builds `./kubeconfig` from those credentials.

Once you have `./kubeconfig`, **point its server URL at the in-cluster API
endpoint** (only needed when the MCP server targets the same cluster it runs
in — the `0.0.0.0:<port>` / k3d-serverlb / `host.docker.internal` addresses
from the compose setup do NOT resolve from inside pods):

```bash
kubectl config set-cluster goclaw-cluster \
  --server=https://kubernetes.default.svc:443 \
  --kubeconfig=./kubeconfig
```

Then create the Secret that `05-kubernetes-mcp.yaml` mounts:

```bash
kubectl -n goclaw create secret generic kubernetes-mcp-kubeconfig \
  --from-file=config=./kubeconfig
```

Then apply `05-kubernetes-mcp.yaml`. The pod mounts it at
`/home/nonroot/.kube/config` — the same path as in docker-compose.

> **Verified end-to-end** (2026-08-20): with the RBAC from
> `../roles-examples/goclaw-mcp-rbac.yaml` applied and the server URL set as
> above, a pod mounting this Secret via the exact volume spec in
> `05-kubernetes-mcp.yaml` successfully ran `kubectl get nodes` and passed
> `auth can-i get nodes/proxy = yes` from inside the cluster.

## What the ConfigMap contains (and why)

The `goclaw-config` ConfigMap in `01-config.yaml` is a **minimal bootstrap config** — not the full `config.json` from the Docker setup. In PostgreSQL mode the GUI is the source of truth for:

- **Providers** (including `localai` at `http://192.168.1.101:8080`) — add via **Providers** page
- **Agents** (provider/model overrides, skills, workspace) — managed per-agent in **Agents**
- **MCP servers** (the `kubernetes-mcp` at `http://kubernetes-mcp:8081/mcp`) — add via **MCP Integration** settings
- **Channels, sessions, memory, bindings**

The ConfigMap only keeps what has **no GUI equivalent** or is needed **before first login**:

| Section | Why it stays |
|---|---|
| `gateway.mcp_allowed_hosts` | SSRF exemption for `kubernetes-mcp` — also backed by env var `GOCLAW_MCP_ALLOWED_HOSTS` (belt & braces) |
| `gateway.host/port/rate_limit/max_message_chars/allowed_origins` | File-only; require restart; no GUI editor |
| `agents.defaults` | Fallback workspace, token limits, `restrict_to_workspace`, subagent concurrency — used until per-agent GUI overrides exist |

Everything else (`providers.*`, `tools.mcp_servers`, empty `{}` placeholders) was removed because the GUI writes them to PostgreSQL.

### Updating the minimal config

```bash
kubectl apply -f k8s-manifests/01-config.yaml
kubectl -n goclaw rollout restart deploy/goclaw
```

## Data & persistence

All state lives in four PVCs — deleting Deployments/Services does **not** delete data.
Full teardown **including data**:

```bash
kubectl delete namespace goclaw     # removes everything, including PVCs
```

Teardown **keeping data**:

```bash
kubectl -n goclaw delete deploy,svc --all
kubectl -n goclaw delete secret kubernetes-mcp-kubeconfig
# PVCs remain; re-deploy with kubectl apply -f k8s-manifests/
```

(RBAC objects `goclaw-k8s-observer` / `goclaw-k8s-viewer-binding` live
outside this namespace setup — delete them separately if desired:
`kubectl delete -f ../roles-examples/goclaw-mcp-rbac.yaml`.)

## Migration from the Docker volumes (optional)

To carry over `data/` and `workspace/` content from the compose setup:

```bash
kubectl -n goclaw run data-copy --rm -i --image=alpine --restart=Never \
  --overrides='{"spec":{"containers":[{"name":"data-copy","image":"alpine","stdin":true,"tty":true,
  "volumeMounts":[{"name":"d","mountPath":"/data"},{"name":"w","mountPath":"/workspace"}]}],
  "volumes":[{"name":"d","persistentVolumeClaim":{"claimName":"goclaw-data"}},
             {"name":"w","persistentVolumeClaim":{"claimName":"goclaw-workspace"}}]}}'
# then kubectl cp your local ./data and ./workspace into /data and /workspace
```

(Or simply start fresh — the seeder recreates skills on first boot.)

## Troubleshooting

| Symptom | Check |
|---|---|
| PVC stuck `Pending` | `kubectl get sc` — no default StorageClass; install one or set `storageClassName` in the PVCs |
| `goclaw-init` initContainer fails | `kubectl -n goclaw logs deploy/goclaw -c goclaw-init` — needs runAsUser 0 (already set) |
| goclaw CrashLoop: postgres unreachable | `kubectl -n goclaw logs deploy/goclaw -c wait-for-postgres`; check `svc/postgres` exists |
| kubernetes-mcp pod stuck `CreateContainerConfigError` | Secret `kubernetes-mcp-kubeconfig` missing — create it from `./kubeconfig` (see deploy step 2) |
| MCP tools fail with RBAC errors | the kubeconfig's ServiceAccount lacks the permission — verify with `kubectl --kubeconfig=./kubeconfig auth can-i get nodes` etc.; the extended role is in `../roles-examples/goclaw-mcp-rbac.yaml` |
| MCP server can't reach API | the `server:` URL in kubeconfig must be reachable **from inside the cluster** — `host.docker.internal` / k3d-serverlb names from compose usually aren't |
| port 18790 unreachable | use the HTTPRoute (`06-httproute.yaml`) or `kubectl -n goclaw port-forward svc/goclaw 18790:18790` |
