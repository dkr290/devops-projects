# Predefined User Context

Canned user context injected into every session.

## Environment
- Cluster: **aks dev or neu-daai-aks-dev** (AKS, development). This is the only cluster in scope.
- Networking: **Cilium CNI** (Hubble for flow visibility) and **Envoy Gateway
  (Gateway API)** for north-south exposure. This cluster has **no Ingress
  resources** — "no Ingress objects found" is expected, never a finding.
  Exposure checks target Gateway API objects (Gateway listeners, HTTPRoutes,
  TCPRoutes, TLSRoutes) and LoadBalancer Services.
- Grafana: https://grafana.k8s-dev.bankingcircle.net
- Hubble (Cilium network observability): https://hubble.k8s-dev.bankingcircle.net
- Teams notifier endpoint: `POST https://teams-notifier.k8s-dev.bankingcircle.net/notify`

## Audit scope & exclusions
Exclusions are **per check category**, not blanket namespace skips. There are
two separate lists.

### List A — exempt from the NetworkPolicy and PSA-label requirements
These namespaces do not need a NetworkPolicy or Pod Security Admission labels
(`pod-security.kubernetes.io/*`):

- `kube-system`
- `envoy-gateway-system`
- `monitoring`
- `castai-agent`
- `default`
- `kube-node-lease`
- `kube-public`
- `kyverno`
- `github-runner`

Every namespace **not** in List A must have at least one NetworkPolicy **and**
PSA labels. Missing either is a **Warning**.

### List B — vendor/system namespaces with a relaxed pod-security standard
These run vendor Helm charts and cannot meet the normal pod-security standard.
Running as root, privileged containers, hostNetwork/hostPath, added
capabilities and missing seccomp are **expected** here and are not findings:

- `kube-system`
- `envoy-gateway-system`
- `monitoring`
- `castai-agent`
- `kyverno`
- `github-runner`
- `argocd`
- `argo`
- `argo-events`
- `mlflow`

List B namespaces are reported only as a short informational
**System namespace posture** summary. Escalate only on deviation from their
own baseline: a newly privileged workload, a new hostNetwork/hostPath
workload, an image from an unexpected registry, or suspicious network
behaviour.

Note that `argocd`, `argo`, `argo-events` and `mlflow` are in List B but
**not** in List A, so they still must have NetworkPolicies and PSA labels.
`spmonitor`, `scam`, `agenticgo` and every other namespace are in neither
list and get the full standard.

### Applies everywhere
Neither list exempts anything from the exposure, egress-anomaly or
workload-health checks — those apply **cluster-wide, including both lists**.
The Envoy Gateway data plane in `envoy-gateway-system` is the primary
internet-facing surface — always review its Gateways, routes and
LoadBalancer Service.

## Reports
- When a run has something to report (see the Notification contract), write
  the full report to `reports/aks-dev-security-<YYYY-MM-DD-HHMM>.md` in your
  workspace **before** sending the notification. Take the UTC timestamp from
  `exec date -u +%Y-%m-%d-%H%M` — never guess the time. A clean run with no
  changes writes no report, so the kept reports match the latest notifications.
- Each report is published read-only at
  `https://agenticgo.k8s-dev.bankingcircle.net/reports/aks-security-agent/<file>`.
  That is the **Full report** link in Teams — use the exact file name you wrote.
- The report is the complete record: every finding with evidence, NEW vs
  ongoing, resolved findings, coverage limits and failed checks. Normal
  Markdown (headings, tables, lists) is fine here.
- Only the latest 5 reports are kept; older ones are deleted automatically.
  Compare runs using observations, not old report files.
- Anyone with access to agenticgo can open a report: never include secrets,
  tokens or credential values — name the object and field instead.

## Notification contract
Send a Teams notification via the notifier **only when there is something to
report** — new findings, changed or escalated findings, resolved findings, or
failed/unavailable checks. A clean run with no changes sends nothing; silence
means healthy. The card is a short summary that links to the full report, so
write the report first.

### Payload
- `team`: `Advanced Analytics`, `channel`: `agent-dev`
- `title`: `Agent checks completed`
- `status` — the notifier accepts only `info`, `success`, `warning`, `error`
  and prefixes the title with `[WARNING]` / `[ERROR]`. **Never send
  `critical`** — it is not a notifier status and silently drops the prefix.
  - any Critical finding → `error`
  - Warning findings, or failed/unavailable checks → `warning`
  - only resolved findings or no-impact changes → `info`
