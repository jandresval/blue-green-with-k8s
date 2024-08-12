#!/bin/bash

# Constants
DB_DEPLOYMENT="./deployments/local/db.yaml"
BACKEND_TEMPLATE="./deployments/local/backend.yaml.template"
FRONTEND_TEMPLATE="./deployments/local/frontend.yaml.template"

# Function to deploy database
deploy_db() {
    echo "Deploying Database..."
    kubectl apply -f "$DB_DEPLOYMENT"

    echo "Waiting for Database to be created..."
    kubectl wait --for=condition=available --timeout=60s deployment/b-g-mariadb
}

# Function to deploy or update
deploy() {
    local status=$1
    local backend_image_tag=$2
    local frontend_image_tag=$3
    
    # Deploy backend
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$backend_image_tag/g" "$BACKEND_TEMPLATE" | kubectl apply -f -
    
    echo "Waiting for backend service to be created..."
    kubectl wait --for=condition=available --timeout=60s deployment/b-g-backend-$status

    # Get the NodePort of the backend service
    local backend_node_port=$(kubectl get service b-g-backend-service-$status -o jsonpath='{.spec.ports[0].nodePort}')
    
    # Deploy frontend
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$frontend_image_tag/g" -e "s/{{BACKEND_NODE_PORT}}/$backend_node_port/g" "$FRONTEND_TEMPLATE" | kubectl apply -f -
    
    echo "$status deployment updated with backend image tag: $backend_image_tag and frontend image tag: $frontend_image_tag"
    echo "Frontend configured to use backend at http://localhost:$backend_node_port"
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
    
    local services=("b-g-backend-service-stable" "b-g-backend-service-beta" "b-g-frontend-service-stable" "b-g-frontend-service-beta" "mariadb-service")
    local names=("Stable Backend" "Beta Backend" "Stable Frontend" "Beta Frontend" "MariaDB")
    
    for i in "${!services[@]}"; do
        local port=$(kubectl get service ${services[$i]} -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        if [ ! -z "$port" ]; then
            echo "${names[$i]}: http://localhost:$port"
        fi
    done
}

# Function to check environment variables
check_env() {
    local status=$1
    echo "Checking environment variables for $status deployment"
    
    for deployment in "backend" "frontend"; do
        echo "$deployment environment:"
        kubectl exec deploy/b-g-$deployment-$status -- printenv | grep -E 'ASPNETCORE_ENVIRONMENT|Database__ConnectionString|API_URL_GREETING_ENDPOINT'
    done
}

# Function to teardown all resources
teardown() {
    echo "Tearing down all resources..."
    kubectl delete deployment -l app=b-g
    kubectl delete service -l app=b-g
    kubectl delete configmap mariadb-init
    kubectl delete pvc mariadb-pv-claim
    echo "Teardown complete."
}

# Main script logic
case "$1" in
    deploy-db)
        deploy_db
        ;;
    deploy)
        if [ "$#" -ne 4 ] || [[ ! "$2" =~ ^(stable|beta)$ ]]; then
            echo "Usage: $0 deploy <stable|beta> <backend_image_tag> <frontend_image_tag>"
            exit 1
        fi
        deploy_db
        deploy "$2" "$3" "$4"
        check_env "$2"
        ;;
    promote)
        beta_backend_image=$(kubectl get deployment b-g-backend-beta -o jsonpath='{.spec.template.spec.containers[0].image}')
        beta_frontend_image=$(kubectl get deployment b-g-frontend-beta -o jsonpath='{.spec.template.spec.containers[0].image}')
        deploy "stable" "$beta_backend_image" "$beta_frontend_image"
        echo "Beta promoted to stable. New stable images: Backend: $beta_backend_image, Frontend: $beta_frontend_image"
        check_env "stable"
        ;;
    status)
        show_status
        ;;
    check-env)
        if [ -z "$2" ] || [[ ! "$2" =~ ^(stable|beta)$ ]]; then
            echo "Usage: $0 check-env <stable|beta>"
            exit 1
        fi
        check_env "$2"
        ;;
    teardown)
        teardown
        ;;
    *)
        echo "Usage: $0 {deploy-db|deploy <stable|beta> <backend_image_tag> <frontend_image_tag>|promote|status|check-env <stable|beta>|teardown}"
        exit 1
        ;;
esac

if [[ "$1" != "teardown" && "$1" != "check-env" ]]; then
    show_status
fi