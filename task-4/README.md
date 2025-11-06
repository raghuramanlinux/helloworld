# Local CI/CD helper (GitHub Actions + kind/minikube)

This folder contains a simple GitHub Actions workflow and a local deploy helper to build, test, and deploy the project to a local Kubernetes cluster (kind or minikube).

Files added
- `.github/workflows/ci-cd.yml` — GitHub Actions workflow that:
  - checks out code, runs tests (if pytest is available), builds a Docker image
  - pushes to Docker Hub when `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are set
  - otherwise creates a `kind` cluster (inside the runner), loads the image, and deploys manifests from `./k8s`

- `deploy/deploy.sh` — helper script for local use; builds the image, pushes or loads it into kind/minikube, and applies manifests (replacing `REPLACE_IMAGE` placeholder in YAML files)

Usage notes & assumptions

- The workflow builds the Docker image from `IMAGE_CONTEXT` which is set to `./5/app` by default. Adjust this path in the workflow or pass parameters to `deploy.sh` if your app is elsewhere.
- To publish to Docker Hub from GitHub Actions, set repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`.
- The workflow creates and uses a `kind` cluster if Docker Hub credentials are not provided; this keeps the deploy within the Actions runner and works for ephemeral CI deployments.
- The deploy steps perform a simple text substitution replacing `REPLACE_IMAGE` in your `k8s/*.yaml` manifests with the built image tag. Add `image: REPLACE_IMAGE` to your deployment YAML or update the workflow to match your manifest structure.

Local deploy example

```bash
# Build and deploy locally using this repo's default context
./folder/deploy/deploy.sh ./5/app my-image-name $(git rev-parse --short HEAD)
```

If you'd like, I can:
- update the workflow to build from a different path (for example `./7` or `./2/app`)
- add a sample `k8s/deployment.yaml` in this folder that uses `REPLACE_IMAGE` so the workflow can deploy without touching your existing manifests
- make the workflow support pushing to a local registry (like `registry:5000`) instead of kind
