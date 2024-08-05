#!/bin/bash

# Ensure the build script is executable
if [[ ! -x "build-images.sh" ]]; then
    chmod +x build-images.sh
fi

# Generate a random tag from a subset of the alphabet
RANDOMTAG=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)

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

echo -e "\n\033[1;33mWaiting for deployments to initialize...\033[0m"
sleep 8

echo -e "\n\033[1;34m===== Deployment Status =====\033[0m"
kubectl get deployments

echo -e "\n\033[1;32mVerification Steps:\033[0m"
echo -e "1. Check for these entries in the deployment list above:"
echo -e "   - \033[1;36mbackend\033[0m"
echo -e "   - \033[1;36mfrontend\033[0m"
echo -e "   - \033[1;36mmariadb\033[0m"
echo -e "2. Ensure each deployment shows \033[1;32m1/1\033[0m in the READY column."

echo -e "\n\033[1;33mDeployment Script completed.\033[0m"
echo -e "\033[1;35mPress any key to exit...\033[0m"
read -n 1 -s -r