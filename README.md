# Filebrowser Quantum Helm Chart

This project contains a Helm chart to install the [FileBrowser Quantum](https://github.com/gtsteffaniak/filebrowser) on a Kubernetes cluster.

This open source project is proudly created and maintained by [Softwaredam](https://softwaredam.com).

<p align="center">
  <img src="https://softwaredam.com/wp-content/uploads/2025/08/logo.svg" alt="Softwaredam Logo" height="150" style="vertical-align: middle;"/>
  <span style="margin: 0 12px; font-size: 44px; vertical-align: middle;">×</span>
  <img src="icon.svg" alt="Filebrowser Quantum Chart Logo" height="180" style="vertical-align: middle;"/>
</p>

# Support
This Helm chart is provided as open-source software under the terms of the included license.

If you require commercial support, consulting, or custom solutions, please feel free to contact us at [Softwaredam](https://softwaredam.com).

# Installation

**Prerequisites:**

- Kubernetes 1.23+
- Helm 3.10+
- Sufficient cluster resources

## Configuration

Prepare your configuration in a values file. See `values.yaml` for all options and `values-example.yaml` for a production-ready example.

Filebrowser Quantum requires a `config.yaml` for application configuration. This chart has an (almost) exact copy of the defaults under `values.yaml`. This makes it very easy to configure both Kubernetes, as well as application related configuration from helm values.

For example use a file called `filebrowser-values.yaml`:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-body-size: "10g"
  hosts:
    - host: filebrowser.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: filebrowser-tls
      hosts:
        - filebrowser.example.com

secret:
  adminPasswordLength: 50
```

## Deployment

Then use `helm` to install, like:

```bash
export FILEBROWSER_NAMESPACE="filebrowser"
export RELEASE_NAME="share"

helm upgrade --install \
     --namespace="${FILEBROWSER_NAMESPACE}" \
     --create-namespace \
     "${RELEASE_NAME}" \
     filebrowser \
     --values filebrowser-values.yaml
```

### Admin password

The admin password is auto-generated on first install and preserved across upgrades. To retrieve it:

```bash
kubectl get secret -n "${FILEBROWSER_NAMESPACE}" "${RELEASE_NAME}-filebrowser-quantum" \
  -o jsonpath="{.data.FILEBROWSER_ADMIN_PASSWORD}" | base64 -d; echo
```

You can also set a specific password via `secret.adminPassword`, or bring your own Secret with `secret.existingSecret`.

### Uninstall

```bash
helm uninstall "${RELEASE_NAME}" -n "${FILEBROWSER_NAMESPACE}"
```

Note: PVCs with `retain: true` (the default) are kept after uninstall to prevent data loss. Delete them manually if needed.

## Kubernetes objects
This chart will create the following objects:

- A PersistentVolumeClaim to store the database and application configuration
- A PersistentVolumeClaim for primary file sharing
- A Secret containing the admin password, JWT signing key, and other sensitive values
- A ConfigMap with the application configuration
- A Deployment with a single pod (filebrowser is not horizontally scalable)
- A Service
- Optionally: Ingress, ServiceAccount

## Further reading

- [values-example.yaml](filebrowser/values-example.yaml) — Production-ready example values
- [CHANGES.md](CHANGES.md) — Changelog and migration guide
- [TESTING.md](TESTING.md) — How to validate the chart

# Contributing
We welcome contributions! If you find a bug or have a feature request, please open an issue on our GitHub repository. If you would like to contribute code, please fork the repository and submit a pull request.

# License
This project is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at:
http://www.apache.org/licenses/LICENSE-2.0
