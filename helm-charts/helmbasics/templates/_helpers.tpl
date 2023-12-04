{{/* Common Labels */}}

{{- define "helmbasics.labels"}}
    app: nginx2
    chartname: {{ .Chart.Name }}
    template-inanother: {{ include "helmbasics.resourceName" . }}

{{- end }}

{{/* k8s resource name string concatenation with print demo */}}
{{- define "helmbasics.resourceName" }}

{{- printf "%s-%s" .Release.Name .Chart.Name }}

{{- end }}
