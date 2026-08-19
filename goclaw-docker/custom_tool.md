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
