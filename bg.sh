#!/bin/bash

# Function to deploy or update
deploy() {
    local status=$1
    local image_tag=$2
    
    # Use sed to replace placeholders in the template
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$image_tag/g" deployment-template.yaml | kubectl apply -f -
    
    echo "$status deployment updated with image tag: $image_tag"
}

# Function to show current status
show_status() {
    echo "Current Deployments:"
    kubectl get deployments -l app=b-g-backend
    echo
    echo "Current Services:"
    kubectl get services -l app=b-g-backend
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
    apply-ingress)
        kubectl apply -f ingress.yaml
        echo "Ingress applied"
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 {deploy-stable <image_tag>|deploy-beta <image_tag>|promote|apply-ingress|status}"
        exit 1
        ;;
esac

# Show status after any action
show_status