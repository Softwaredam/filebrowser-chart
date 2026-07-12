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

- Access to a Kubernetes cluster
- Sufficent resources
- Helm3

## Quick Start

Install the chart directly from the GitHub Container Registry (OCI):

```bash
helm upgrade --install filebrowser \
  oci://ghcr.io/softwaredam/helm-charts/filebrowser-quantum \
  --namespace filebrowser \
  --create-namespace \
  --values filebrowser-values.yaml
```

## Configuration

This chart supports multiple ways to prepare your deployment configuration. See `values.yaml` for all the possibilities. 

### Application configuration
Filebrowser Quantum requires a `config.yaml` for application configuration. This chart has an (almost) exact copy of the defaults under `values.yaml`. This makes it very easy to configure both Kubernetes, as well as application related configuration from helm values.

### Admin password
After each upgrade/deploy, a new password will be generated for the admin user. This is intentional to keep the admin password rolling. the default admin password can be overridden (not recommended) through config. 

To get the password, use the following:
```bash
kubectl -n filebrowser get secrets filebrowser-filebrowser-quantum -oyaml | yq '.data.FILEBROWSER_ADMIN_PASSWORD' | base64 -d | pbcopy
```

### Other secrets
To provide secrets like OIDC/JWT values, there are 2 way. Both ways will be mounted in a kubernetes secret and eventually be passed as environment variables to the container pod, where the filebrowser Quantum expects it. 

1. Use existing secrets (for example managed by ExternalSecrets operator) that are managed outside the scope of this chart. See `extraEnv` in `value.yaml`.
2. Provide variable (secrets) through `extraEnvSecrets`. See `values.yaml`. This is a useful case for example when you use SOPS to manage your secrets alongside your other config in git.

### Configuration Examples

#### Simple configuration

For example use a file called `filebrowser-values.yaml`:
```yaml
ingress:
  enabled: true
  host: filebrowser.example.com
  certSecret: secret-filebrowser
  annotations:
    cert-manager.io/cluster-issuer: lets-encrypt
    
    #Note that nginx ingress controller is end of life (EOL). This snippet just shows how to add an annotation.
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10g"

adminPassword:
  passwordLength: 50
  passwordOverride: "" # Leave empty to auto-generate
```


#### Configuration with external managed secrets

This example shows how to use and existing secret which contains OIDC configuration.

```yaml
#filebrowser-values.yaml

extraEnv:
  - name: FILEBROWSER_OIDC_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: filebrowser-oidc-client
        key: id
  - name: FILEBROWSER_OIDC_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: filebrowser-oidc-client
        key: secret
```


#### Configuration with SOPS managed secrets
This example shows how to use SOPS to manage OIDC (or any other) secret. 

```yaml
#filebrowser-values.yaml
adminPassword:
  passwordLength: 50
  passwordOverride: "" # Leave empty to auto-generate

```
```yaml
#decrypted-sops-secrets.yaml
adminPassword:
  passwordLength: 50
  passwordOverride: "" # Leave empty to auto-generate

extraEnvSecrets:
    FILEBROWSER_OIDC_CLIENT_ID: the-oidc-client-id
    FILEBROWSER_OIDC_CLIENT_SECRET: the-oidc-client-secret
```

## Kubernetes objects

This chart will create the following objects:

- A PersistentVolumeClaim to store the database and application configuration
- A PersistentVolumeClaim for primary file sharing.
- A Secret containing the admin password (this will be generated on the fly at deploy/upgrade time). 
- A Deployment with a single pod since filebrowser is not scalable (I assume).
- A Service
- Optionally: Ingress

# Contributing

We welcome contributions! If you find a bug or have a feature request, please open an issue on our GitHub repository. If you would like to contribute code, please fork the repository and submit a pull request.

# License

This project is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at:
http://www.apache.org/licenses/LICENSE-2.0