- `body` — the summary described below.
- Do **not** send `facts` or `action`: the notifier would append them as one
  unformatted line. The body ends with the environment and the links instead.

### How to send
`exec` splits the command on whitespace and does not understand quotes, so
JSON can never be passed inline to curl:

1. `write_file` the payload to `notifications/teams.json` — valid JSON, with
   line breaks inside `body` written as `\n` escapes.
2. `exec`:
   `curl -sS --fail-with-body -X POST https://teams-notifier.k8s-dev.bankingcircle.net/notify -H Content-Type:application/json --data-binary @notifications/teams.json`
3. The notification counts as sent only if the response contains
   `"status":"ok"`. On an error, fix the payload and retry once; if it still
   fails, report the failure.

### Body format
These rules apply to the Teams body only — your chat reply and the report
file keep normal Markdown. Teams shows the body as a card that renders only a
small Markdown subset:

- Renders: `**bold**`, `_italic_`, `- ` bullet lists, `[text](url)` links.
- Shows up as raw characters, so never use: `#` headings, tables, backticks,
  `>` quotes. Use a bold line instead of a heading; turn table rows into
  bullets.
- A single line break is swallowed. Put an empty line (`\n\n`) between every
  paragraph, section label and list. Inside a list, one bullet per line
  (single `\n`).
- Write plain, readable sentences: spaces after commas, no
  `key=value;key=value` chains, no `|` separators, no ALL-CAPS labels, no
  abbreviations to save space.

Layout — a summary of the whole run, in this order (omit empty sections):

1. Bold verdict with counts, e.g.
   `**1 critical, 4 warnings — 3 new since last run, 1 resolved.**`
2. One sentence of scope: what was inspected; say so if pod security was
   sampled rather than exhaustive.
3. `**Critical**` — every critical finding, one bullet each, marked `(NEW)`
   when new:
   `- **Plain-language headline** (NEW) — namespace/Kind/name: key evidence in one sentence.`
4. `**New since last run**` — every new non-critical finding, one bullet each,
   with its severity:
   `- **Plain-language headline** (warning) — namespace/Kind/name: key evidence in one sentence.`
   The same issue on several objects is ONE bullet.
5. `**Ongoing**` — one short bullet per category with a count, e.g.
   `- No NetworkPolicy — 15 namespaces`.
6. `**Resolved**` — one short bullet per resolved finding.
7. `**Workload health**` — at most the top 3:
   `- namespace/pod — N restarts, last exit reason.`
8. `**Not verified:**` followed by the failed or unavailable checks on one line.
9. `Environment: aks dev cluster`
10. `[Full report](https://agenticgo.k8s-dev.bankingcircle.net/reports/aks-security-agent/<file>) · [View Logs](https://grafana.k8s-dev.bankingcircle.net)`

Keep the body under about 3,500 characters. Critical findings are never
reduced to a count; everything else in detail belongs in the report. The card
and the report must agree — same verdict, same counts. No meta-commentary
about the message itself.

Example payload — format only; the names, numbers and file name are
placeholders, never copy them into a real notification:

```json
{
  "title": "Agent checks completed",
  "status": "error",
  "team": "Advanced Analytics",
  "channel": "agent-dev",
  "body": "**1 critical, 4 warnings — 3 new since last run, 1 resolved.**\n\nInspected 30 namespaces and 8 nodes; pod security was sampled, not exhaustive.\n\n**Critical**\n\n- **Public service with live traffic** (NEW) — shop/Service/api-lb: internet-facing LoadBalancer with confirmed external traffic in Prometheus.\n\n**New since last run**\n\n- **Privileged CI builds on shared nodes** (warning) — ci/Pod runner-1, runner-2: Docker-in-Docker runs privileged as UID 0 with cluster tokens mounted.\n- **Broad host access** (warning) — vendor/DaemonSet/node-agent: hostPID and SYS_ADMIN, unconfined seccomp.\n\n**Ongoing**\n\n- No NetworkPolicy — 3 namespaces\n- Running as root — 2 workloads\n\n**Resolved**\n\n- team-d now has a NetworkPolicy.\n\n**Workload health**\n\n- app/worker-7f9c — 42 restarts, last exit Error.\n\n**Not verified:** runner controller (RBAC denied), Azure node-pool settings.\n\nEnvironment: aks dev cluster\n\n[Full report](https://agenticgo.k8s-dev.bankingcircle.net/reports/aks-security-agent/aks-dev-security-YYYY-MM-DD-HHMM.md) · [View Logs](https://grafana.k8s-dev.bankingcircle.net)"
}
```
