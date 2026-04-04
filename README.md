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

## Configuration

Prepare your configuration in a values file. See `values.yaml` for all the possibilities. 

Filebrowser Quantum requires a `config.yaml` for application configuration. This chart has an (almost) exact copy of the defaults under `values.yaml`. This makes it very easy to configure both Kubernetes, as well as application related configuration from helm values.

For example use a file called `filebrowser-values.yaml`:

```yaml
ingress:
  enabled: true
  host: filebrowser.example.com
  certSecret: secret-filebrowser
  annotations:
    cert-manager.io/cluster-issuer: lets-encrypt
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10g"

adminPassword:
  passwordLength: 50
  passwordOverride: ""  # Leave empty to auto-generate
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
After each upgrade/deploy, a new secret will be generated if not provided through config. 
To get the password, use the following for ease: 

```bash
export FILEBROWSER_NAMESPACE="filebrowser"
export RELEASE_NAME="share"

kubectl -n "${FILEBROWSER_NAMESPACE}"  get secrets ${RELEASE_NAME}-filebrowser-quantum -oyaml | yq '.data.FILEBROWSER_ADMIN_PASSWORD' | base64 -d | pbcopy
```

## Kubernetes objects
This chart will create the following objects:

- A PersistentVolumeClaim to store the database and application configuration
- A PersistentVolumeClaim for primary file sharing. 
- A Secret containing the admin password (this will be generated on the fly at deploy/upgrade time)
- A Deployment with a single pod since filebrowser is not scalable (I assume).
- A Service
- Optionally: Ingress

# Contributing
We welcome contributions! If you find a bug or have a feature request, please open an issue on our GitHub repository. If you would like to contribute code, please fork the repository and submit a pull request.

# License
This project is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at:
http://www.apache.org/licenses/LICENSE-2.0
