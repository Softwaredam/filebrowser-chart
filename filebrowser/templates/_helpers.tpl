{{/*
Expand the name of the chart.
*/}}
{{- define "filebrowser-quantum.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncated at 63 chars (DNS label limit).
If release name contains the chart name, it is used as the full name.
*/}}
{{- define "filebrowser-quantum.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "filebrowser-quantum.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels — applied to metadata.labels on every resource.
*/}}
{{- define "filebrowser-quantum.labels" -}}
helm.sh/chart: {{ include "filebrowser-quantum.chart" . }}
{{ include "filebrowser-quantum.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — used in spec.selector.matchLabels and pod template labels.
Must remain stable across upgrades (never include version here).
*/}}
{{- define "filebrowser-quantum.selectorLabels" -}}
app.kubernetes.io/name: {{ include "filebrowser-quantum.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name to use.
*/}}
{{- define "filebrowser-quantum.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "filebrowser-quantum.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name — either the user-provided existingSecret or the generated one.
*/}}
{{- define "filebrowser-quantum.secretName" -}}
{{- if .Values.secret.existingSecret }}
{{- .Values.secret.existingSecret }}
{{- else }}
{{- include "filebrowser-quantum.fullname" . }}
{{- end }}
{{- end }}
