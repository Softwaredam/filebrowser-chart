# Changes in v2.0.0 — Helm Chart Rewrite

This is a breaking release that rewrites the chart to follow Helm community best practices.
Patterns follow Grafana, Prometheus kube-state-metrics, and Elastic Kibana charts.

## Breaking Changes

These require updating your custom `values.yaml` when upgrading from v0.1:

| Old Value | New Value | Notes |
|---|---|---|
| `ingress.class` | `ingress.className` | Matches Kubernetes `spec.ingressClassName` |
| `ingress.host` | `ingress.hosts[].host` | Now an array — supports multiple hosts |
| `ingress.certSecret` | `ingress.tls[].secretName` | Standard K8s TLS format; TLS is now optional |
| `persistence.enabled` | `persistence.config.enabled` / `persistence.data.enabled` | Config and data PVCs are now independent |
| `persistence.storageClass` | `persistence.config.storageClass` / `persistence.data.storageClass` | Each PVC has its own storage class |
| `persistence.configSize` | `persistence.config.size` | |
| `persistence.dataSize` | `persistence.data.size` | Default changed from `1Gi` to `10Gi` |
| `persistence.keep` | `persistence.config.retain` / `persistence.data.retain` | Per-PVC control |
| `persistence.accessMode` | `persistence.config.accessMode` / `persistence.data.accessMode` | Per-PVC control |
| `adminPassword.passwordLength` | `secret.adminPasswordLength` | Moved under `secret` block |
| `adminPassword.passwordOverride` | `secret.adminPassword` | Simpler name |
| `securityContext.runAsUser` | `podSecurityContext.runAsUser` | Full pod security context object |
| `extraPodLabels` | `podLabels` | Standard naming |
| `serviceAccount.name` | `serviceAccount.name` | Same key, but now supports `serviceAccount.create` |
| `config.auth.key` | `secret.jwtSecret` | Moved to Secret (was in ConfigMap) |
| `config.auth.adminPassword` | `secret.adminPassword` | Moved to Secret |
| `config.auth.totpSecret` | `secret.totpSecret` | Moved to Secret |
| `config.auth.methods.oidc.clientId` | `secret.oidcClientId` | Moved to Secret |
| `config.auth.methods.oidc.clientSecret` | `secret.oidcClientSecret` | Moved to Secret |
| `config.auth.methods.password.recaptcha.secret` | `secret.recaptchaSecret` | Moved to Secret |
| `config.integrations.office.secret` | `secret.onlyofficeSecret` | Moved to Secret |

## New Features

### Secret management
- **`secret.existingSecret`**: Bring your own Secret (for External Secrets Operator, Vault, sealed-secrets, etc.)
- **`lookup` guard**: Auto-generated passwords and JWT keys are preserved across `helm upgrade` — no more password rotation on every upgrade
- **All sensitive values in Secret**: JWT key, OIDC credentials, OnlyOffice secret, reCAPTCHA secret, and TOTP secret are now stored in a Kubernetes Secret and injected via `FILEBROWSER_*` environment variables

### Persistence
- **Independent PVCs**: Config and data volumes have separate `storageClass`, `size`, `accessMode`, `annotations`, and `labels`
- **`existingClaim`**: Bind to a pre-existing PVC instead of creating one
- **Per-PVC labels and annotations**: Enables Velero backup policies, custom metadata, etc.

### Ingress
- **Standard hosts/tls arrays**: Supports multiple hosts, multiple paths per host, and optional TLS
- **`className`** instead of `class`: Matches the Kubernetes API field name

### Infrastructure
- **`_helpers.tpl`**: Standard naming helpers (`fullname`, `name`, `labels`, `selectorLabels`)
- **`nameOverride` / `fullnameOverride`**: Control resource naming
- **Standard Kubernetes labels** (`app.kubernetes.io/*`): Consistent with the broader ecosystem
- **`serviceAccount.create`**: Optionally create a dedicated ServiceAccount with annotations (AWS IRSA, GCP Workload Identity)
- **`service.type`**: Configurable Service type (ClusterIP, NodePort, LoadBalancer)
- **`podAnnotations`**, **`podLabels`**: First-class pod metadata
- **`nodeSelector`**, **`tolerations`**, **`affinity`**: Pod scheduling
- **`containerSecurityContext`**: Container-level security (separate from pod-level)
- **`imagePullSecrets`**: Private registry support
- **`extraEnv`**: Inject additional environment variables
- **Liveness probe**: Added alongside the existing readiness probe
- **`NOTES.txt`**: Post-install instructions with access URL and password retrieval

### Chart metadata
- **`Chart.yaml`**: Proper SemVer versioning, `appVersion` synced with image tag, description, keywords, maintainers, sources
- **`image.tag` defaults to `Chart.appVersion`**: Single source of truth for the application version

## Bug Fixes

- **Config PVC always created**: Previously, the config PVC was created even when `persistence.enabled: false`. Now gated correctly.
- **Secret regeneration**: Admin password and JWT key no longer change on every `helm upgrade`
- **Service selector collision**: The Service selector now uses `app.kubernetes.io/name` + `app.kubernetes.io/instance`, preventing collisions when multiple releases share a namespace
- **`fsGroup: 0`**: Changed from root group (`0`) to `1000`
- **Ingress TLS always rendered**: TLS block is now conditional — omitted when `ingress.tls` is empty

## Files Changed

| Old File | New File | Change |
|---|---|---|
| — | `templates/_helpers.tpl` | New: naming and label helpers |
| `templates/config.yaml` | `templates/configmap.yaml` | Renamed, uses helpers |
| `templates/secret.yaml` | `templates/secret.yaml` | Rewritten: lookup guard, all secrets |
| `templates/deployment.yaml` | `templates/deployment.yaml` | Rewritten: helpers, security, scheduling |
| `templates/network.yaml` | `templates/service.yaml` | Split: Service extracted |
| `templates/network.yaml` | `templates/ingress.yaml` | Split: Ingress extracted |
| `templates/pvcs.yaml` | `templates/pvc.yaml` | Rewritten: independent config/data blocks |
| — | `templates/serviceaccount.yaml` | New: optional SA creation |
| — | `templates/NOTES.txt` | New: post-install instructions |
| — | `values-example.yaml` | New: production example |
| — | `TESTING.md` | New: testing guide |
