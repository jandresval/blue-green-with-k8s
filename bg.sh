#!/bin/bash

# Constants
DB_DEPLOYMENT="./deployments/local/db.yaml"
BACKEND_TEMPLATE="./deployments/local/backend.yaml.template"
FRONTEND_TEMPLATE="./deployments/local/frontend.yaml.template"
BUILD_SCRIPT="./build-images.sh"

# Color codes for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to generate a random tag
generate_random_tag() {
    echo $(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)
}

# Function to deploy database
deploy_db() {
    echo -e "${BLUE}Deploying Database...${NC}"
    kubectl apply -f "$DB_DEPLOYMENT"

    echo -e "${YELLOW}Waiting for Database to be created...${NC}"
    kubectl wait --for=condition=available --timeout=60s deployment/b-g-mariadb
}

# Function to deploy or update
deploy() {
    local status=$1
    local image_tag=$2
    
    # Deploy backend
    echo -e "${BLUE}Deploying $status backend...${NC}"
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$image_tag/g" "$BACKEND_TEMPLATE" | kubectl apply -f -
    
    echo -e "${YELLOW}Waiting for $status backend service to be created...${NC}"
    kubectl wait --for=condition=available --timeout=60s deployment/b-g-backend-$status

    # Get the NodePort of the backend service
    local backend_node_port=$(kubectl get service b-g-backend-service-$status -o jsonpath='{.spec.ports[0].nodePort}')
    
    # Deploy frontend
    echo -e "${BLUE}Deploying $status frontend...${NC}"
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$image_tag/g" -e "s/{{BACKEND_NODE_PORT}}/$backend_node_port/g" "$FRONTEND_TEMPLATE" | kubectl apply -f -
    
    echo -e "${GREEN}$status deployment updated with image tag: $image_tag${NC}"
    echo -e "${CYAN}Frontend configured to use backend at http://localhost:$backend_node_port${NC}"
}

# Function to show current status and provide access URLs
show_status() {
    echo -e "\n${BLUE}===== Current Deployment Status =====${NC}"
    kubectl get deployments

    echo -e "\n${BLUE}Current Services:${NC}"
    kubectl get services

    echo -e "\n${GREEN}Access URLs:${NC}"
    
    local services=("b-g-backend-service-stable" "b-g-backend-service-beta" "b-g-frontend-service-stable" "b-g-frontend-service-beta" "mariadb-service")
    local names=("Stable Backend" "Beta Backend" "Stable Frontend" "Beta Frontend" "MariaDB")
    
    for i in "${!services[@]}"; do
        local port=$(kubectl get service ${services[$i]} -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        if [ ! -z "$port" ]; then
            echo -e "${CYAN}${names[$i]}: http://localhost:$port${NC}"
        fi
    done
}

# Function to check environment variables
check_env() {
    local status=$1
    echo -e "${BLUE}Checking environment variables for $status deployment${NC}"
    
    for deployment in "backend" "frontend"; do
        echo -e "${CYAN}$deployment environment:${NC}"
        kubectl exec deploy/b-g-$deployment-$status -- printenv | grep -E 'ASPNETCORE_ENVIRONMENT|Database__ConnectionString|API_URL_GREETING_ENDPOINT'
    done
}

# Function to teardown all resources
teardown() {
    echo -e "${YELLOW}Tearing down all resources...${NC}"
    kubectl delete deployment -l app=b-g
    kubectl delete service -l app=b-g
    kubectl delete configmap mariadb-init
    kubectl delete pvc mariadb-pv-claim
    echo -e "${GREEN}Teardown complete.${NC}"
}

# Function to build images
build_images() {
    local tag=$1
    
    # Ensure the build script is executable
    if [[ ! -x "$BUILD_SCRIPT" ]]; then
        chmod +x "$BUILD_SCRIPT"
    fi

    echo -e "${BLUE}Building images with tag: $tag${NC}"
    "$BUILD_SCRIPT" true "$tag"
}

# Function to handle deployment
handle_deployment() {
    local deployment_type=$1
    local tag=$(generate_random_tag)
    
    build_images "$tag"
    deploy_db
    deploy "$deployment_type" "$tag"
    check_env "$deployment_type"
}

# Main script logic
case "$1" in
    deploy-db)
        deploy_db
        ;;
    deploy)
        if [ "$#" -ne 2 ] || [[ ! "$2" =~ ^(stable|beta)$ ]]; then
            echo -e "${YELLOW}Usage: $0 deploy <stable|beta>${NC}"
            exit 1
        fi
        handle_deployment "$2"
        ;;
    promote)
        beta_image=$(kubectl get deployment b-g-backend-beta -o jsonpath='{.spec.template.spec.containers[0].image}')
        deploy "stable" "${beta_image##*:}" # Extract tag from image
        echo -e "${GREEN}Beta promoted to stable. New stable image tag: ${beta_image##*:}${NC}"
        check_env "stable"
        ;;
    status)
        show_status
        ;;
    check-env)
        if [ -z "$2" ] || [[ ! "$2" =~ ^(stable|beta)$ ]]; then
            echo -e "${YELLOW}Usage: $0 check-env <stable|beta>${NC}"
            exit 1
        fi
        check_env "$2"
        ;;
    teardown)
        teardown
        ;;
    *)
        echo -e "${YELLOW}Usage: $0 {deploy-db|deploy <stable|beta>|promote|status|check-env <stable|beta>|teardown}${NC}"
        exit 1
        ;;
esac

if [[ "$1" != "teardown" && "$1" != "check-env" ]]; then
    show_status
fi

echo -e "\n${YELLOW}Deployment Script completed.${NC}"
echo -e "${CYAN}Press any key to exit...${NC}"
read -n 1 -s -r