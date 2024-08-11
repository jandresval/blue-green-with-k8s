#!/bin/bash

deploy_db() {
    echo "Deploying Database..."
    kubectl apply -f ./deployments/local/db.yaml

    echo "Waiting for Database to be created..."
    kubectl wait --for=condition=available --timeout=60s deployment/b-g-mariadb
}

# Function to deploy or update
deploy() {
    local status=$1
    local backend_image_tag=$2
    local frontend_image_tag=$3
    
    # Deploy backend
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$backend_image_tag/g" "./deployments/local/backend.yaml.template" | kubectl apply -f -
    
    echo "Waiting for backend service to be created..."
    kubectl wait --for=condition=available --timeout=60s deployment/b-g-backend-$status

    # Get the NodePort of the backend service
    local backend_node_port=$(kubectl get service b-g-backend-service-$status -o jsonpath='{.spec.ports[0].nodePort}')
    
    # Deploy frontend
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$frontend_image_tag/g" -e "s/{{BACKEND_NODE_PORT}}/$backend_node_port/g" "./deployments/local/frontend.yaml.template" | kubectl apply -f -
    
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
    
    local stable_backend_port=$(kubectl get service b-g-backend-service-stable -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    local beta_backend_port=$(kubectl get service b-g-backend-service-beta -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    local stable_frontend_port=$(kubectl get service b-g-frontend-service-stable -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    local beta_frontend_port=$(kubectl get service b-g-frontend-service-beta -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    local mariadb_port=$(kubectl get service mariadb-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    
    if [ ! -z "$stable_backend_port" ]; then
        echo "Stable Backend: http://localhost:$stable_backend_port"
    fi
    if [ ! -z "$beta_backend_port" ]; then
        echo "Beta Backend: http://localhost:$beta_backend_port"
    fi
    if [ ! -z "$stable_frontend_port" ]; then
        echo "Stable Frontend: http://localhost:$stable_frontend_port"
    fi
    if [ ! -z "$beta_frontend_port" ]; then
        echo "Beta Frontend: http://localhost:$beta_frontend_port"
    fi
    if [ ! -z "$mariadb_port" ]; then
        echo "MariaDB: localhost:$mariadb_port"
    fi
}

# New function to check environment variables
check_env() {
    local status=$1
    echo "Checking environment variables for $status deployment"
    
    echo "Backend environment:"
    kubectl exec deploy/b-g-backend-$status -- printenv | grep ASPNETCORE_ENVIRONMENT
    kubectl exec deploy/b-g-backend-$status -- printenv | grep Database__ConnectionString
    
    echo "Frontend environment:"
    kubectl exec deploy/b-g-frontend-$status -- printenv | grep API_URL_GREETING_ENDPOINT
}

# Function to teardown all resources
teardown() {
    echo "Tearing down all resources..."
    kubectl delete deployment b-g-backend-stable b-g-backend-beta b-g-frontend-stable b-g-frontend-beta b-g-mariadb
    kubectl delete service b-g-backend-service-stable b-g-backend-service-beta b-g-frontend-service-stable b-g-frontend-service-beta mariadb-service
    kubectl delete configmap mariadb-init
    kubectl delete pvc mariadb-pv-claim
    echo "Teardown complete."
}

# Main script logic
case "$1" in
    deploy-db)
        deploy_db
        ;;
    deploy-stable)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Please provide image tags for backend and frontend stable deployment"
            exit 1
        fi
        deploy_db
        deploy "stable" "$2" "$3"
        check_env "stable"
        ;;
    deploy-beta)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Please provide image tags for backend and frontend beta deployment"
            exit 1
        fi
        deploy_db
        deploy "beta" "$2" "$3"
        check_env "beta"
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
        if [ -z "$2" ]; then
            echo "Please specify 'stable' or 'beta' to check environment"
            exit 1
        fi
        check_env "$2"
        ;;
    teardown)
        teardown
        ;;
    *)
        echo "Usage: $0 {deploy-mariadb|deploy-stable <backend_image_tag> <frontend_image_tag>|deploy-beta <backend_image_tag> <frontend_image_tag>|promote|status|check-env <stable|beta>|teardown}"
        exit 1
        ;;
esac

if [ "$1" != "teardown" ] && [ "$1" != "check-env" ]; then
    show_status
fi

read -rsp $'\nScript ended. Press any key to exit...'