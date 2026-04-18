# Testing the FileBrowser Quantum Helm Chart

This guide covers how to validate the chart before deploying.

## Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) v3.10+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (for dry-run validation)
- Access to a Kubernetes cluster (for live testing)

## 1. Lint the Chart

Checks for syntax errors, missing required fields, and common mistakes.

```bash
helm lint filebrowser/
```

Expected: `1 chart(s) linted, 0 chart(s) failed`

Lint with example values:

```bash
helm lint filebrowser/ -f filebrowser/values-example.yaml
```

## 2. Render Templates Locally

Renders all templates to stdout so you can inspect the generated YAML without deploying.

```bash
# Default values
helm template test-release filebrowser/

# With production example values
helm template test-release filebrowser/ -f filebrowser/values-example.yaml
```

### Things to check in the rendered output

- **Labels**: All resources should have `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `helm.sh/chart`
- **Secret**: Should contain `FILEBROWSER_ADMIN_PASSWORD` and `FILEBROWSER_JWT_TOKEN_SECRET`
- **PVCs**: Config and data PVCs should have correct storage classes and sizes
- **Deployment**: Pod should reference the correct Secret, ConfigMap, and PVCs
- **Ingress**: Should only appear when `ingress.enabled: true`
- **ServiceAccount**: Should only appear when `serviceAccount.create: true`

## 3. Dry-Run Against a Cluster

Validates the rendered YAML against the Kubernetes API server without creating resources.

```bash
# Server-side dry-run (requires cluster access)
helm install test-release filebrowser/ --dry-run --debug

# With custom values
helm install test-release filebrowser/ -f filebrowser/values-example.yaml --dry-run --debug
```

You can also pipe `helm template` output to `kubectl`:

```bash
helm template test-release filebrowser/ | kubectl apply --dry-run=client -f -
```

## 4. Test Specific Scenarios

### Minimal install (defaults)

```bash
helm template test filebrowser/
```

Verify: Service, Deployment, ConfigMap, Secret, 2 PVCs created. No Ingress, no ServiceAccount.

### With existingSecret

```bash
helm template test filebrowser/ --set secret.existingSecret=my-secret
```

Verify: No Secret resource is rendered. Deployment references `my-secret`.

### With existingClaim for data

```bash
helm template test filebrowser/ \
  --set persistence.data.existingClaim=my-data-pvc
```

Verify: No data PVC created. Deployment volume references `my-data-pvc`.

### Persistence disabled

```bash
helm template test filebrowser/ \
  --set persistence.config.enabled=false \
  --set persistence.data.enabled=false
```

Verify: No PVC resources. Deployment has no PVC volume mounts.

### Ingress with TLS

```bash
helm template test filebrowser/ \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=files.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --set ingress.tls[0].secretName=files-tls \
  --set ingress.tls[0].hosts[0]=files.example.com
```

Verify: Ingress created with TLS block, correct host, ingressClassName.

### Ingress without TLS

```bash
helm template test filebrowser/ \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=files.internal \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

Verify: Ingress created without any `tls:` block.

### Different storage classes

```bash
helm template test filebrowser/ \
  --set persistence.config.storageClass=fast-ssd \
  --set persistence.data.storageClass=bulk-hdd \
  --set persistence.data.size=100Gi
```

Verify: Config PVC uses `fast-ssd`, data PVC uses `bulk-hdd` with 100Gi.

### Custom labels on PVCs

```bash
helm template test filebrowser/ \
  --set persistence.data.labels.backup=weekly \
  --set persistence.data.annotations."velero\.io/backup-schedule"=weekly
```

Verify: Data PVC has the `backup: weekly` label and the Velero annotation.

## 5. Install in a Test Namespace

```bash
# Create a test namespace
kubectl create namespace filebrowser-test

# Install with defaults
helm install fb-test filebrowser/ -n filebrowser-test

# Check that all resources are created
kubectl get all,configmap,secret,pvc -n filebrowser-test -l app.kubernetes.io/instance=fb-test

# Check the pod is running
kubectl get pods -n filebrowser-test -l app.kubernetes.io/instance=fb-test

# Get the admin password
kubectl get secret -n filebrowser-test fb-test-filebrowser-quantum \
  -o jsonpath="{.data.FILEBROWSER_ADMIN_PASSWORD}" | base64 -d; echo

# Port-forward and test in browser
kubectl port-forward -n filebrowser-test svc/fb-test-filebrowser-quantum 8080:8080
# Open http://localhost:8080

# Clean up
helm uninstall fb-test -n filebrowser-test
# Note: PVCs with retain=true will NOT be deleted automatically
kubectl delete pvc -n filebrowser-test -l app.kubernetes.io/instance=fb-test
kubectl delete namespace filebrowser-test
```

## 6. Upgrade Test

Verify that secrets are preserved across upgrades:

```bash
# Install
helm install fb-test filebrowser/ -n filebrowser-test

# Get the auto-generated password
kubectl get secret -n filebrowser-test fb-test-filebrowser-quantum \
  -o jsonpath="{.data.FILEBROWSER_ADMIN_PASSWORD}" | base64 -d; echo

# Upgrade (e.g., change a config value)
helm upgrade fb-test filebrowser/ -n filebrowser-test \
  --set config.auth.tokenExpirationHours=8

# Verify the password is the SAME as before
kubectl get secret -n filebrowser-test fb-test-filebrowser-quantum \
  -o jsonpath="{.data.FILEBROWSER_ADMIN_PASSWORD}" | base64 -d; echo
```
