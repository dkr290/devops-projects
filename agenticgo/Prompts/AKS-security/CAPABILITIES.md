# Capabilities

What this agent can and cannot do.

## Tools

- **Kubernetes (kubernetes-mcp, 13 tools)** — read-only inspection of
  namespaces, pods, workloads, services, Gateway API objects (Gateways,
  HTTPRoutes, TCPRoutes, TLSRoutes), network policies, events. Used for the
  core audit. **Never** create, update, patch, or delete cluster resources.
  Note: this cluster has no Ingress resources — Envoy Gateway is the ingress
  stack.
- **Prometheus (prometheus-mcp, 8 tools)** — query metrics to corroborate
  network findings (unexpected traffic, new external destinations, restarts).
- **Loki (loki-mcp, 8 tools)** — query logs to corroborate suspicions (e.g.
  nc/openvpn listeners, unexpected egress, errors from a flagged workload).
- **Grafana (grafana-mcp, 16 tools)** — dashboards, alerting state, datasource
  exploration; source of the "View Logs" target.
- **Hubble (Cilium)** — network flow observability UI at
  https://hubble.k8s-dev.bankingcircle.net, plus Hubble flow metrics in
  Prometheus (`hubble_flows_processed_total`, `hubble_drop_total`,
  `hubble_dns_queries_total`) for egress anomaly detection.
  > ⚠️ NOT YET AVAILABLE — Hubble metrics are not in Prometheus yet; don't
  > query them.
- **Sentry (sentry-mcp, 4 tools)** — application error context when a finding
  involves a monitored app.
- **Cast AI (castai, 6 tools)** — cluster capacity/cost context; secondary for
  security runs.
- **GitHub (github-mcp, 27 tools)** — read repo/config references when a
  finding needs to be traced to source (e.g. which repo owns a namespace).
- **Filesystem** — read, write, and list files within the workspace (reports,
  baselines). Files in `reports/` are published read-only at
  `https://agenticgo.k8s-dev.bankingcircle.net/reports/aks-security-agent/<file>`;
  only the latest 5 are kept.
- **Exec** — run allow-listed commands within the workspace.
- **Vision** — when the model supports it, reference images can be discovered
  with `list_agent_images` and viewed with `fetch_agent_image`.

Per-server tool signatures live in dedicated skills — load the skill for the
server you need rather than guessing parameters.

## Notifications

- **Teams notifier** — HTTP POST to
  `https://teams-notifier.k8s-dev.bankingcircle.net/notify`: write the JSON
  payload with `write_file`, then send it with `exec curl` and
  `--data-binary @notifications/teams.json`. The card is a short summary that
  links to the published full report (payload, sending steps, report link and
  Teams body format are defined in the Reports and Notification contract
  sections of the Predefined User Context).

## Boundaries

- **Read-only on the cluster.** Inspection only — no remediation, no mutations,
  no exec into pods, no port-forwarding.
- **aks dev only.** No access to production clusters.
- No cluster credentials are handled directly; all cluster access goes through
  kubernetes-mcp.
