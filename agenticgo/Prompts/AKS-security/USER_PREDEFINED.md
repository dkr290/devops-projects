# Predefined User Context

Canned user context injected into every session.

## Environment
- Cluster: an explicitly configured **AKS development** cluster only; `aks-dev`
  is an example name. Never access production. If the target cannot be verified,
  record the scope as unknown and do not inspect an unverified cluster.
- Networking: discover the installed CNI and ingress stack, such as Cilium with
  Hubble or Envoy Gateway. Inspect the available Gateway API objects (Gateway
  listeners, HTTPRoutes, TCPRoutes, TLSRoutes), Ingresses and LoadBalancer
  Services; do not assume that Ingress resources are absent.
- Example Grafana URL: https://grafana.k8s-dev.example.com
- Example Hubble URL: https://hubble.k8s-dev.example.com
- Example Teams notifier endpoint: `POST https://teams-notifier.k8s-dev.example.com/notify`

All `example.com` URLs and Teams team/channel placeholders in this context are
illustrative. Configure the real endpoints and destinations before use; never
send requests or reports to a placeholder. If a required setting is missing,
record it as unavailable rather than inventing a value.

## Audit scope & exclusions
Exclusions are **per check category**, not blanket namespace skips. There are
two separate lists. Configure them for the authorized cluster using approved
exceptions. An unconfigured list is empty; never infer exemptions from a
namespace name.

### List A — exempt from the NetworkPolicy and PSA-label requirements
Namespaces explicitly listed here do not need a NetworkPolicy or Pod Security
Admission labels (`pod-security.kubernetes.io/*`):

- No exemptions configured.

Every namespace **not** in List A must have at least one NetworkPolicy **and**
PSA labels. Missing either is a **Warning**.

### List B — vendor/system namespaces with a relaxed pod-security standard
Explicitly approved vendor/system namespaces may need a relaxed pod-security
standard. Running as root, privileged containers, hostNetwork/hostPath, added
capabilities and missing seccomp are not individual findings in these
namespaces; compare them against their approved baseline instead:

- No exemptions configured.

List B namespaces are reported only as a short informational
**System namespace posture** summary. Escalate only on deviation from their
own baseline: a newly privileged workload, a new hostNetwork/hostPath
workload, an image from an unexpected registry, or suspicious network
behaviour.

A namespace in List B but **not** in List A still needs NetworkPolicies and
PSA labels. Namespaces in neither list get the full standard.

### Applies everywhere
Neither list exempts anything from the exposure, egress-anomaly or
workload-health checks — those apply **cluster-wide, including both lists**.
Review the internet-facing Gateways, routes, Ingresses and LoadBalancer Services
that exist in the target cluster; the controller and namespace may vary.

## Reports
- When a run has something to report (see the Notification contract), write
  the full report to `reports/aks-dev-security-<YYYY-MM-DD-HHMM>.md` in your
  workspace **before** sending the notification. Take the UTC timestamp from
  `exec date -u +%Y-%m-%d-%H%M` — never guess the time. A clean run with no
  changes writes no report. If notification delivery is unavailable or fails,
  keep the report and record the failure.
- When report publishing is configured, build the **Full report** link from its
  actual base URL and the exact file name you wrote. Example only:
  `https://agenticgo.k8s-dev.example.com/reports/aks-security-agent/<file>`.
  If no publication URL is configured, record the link as unavailable; do not
  use the example as a real link.
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
failed/unavailable checks. A clean run with no changes sends nothing. Silence
does not establish health: notification delivery or its configuration may be
unavailable. The card is a short summary that links to the full report, so write
the report first. Send only when the notifier endpoint, team, channel and report
URL are configured. Otherwise, record the notification as unavailable and do
not send it or claim it was sent.

### Payload
- `team`: the configured Teams team; `channel`: the configured channel.
  `<teams-team>` and `<teams-channel>` below are placeholders only.
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
JSON can never be passed inline to curl. Replace the example URL below with
the configured notifier endpoint before running the command:

1. `write_file` the payload to `notifications/teams.json` — valid JSON, with
   line breaks inside `body` written as `\n` escapes.
2. `exec`:
   `curl -sS --fail-with-body -X POST https://teams-notifier.k8s-dev.example.com/notify -H Content-Type:application/json --data-binary @notifications/teams.json`
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
9. `Environment: <configured development cluster>`
10. `[Full report](https://agenticgo.k8s-dev.example.com/reports/aks-security-agent/<file>) · [View Logs](https://grafana.k8s-dev.example.com)`
    — example URLs only; use the configured URLs and omit View Logs if
    unavailable.

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
  "team": "<teams-team>",
  "channel": "<teams-channel>",
  "body": "**1 critical, 4 warnings — 3 new since last run, 1 resolved.**\n\nInspected 30 namespaces and 8 nodes; pod security was sampled, not exhaustive.\n\n**Critical**\n\n- **Public service with live traffic** (NEW) — shop/Service/api-lb: internet-facing LoadBalancer with confirmed external traffic in Prometheus.\n\n**New since last run**\n\n- **Privileged CI builds on shared nodes** (warning) — ci/Pod runner-1, runner-2: Docker-in-Docker runs privileged as UID 0 with cluster tokens mounted.\n- **Broad host access** (warning) — vendor/DaemonSet/node-agent: hostPID and SYS_ADMIN, unconfined seccomp.\n\n**Ongoing**\n\n- No NetworkPolicy — 3 namespaces\n- Running as root — 2 workloads\n\n**Resolved**\n\n- team-d now has a NetworkPolicy.\n\n**Workload health**\n\n- app/worker-7f9c — 42 restarts, last exit Error.\n\n**Not verified:** runner controller (RBAC denied), Azure node-pool settings.\n\nEnvironment: <configured development cluster>\n\n[Full report](https://agenticgo.k8s-dev.example.com/reports/aks-security-agent/aks-dev-security-YYYY-MM-DD-HHMM.md) · [View Logs](https://grafana.k8s-dev.example.com)"
}
```
