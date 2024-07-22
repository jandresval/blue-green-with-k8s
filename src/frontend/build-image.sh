#!/bin/bash

# Define variables
IMAGE_NAME="frontend"
TAG="latest"

# Uncomment and set the following if using a local registry
# REGISTRY_URL="your-local-registry"

# Build the Docker image
docker build -t ${IMAGE_NAME}:${TAG} . --no-cache

# Tag the image for a local registry (optional)
# docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY_URL}/${IMAGE_NAME}:${TAG}

# Push the image to the local registry (optional)
# docker push ${REGISTRY_URL}/${IMAGE_NAME}:${TAG}

echo "Build and tag completed."

read -rsp $'\nScript end.'