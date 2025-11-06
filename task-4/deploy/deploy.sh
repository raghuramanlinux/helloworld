#!/usr/bin/env bash
set -euo pipefail

# Simple helper to deploy this repo to a local kind or minikube cluster.
# Assumptions:
# - Docker is available and the image build context is ./5/app by default
# - kubectl is installed and points to the target cluster (kind/minikube)
# - If DOCKERHUB_USERNAME and DOCKERHUB_TOKEN are provided, the script will push to Docker Hub.

IMAGE_CONTEXT=${1:-./5/app}
IMAGE_NAME=${2:-$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" )}
TAG=${3:-latest}

FULL_IMAGE="$IMAGE_NAME:$TAG"

echo "Building image $FULL_IMAGE from context $IMAGE_CONTEXT"
docker build -t "$FULL_IMAGE" "$IMAGE_CONTEXT"

if [ -n "${DOCKERHUB_USERNAME:-}" ] && [ -n "${DOCKERHUB_TOKEN:-}" ]; then
  echo "Logging in to Docker Hub and pushing image"
  echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
  docker push "$FULL_IMAGE"
else
  echo "No Docker Hub credentials found — attempting to load into kind (if available)"
  if command -v kind >/dev/null 2>&1; then
    kind load docker-image "$FULL_IMAGE" || true
  elif command -v minikube >/dev/null 2>&1; then
    minikube image load "$FULL_IMAGE" || true
  else
    echo "Neither kind nor minikube found — cannot load image into local cluster. Exiting."
    exit 1
  fi
fi

if [ -d ./k8s ]; then
  echo "Applying k8s manifests from ./k8s (replacing REPLACE_IMAGE with $FULL_IMAGE)"
  for f in ./k8s/*.yaml; do
    sed "s|REPLACE_IMAGE|${FULL_IMAGE}|g" "$f" | kubectl apply -f -
  done
else
  echo "No ./k8s directory found — nothing to apply"
fi

echo "Deployment complete. Run 'kubectl get all' to inspect resources."
