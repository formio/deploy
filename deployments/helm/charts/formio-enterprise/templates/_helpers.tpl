{{/*
Expand the name of the chart.
*/}}
{{- define "formio-enterprise-name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "formio-enterprise-fullname" -}}
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
{{- define "formio-enterprise-chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "formio-enterprise-labels" -}}
helm.sh/chart: {{ include "formio-enterprise-chart" . }}
{{ include "formio-enterprise-selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "formio-enterprise-selectorLabels" -}}
app.kubernetes.io/name: {{ include "formio-enterprise-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "formio-enterprise-serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "formio-enterprise-fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "formio-enterprise.envVarName" -}}
{{ . | snakecase | upper }}
{{- end }}

{{/*
Generate file storage provider environment variables using the same structure as envVars helper
*/}}
{{- define "formio-enterprise-fileStorageProviderEnv" -}}
{{- $fileStorageProvider := .Values.pdf.fileStorageProvider -}}
{{- if not $fileStorageProvider }}
  {{- fail "A file storage provider (pdf.fileStorageProvider) must be configured for PDF functionality" }}
{{- end }}
{{- $allowedProviders := list "aws" "azure" "gcp" "minio" -}}
{{- if not (has $fileStorageProvider $allowedProviders) }}
  {{- fail (printf "Invalid file storage provider: %s. Allowed values are: aws, azure, gcp, minio" $fileStorageProvider) }}
{{- end }}

{{- /* Get pdf environment variables */ -}}
{{- $providerSecrets := .Values.secret.pdf | default dict }}
{{- $providerPublic := .Values.pdf.env | default dict }}

{{- if ne $fileStorageProvider "azure" }}
  {{- /* S3-compatible storage (AWS, GCP, Minio) */ -}}
  {{- if not $providerPublic.formioS3Bucket }}
    {{- fail "Environment variable formioS3Bucket is required for aws, gcp and minio storage" }}
  {{- end }}

  {{- if not $providerSecrets.formioS3Key }}
    {{- fail "Environment variable formioS3Key is required when using aws, gcp or minio storage" }}
  {{- end }}

  {{- if not $providerSecrets.formioS3Secret }}
    {{- fail "Environment variable formioS3Secret is required when using aws, gcp or minio storage" }}
  {{- end }}

  {{- if eq $fileStorageProvider "aws" }}
    {{- if not $providerPublic.formioS3Region }}
      {{- fail "Environment variable formioS3Region is required when using aws storage" }}
    {{- end }}
  {{- else }}
    {{- if not $providerPublic.formioS3Server }}
      {{- fail "Environment variable formioS3Server is required when using gcp or minio storage" }}
    {{- end }}
  {{- end }}
{{- else }}
  {{- /* Azure Blob Storage */ -}}
  {{- if not $providerPublic.formioAzureContainer }}
    {{- fail "Environment variable formioAzureContainer is required for azure storage" }}
  {{- end }}

  {{- if not $providerSecrets.formioAzureConnectionString }}
    {{- fail "Environment variable formioAzureConnectionString is required for azure storage" }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Merge default port into probe configuration
*/}}
{{- define "formio-enterprise.probe" -}}
{{- $probe := .probe -}}
{{- $defaultPort := .defaultPort -}}
{{- /* Remove the enabled field if it exists */ -}}
{{- $cleanProbe := omit $probe "enabled" -}}
{{- /* Set default port if not specified */ -}}
{{- if and $cleanProbe.httpGet (not $cleanProbe.httpGet.port) -}}
{{- $_ := set $cleanProbe.httpGet "port" $defaultPort -}}
{{- end -}}
{{- toYaml $cleanProbe -}}
{{- end -}}

{{/*
Generate environment variables with secret support and validation
*/}}
{{- define "formio-enterprise.envVars" -}}
{{- $component := .component -}}
{{- /* newSecretValues refers to secrets created by this chart as opposed to values from an existing secret  */ -}}
{{- $newSecretValues := dict }}
{{- $publicValues := dict }}
{{- $requiredSecrets := list "mongo" "licenseKey" "dbSecret" "adminPass" "portalSecret" "jwtSecret" }}

{{- if eq $component "api" }}
  {{- $newSecretValues = .Values.secret.api }}
  {{- $publicValues = .Values.api.env }}
  {{- if hasKey .Values.secret.api "extraVars" }}
    {{- range $item := .Values.secret.api.extraVars }}
      {{- $newSecretValues = set $newSecretValues $item.name $item.value }}
    {{- end }}
  {{- end }}
{{- else if eq $component "pdf" }}
  {{- $newSecretValues = .Values.secret.pdf }}
  {{- $publicValues = .Values.pdf.env }}
  {{- if hasKey .Values.secret.pdf "extraVars" }}
    {{- range $item := .Values.secret.pdf.extraVars }}
      {{- $newSecretValues = set $newSecretValues $item.name $item.value }}
    {{- end }}
  {{- end }}
{{- else }}
  {{- fail (printf "Invalid component parameter: %s. Must be 'api' or 'pdf'" $component) }}
{{- end }}

{{- /* Merge common environment variables */ -}}
{{- if .Values.secret.common }}
  {{- $newSecretValues = merge $newSecretValues .Values.secret.common }}
  {{- if hasKey .Values.secret.common "extraVars" }}
    {{- range $item := .Values.secret.common.extraVars }}
      {{- $newSecretValues = set $newSecretValues $item.name $item.value }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if .Values.common.env }}
  {{- $publicValues = merge $publicValues .Values.common.env }}
{{- end }}

{{- /* Explicitly check for required public vars */ -}}
{{- if eq $component "api" }}
{{- $requiredPublic := list "adminEmail" "portalEnabled" }}
{{- range $req := $requiredPublic }}
  {{- if not (hasKey $publicValues $req) }}
    {{- fail (printf "Required public environment variable %s is missing from configuration" $req) }}
  {{- end }}
  {{- if not (get $publicValues $req) }}
    {{- fail (printf "Required public environment variable %s is not defined" $req) }}
  {{- end }}
{{- end }}
{{- end }}

{{- /* Get all secret environment variable keys, whether from existing secret or chart-managed secret */ -}}
{{- $existingSecretManifest := lookup "v1" "Secret" .Release.Namespace .Values.secret.name }}
{{- $availableSecretKeys := list }}
{{- if .Values.secret.existingSecret }}
{{- if $existingSecretManifest }}
{{- /* If we have an existing secret, use its keys */ -}}
{{- $availableSecretKeys = keys $existingSecretManifest.data }}
{{- else }}
{{- /* In case of a client-side dry run where the cluster isn't accessed */ -}}
{{- $availableSecretKeys = $requiredSecrets }}
{{- end }}
{{- else }}
{{- /* If we have a secret created by this chart, use its keys */ -}}
{{- range $key, $value := $newSecretValues }}
{{- if $value }}
{{- $availableSecretKeys = append $availableSecretKeys $key }}
{{- end }}
{{- end }}
{{- end }}

{{- /* Validate that required secret keys and values exist */ -}}
{{- if eq $component "api" }}
{{- /* Some of these are required for both PDF and API servers, but as of now, PDF has no required vars that aren't shared with API */ -}}
{{- /* If down the road we require validating distinct required PDF vars, we'll need to separate the lists of vars between this and a new helper for the PDF vars */ -}}
{{- range $req := $requiredSecrets }}
{{- if not (has $req $availableSecretKeys) }}
{{- if $.Values.secret.existingSecret }}
{{- fail (printf "Required secret key '%s' not found in existing secret '%s'. Existing secret keys: %s" $req $.Values.secret.name ($availableSecretKeys | join ", ")) }}
{{- else }}
{{- fail (printf "Required secret key '%s' not found in chart-managed secret" $req) }}
{{- end }}
{{- else if $.Values.secret.existingSecret }}
{{- /* For existing secrets, also validate that values are not empty */ -}}
{{- if $existingSecretManifest }}
{{- $secretValue := index $existingSecretManifest.data $req | b64dec }}
{{- if not $secretValue }}
{{- fail (printf "Required secret key '%s' exists but has empty value in existing secret '%s'" $req $.Values.secret.name) }}
{{- end }}
{{- end }}
{{- else }}
{{- /* For newly created secrets, validate that values are not empty */ -}}
{{- $newSecretValue := get $newSecretValues $req }}
{{- if not $newSecretValue }}
{{- fail (printf "Required secret key '%s' was found in chart-managed secret, but has an empty value" $req) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- /* Render secret environment variables */ -}}
{{- if .Values.secret.existingSecret }}
{{- /* For existing secrets, filter keys by component based on values.secret configuration */ -}}
{{- $componentSecretKeys := list }}
{{- /* Add common keys */ -}}
{{- if .Values.secret.common }}
{{- $componentSecretKeys = concat $componentSecretKeys (keys .Values.secret.common) (.Values.secret.common.extraExistingKeys | default list) }}
{{- end }}
{{- /* Add component-specific keys */ -}}
{{- if eq $component "api" }}
{{- if .Values.secret.api }}
{{- $componentSecretKeys = concat $componentSecretKeys (keys .Values.secret.api) (.Values.secret.api.extraExistingKeys | default list) }}
{{- end }}
{{- else if eq $component "pdf" }}
{{- if .Values.secret.pdf }}
{{- $componentSecretKeys = concat $componentSecretKeys (keys .Values.secret.pdf) (.Values.secret.pdf.extraExistingKeys | default list) }}
{{- end }}
{{- end }}
{{- /* Only render env vars for keys that exist in both the secret and the component configuration */ -}}
{{- range $key := $availableSecretKeys }}
{{- if has $key $componentSecretKeys }}
- name: {{ include "formio-enterprise.envVarName" $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.secret.name }}
      key: {{ $key }}
{{- end }}
{{- end }}
{{- else }}
{{- /* For chart-managed secrets, only include keys that have values */ -}}
{{- range $key, $value := $newSecretValues }}
{{- if and (has $key $availableSecretKeys) (ne $key "extraExistingKeys") (ne $key "extraVars") }}
- name: {{ include "formio-enterprise.envVarName" $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.secret.name }}
      key: {{ $key }}
{{- end }}
{{- end }}
{{- end }}

{{- /* Handle injecting public environment variables */ -}}
{{- range $key, $value := $publicValues }}
{{- if $value }}
- name: {{ include "formio-enterprise.envVarName" $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}
