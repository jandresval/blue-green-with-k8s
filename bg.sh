#!/bin/bash

# Function to deploy or update
deploy() {
    local status=$1
    local image_tag=$2
    
    # Use sed to replace placeholders in the template
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$image_tag/g" "./deployments/local/backend.yaml.template" | kubectl apply -f -
    
    echo "$status deployment updated with image tag: $image_tag"
}

# Function to show current status and provide access URLs
show_status() {
    echo "Current Deployments:"
    kubectl get deployments
    echo
    echo "Current Services:"
    kubectl get services
    echo
    echo "Access URLs:"
    
    local stable_port=$(kubectl get service b-g-backend-service-stable -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    local beta_port=$(kubectl get service b-g-backend-service-beta -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    
    if [ ! -z "$stable_port" ]; then
        echo "Stable: http://localhost:$stable_port"
    fi
    
    if [ ! -z "$beta_port" ]; then
        echo "Beta: http://localhost:$beta_port"
    fi
}

# Function to teardown all resources
teardown() {
    echo "Tearing down all resources..."
    kubectl delete deployment b-g-backend-stable b-g-backend-beta
    kubectl delete service b-g-backend-service-stable b-g-backend-service-beta
    echo "Teardown complete."
}

# Main script logic
case "$1" in
    deploy-stable)
        if [ -z "$2" ]; then
            echo "Please provide an image tag for stable deployment"
            exit 1
        fi
        deploy "stable" "$2"
        ;;
    deploy-beta)
        if [ -z "$2" ]; then
            echo "Please provide an image tag for beta deployment"
            exit 1
        fi
        deploy "beta" "$2"
        ;;
    promote)
        beta_image=$(kubectl get deployment b-g-backend-beta -o jsonpath='{.spec.template.spec.containers[0].image}')
        deploy "stable" "$beta_image"
        echo "Beta promoted to stable. New stable image: $beta_image"
        ;;
    status)
        show_status
        ;;
    teardown)
        teardown
        ;;
    *)
        echo "Usage: $0 {deploy-stable <image_tag>|deploy-beta <image_tag>|promote|status|teardown}"
        exit 1
        ;;
esac

if [ "$1" != "teardown" ]; then
    show_status
fi

read -rsp $'\nScript ended. Press any key to exit...'