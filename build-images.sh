#!/bin/bash

CUSTOM_TAG="$1"

BE_IMAGE_NAME="b-g-backend"
FE_IMAGE_NAME="b-g-frontend"
TAG="latest"

if [[ -n "$CUSTOM_TAG" ]]; then
    TAG="$CUSTOM_TAG"
fi

# Uncomment and set the following if using a local registry
# REGISTRY_URL="your-local-registry"

docker build -t "${BE_IMAGE_NAME}:${TAG}" -f ./backend/Dockerfile ./backend/Api --no-cache
docker build -t "${FE_IMAGE_NAME}:${TAG}" -f ./frontend/Dockerfile ./frontend --no-cache

# Optional: Tag and push the image to a local registry
# docker tag "${BE_IMAGE_NAME}:${TAG}" "${REGISTRY_URL}/${BE_IMAGE_NAME}:${TAG}"
# docker tag "${FE_IMAGE_NAME}:${TAG}" "${REGISTRY_URL}/${FE_IMAGE_NAME}:${TAG}"
# docker push "${REGISTRY_URL}/${BE_IMAGE_NAME}:${TAG}"
# docker push "${REGISTRY_URL}/${FE_IMAGE_NAME}:${TAG}"

echo "Build and tag completed."