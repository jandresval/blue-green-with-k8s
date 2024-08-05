#!/bin/bash

SKIP_PAUSE="$1" # First Script Argument
CUSTOM_TAG="$2" # Second Script Argument

BE_IMAGE_NAME="backend"
FE_IMAGE_NAME="frontend"
TAG="latest"

if [[ -n "$CUSTOM_TAG" ]]; then
    TAG="$CUSTOM_TAG"
fi

# Uncomment and set the following if using a local registry
# REGISTRY_URL="your-local-registry"

docker build -t "${BE_IMAGE_NAME}:${TAG}" -f ./src/webapp/Dockerfile ./src/webapp --no-cache
docker build -t "${FE_IMAGE_NAME}:${TAG}" -f ./src/frontend/Dockerfile ./src/frontend --no-cache

# Optional: Tag and push the image to a local registry
# docker tag "${BE_IMAGE_NAME}:${TAG}" "${REGISTRY_URL}/${BE_IMAGE_NAME}:${TAG}"
# docker tag "${FE_IMAGE_NAME}:${TAG}" "${REGISTRY_URL}/${FE_IMAGE_NAME}:${TAG}"
# docker push "${REGISTRY_URL}/${BE_IMAGE_NAME}:${TAG}"
# docker push "${REGISTRY_URL}/${FE_IMAGE_NAME}:${TAG}"

echo "Build and tag completed."

if [[ "$SKIP_PAUSE" != "true" ]]; then
    read -rsp $'\nScript ended. Press any key to exit...'
fi