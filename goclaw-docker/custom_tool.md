> ⚠️ **Deprecated.** Current GoClaw builds removed the `POST /v1/tools/custom`
> API (it returns `404 API route not found`). To add custom capabilities now,
> use an **MCP server** instead. For the Teams Notifier, see
> `k8s-manifests/05b-teams-notifier-mcp.yaml` and
> `k8s-manifests/Readme-k8s.md` → "Teams notifications", which run a small
> Python (FastMCP) MCP server that POSTs to the notifier. The example below is
> kept for reference only and will not work on current GoClaw.

curl -X POST http://localhost:8080/v1/tools/custom \
  -H "Authorization: Bearer YOUR_MASTER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "k8s_cluster_inspector",
    "description": "Inspects Kubernetes resources. Allowed actions: get, list, watch, describe across namespaces.",
    "command_template": "kubectl {{.action}} {{.resource}} {{if .name}}{{.name}}{{end}} {{if .namespace}}-n {{.namespace}}{{end}} --ignore-not-found",
    "env": {
      "KUBECONFIG": "/etc/goclaw/kubeconfig.yaml"
    },
    "deny_patterns": [
      "delete",
      "apply",
      "create",
      "patch",
      "replace",
      "edit",
      "exec",
      "scale",
      "drain",
      "cordon",
      ";",
      "&&",
      "|"
    ]
  }'
