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
| `goclaw` (gateway on 18790) | `Deployment/goclaw` + `Service/goclaw` (**NodePort 18790**) | `04-goclaw.yaml` |
| `kubernetes-mcp` (read-only, port 8081) | `Deployment/kubernetes-mcp` + `Service` + `ServiceAccount` + `ClusterRoleBinding(view)` | `05-kubernetes-mcp.yaml` |
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
# apply everything in order (namespace first, config before workloads)
kubectl apply -f k8s-manifests/

# or one file at a time if you prefer:
kubectl apply -f k8s-manifests/00-namespace.yaml
kubectl apply -f k8s-manifests/01-config.yaml
kubectl apply -f k8s-manifests/02-postgres.yaml
kubectl apply -f k8s-manifests/03-pgadmin.yaml
kubectl apply -f k8s-manifests/04-goclaw.yaml
kubectl apply -f k8s-manifests/05-kubernetes-mcp.yaml
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

Same as compose, exposed as **NodePort 18790**:

- k3d: `http://localhost:18790` (k3d maps node ports by default; if not, recreate cluster with `-p "18790:18790@server:0"`)
- minikube: `minikube service goclaw -n goclaw` or `http://$(minikube ip):18790`
- kind: node ports need extraPortMappings at cluster creation, otherwise use port-forward below

Universal fallback:

```bash
kubectl -n goclaw port-forward svc/goclaw 18790:18790
# open http://localhost:18790
```

Gateway token (same as compose): `ed21ff609cc51f534a69d8c9a92f5c49`

### pgAdmin (port 5050 in compose → port-forward in k8s)

```bash
kubectl -n goclaw port-forward svc/pgadmin 5050:80
# open http://localhost:5050  (admin@example.com / admin)
```

### PostgreSQL (port 5432 in compose → port-forward in k8s)

```bash
kubectl -n goclaw port-forward svc/postgres 5432:5432
psql "postgres://goclaw:goclaw@localhost:5432/goclaw?sslmode=disable"
```

## kubernetes-mcp: how it differs from compose (and why)

Compose mounts an **exported kubeconfig file** (`./kubeconfig`, built per `Readme.md`) so the
MCP server can reach the cluster API from a container.

On Kubernetes the idiomatic equivalent is a **ServiceAccount + in-cluster config**:

- `ServiceAccount/kubernetes-mcp` — identity of the pod
- `ClusterRoleBinding/kubernetes-mcp-view` → built-in `view` ClusterRole = **read-only cluster-wide**, exactly matching the compose intent (`--read-only --toolsets=core` plus a viewer-scoped kubeconfig)
- No token files, no `kubectl config` bootstrap, no secrets to rotate

The server flags are unchanged (`--port=8081 --read-only --toolsets=core`) with
`--cluster-provider=in-cluster` replacing `--kubeconfig=...`.

### Alternative: kubeconfig Secret (exact compose parity)

If you must point the MCP server at a **different** cluster (as the compose setup does with
`k3d-cluster-net`), reuse the kubeconfig from `Readme.md` and mount it:

```bash
kubectl -n goclaw create secret generic kubernetes-mcp-kubeconfig \
  --from-file=config=./kubeconfig
```

Then patch `05-kubernetes-mcp.yaml`: drop `--cluster-provider=in-cluster`, restore
`--kubeconfig=/home/nonroot/.kube/config` and the `KUBECONFIG` env var, and add:

```yaml
          volumeMounts:
            - name: kubeconfig
              mountPath: /home/nonroot/.kube/config
              subPath: config
              readOnly: true
      volumes:
        - name: kubeconfig
          secret:
            secretName: kubernetes-mcp-kubeconfig
```

(Remove `serviceAccountName` + the RBAC objects in that case.)

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
kubectl -n goclaw delete deploy,svc,sa --all
kubectl delete clusterrolebinding kubernetes-mcp-view
# PVCs remain; re-deploy with kubectl apply -f k8s-manifests/
```

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
| MCP tools fail with RBAC errors | `kubectl auth can-i get pods --as=system:serviceaccount:goclaw:kubernetes-mcp -A` should be `yes` |
| port 18790 unreachable | cluster-specific NodePort caveats — use `kubectl -n goclaw port-forward svc/goclaw 18790:18790` |
