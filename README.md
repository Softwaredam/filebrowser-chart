
# Filebrowser Quantum Chart

This project contains a helm chart to install the [Filebrowser Quantum](https://github.com/gtsteffaniak/filebrowser) on a Kubernetes cluster.
Same as the Filebrowser Quantum itself, this project is in beta. The latest tested version is `0.7.11-beta`.


## Installation

**Prerequisites:**
- There is already a namespace
- There are sufficent resources

### Configuration

Prepare your configuration in a values file. See `values.yaml` for all the possibilities. 

Filebrowser Quantum requires a `config.yaml` for application configuration. This chart has an (almost) exact copy of the defaults under `values.yaml`. This makes it very easy to configure both Kubernetes, as well as application related configuration from helm values.

For example use a file called `filebrowser-values.yaml`:

```yaml
ingress:
  enabled: true
  host: filebrowser.example.com
  certSecret: secret-filebrowser

adminPassword:
  passwordLength: 50
  passwordOverride: ""  # Leave empty to auto-generate
```

### Deployment

Then use `helm` to install, like:

```bash
export FILEBROWSER_NAMESPACE="filebrowser"
export RELEASE_NAME="share"

helm upgrade --install \
     --namespace="${FILEBROWSER_NAMESPACE}" \
     "${RELEASE_NAME}" \
     filebrowser \
     --values filebrowser-values.yaml
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
