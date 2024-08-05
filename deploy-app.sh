#!/bin/bash

# Ensure the build script is executable
if [[ ! -x "build-images.sh" ]]; then
    chmod +x build-images.sh
fi

# Generate a random tag from a subset of the alphabet
declare -a letters=({a..z})
RANDOMTAG=$(for i in {1..8}; do echo -n "${letters[$RANDOM % ${#letters[@]}]}"; done)

# Build images with the generated random tag
./build-images.sh true "$RANDOMTAG"

# Deploy the database
kubectl apply -f ./db/mariadb-deployment.yaml

# Deploy backend with the random tag
backendTemplate=$(sed "s/{{TAG}}/$RANDOMTAG/g" "./k8s-local/local-backend-deployment.yaml.template")
echo "$backendTemplate" | kubectl apply -f -

# Deploy frontend with the random tag
frontendTemplate=$(sed "s/{{TAG}}/$RANDOMTAG/g" "./k8s-local/local-frontend-deployment.yaml.template")
echo "$frontendTemplate" | kubectl apply -f -

# Uncomment to check deployments
# kubectl get deployments