{{- define "redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "redis.serviceName" -}}
{{ include "redis.fullname" . }}-{{ .Values.redisscaled.nameOverride }}
{{- end -}}



