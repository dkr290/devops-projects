# Capabilities

What this agent can and cannot do.

## Tools

Verify which integrations are configured for the target environment. URLs under
`example.com` are placeholders, not services to contact.

- **Kubernetes (kubernetes-mcp, 13 tools)** — read-only inspection of
  namespaces, pods, workloads, services, Gateway API objects (Gateways,
  HTTPRoutes, TCPRoutes, TLSRoutes), Ingress resources when supported, network
  policies, and events. Used for the core audit. **Never** create, update,
  patch, or delete cluster resources. Discover the ingress stack rather than
  assuming a particular controller or resource type.
- **Prometheus (prometheus-mcp, 8 tools)** — query metrics to corroborate
  network findings (unexpected traffic, new external destinations, restarts).
- **Loki (loki-mcp, 8 tools)** — query logs to corroborate suspicions (e.g.
  nc/openvpn listeners, unexpected egress, errors from a flagged workload).
- **Grafana (grafana-mcp, 16 tools)** — dashboards, alerting state, datasource
  exploration; source of the "View Logs" target.
- **Hubble (Cilium)** — when available, network flow observability via its UI
  (for example, `https://hubble.k8s-dev.example.com`) and Hubble flow metrics
  in Prometheus (`hubble_flows_processed_total`, `hubble_drop_total`,
  `hubble_dns_queries_total`) for egress anomaly detection. Record a coverage
  limit if the flow data is unavailable.
- **Sentry (sentry-mcp, 4 tools)** — application error context when a finding
  involves a monitored app.
- **Cast AI (castai, 6 tools)** — cluster capacity/cost context; secondary for
  security runs.
- **GitHub (github-mcp, 27 tools)** — read repo/config references when a
  finding needs to be traced to source (e.g. which repo owns a namespace).
- **Filesystem** — read, write, and list files within the workspace (reports,
  baselines). If report publishing is configured, files in `reports/` can be
  published read-only, for example at
  `https://agenticgo.k8s-dev.example.com/reports/aks-security-agent/<file>`;
  only the latest 5 are kept.
- **Exec** — run allow-listed commands within the workspace.
- **Vision** — when the model supports it, reference images can be discovered
  with `list_agent_images` and viewed with `fetch_agent_image`.

Per-server tool signatures live in dedicated skills — load the skill for the
server you need rather than guessing parameters.

## Notifications

- **Teams notifier** — when configured, HTTP POST to the notifier endpoint
  (for example, `https://teams-notifier.k8s-dev.example.com/notify`): write
  the JSON payload with `write_file`, then send it with `exec curl` and
  `--data-binary @notifications/teams.json`. Never send to a placeholder. The
  card is a short summary that links to the published full report (payload,
  sending steps, report link and Teams body format are defined in the Reports
  and Notification contract sections of the Predefined User Context).

## Boundaries

- **Read-only on the cluster.** Inspection only — no remediation, no mutations,
  no exec into pods, no port-forwarding.
- **Development AKS only.** No access to production clusters.
- No cluster credentials are handled directly; all cluster access goes through
  kubernetes-mcp.
