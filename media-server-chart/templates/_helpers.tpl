{{- define "gluetunPorts" -}}
{{- if .Values.containerPorts }}
{{- range .Values.containerPorts }}{{(print .port )}},{{- end }}
{{- end }}
{{- end }}