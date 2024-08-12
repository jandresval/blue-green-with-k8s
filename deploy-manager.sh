#!/bin/bash

# ==============================
# Constants
# ==============================
readonly DB_DEPLOYMENT="./deployments/local/db.yaml"
readonly BACKEND_TEMPLATE="./deployments/local/backend.yaml.template"
readonly FRONTEND_TEMPLATE="./deployments/local/frontend.yaml.template"
readonly BUILD_SCRIPT="./build-images.sh"

# ==============================
# Color codes for output
# ==============================
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# ==============================
# Logging Functions
# ==============================

# Function to print colored output with improved spacing
print_colored() {
    local color=$1
    local message=$2
    local prefix=$3
    echo -e "\n${color}${prefix}${message}${NC}"
}

# Function to print a header
print_header() {
    local message=$1
    echo -e "\n${BLUE}==============================${NC}"
    echo -e "${BLUE}  ${message}${NC}"
    echo -e "${BLUE}==============================${NC}"
}

# Function to print a sub-header
print_subheader() {
    local message=$1
    echo -e "\n${CYAN}--- ${message} ---${NC}"
}

# Function to print a success message
print_success() {
    print_colored "$GREEN" "$1" "✔ "
}

# Function to print a warning message
print_warning() {
    print_colored "$YELLOW" "$1" "⚠ "
}

# Function to print an error message
print_error() {
    print_colored "$RED" "$1" "✖ "
}

# Function to print an info message
print_info() {
    print_colored "$BLUE" "$1" "ℹ "
}

# ==============================
# Utility Functions
# ==============================

# Function to generate a random tag
generate_random_tag() {
    cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1
}

# ==============================
# Deployment Functions
# ==============================

# Function to deploy database
deploy_db() {
    print_header "Deploying Database"
    kubectl apply -f "$DB_DEPLOYMENT"

    print_info "Waiting for Database to be fully ready..."
    if kubectl wait --for=condition=ready --timeout=60s pod -l app=b-g,component=mariadb; then
        print_success "Database is ready!"
    else
        print_error "Database is not ready. Please check the deployment."
        read -n 1 -s -r
    fi
}

# Function to deploy or update
deploy() {
    local status=$1
    local image_tag=$2
    
    print_header "Deploying $status Environment"

    # Deploy backend
    print_subheader "Deploying $status backend"
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$image_tag/g" "$BACKEND_TEMPLATE" | kubectl apply -f -
    
    print_info "Waiting for $status backend deployment to be available..."
    if ! kubectl wait --for=condition=available --timeout=60s deployment/b-g-backend-$status; then
        print_error "Backend deployment failed. Check the logs for more information."
        kubectl get pods -l app=b-g,component=backend,status=$status
        kubectl describe deployment b-g-backend-$status
        show_exit_prompt
    fi

    local service_name="b-g-backend-service-$status"
    print_info "Checking if $status backend service exists..."
    if kubectl get service "$service_name" &> /dev/null; then
        print_success "$status backend service exists."
    else
        print_error "Backend service $service_name does not exist. Check the configuration."
        wait_for_user
        return 1
    fi

    # Get the NodePort of the backend service
    local backend_node_port=$(kubectl get service "$service_name" -o jsonpath='{.spec.ports[0].nodePort}')
    
    # Deploy frontend
    print_subheader "Deploying $status frontend"
    sed -e "s/{{STATUS}}/$status/g" -e "s/{{IMAGE_TAG}}/$image_tag/g" -e "s/{{BACKEND_NODE_PORT}}/$backend_node_port/g" "$FRONTEND_TEMPLATE" | kubectl apply -f -
    
    print_info "Waiting for $status frontend deployment to be available..."
    if ! kubectl wait --for=condition=available --timeout=60s deployment/b-g-frontend-$status; then
        print_error "Frontend deployment failed. Check the logs for more information."
        kubectl get pods -l app=b-g,component=frontend,status=$status
        kubectl describe deployment b-g-frontend-$status
        show_exit_prompt
    fi
    
    print_success "$status deployment updated with image tag: $image_tag"
    print_info "Frontend configured to use backend at http://localhost:$backend_node_port"
}

# Function to show current status and provide access URLs
show_status() {
    print_header "Current Deployment Status"
    kubectl get deployments

    print_subheader "Current Services"
    kubectl get services

    print_subheader "Access URLs"
    
    local services=("b-g-backend-service-stable" "b-g-backend-service-beta" "b-g-frontend-service-stable" "b-g-frontend-service-beta" "mariadb-service")
    local names=("Stable Backend" "Beta Backend" "Stable Frontend" "Beta Frontend" "MariaDB")
    
    for i in "${!services[@]}"; do
        local port=$(kubectl get service ${services[$i]} -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        if [ -n "$port" ]; then
            print_info "${names[$i]}: http://localhost:$port"
        fi
    done
}

check_env() {
    local status=$1
    print_header "Checking environment variables for $status deployment"
    
    for deployment in "backend" "frontend"; do
        print_subheader "$deployment environment"
        kubectl exec deploy/b-g-$deployment-$status -- printenv | grep -E 'ASPNETCORE_ENVIRONMENT|Database__ConnectionString|API_URL_GREETING_ENDPOINT'
    done
}

teardown_resources() {
    local scope=$1
    
    if [ "$scope" == "all" ]; then
        print_header "Tearing down all resources"
        kubectl delete deployment,service,configmap,pvc -l app=b-g
        print_success "All resources teardown complete."
    elif [ "$scope" == "beta" ]; then
        print_header "Tearing down beta resources"
        kubectl delete deployment,service,configmap -l app=b-g,status=beta
        print_success "Beta resources teardown complete."
    else
        print_error "Invalid teardown scope. Use 'all' or 'beta'."
        show_exit_prompt
    fi
}

build_images() {
    local tag=$1
    
    if [[ ! -x "$BUILD_SCRIPT" ]]; then
        chmod +x "$BUILD_SCRIPT"
    fi

    print_header "Building Images"
    print_info "Building images with tag: $tag"
    "$BUILD_SCRIPT" true "$tag"
    print_success "Images successfully built with tag: $tag"
}

handle_deployment() {
    local deployment_type=$1
    local tag=$(generate_random_tag)
    
    build_images "$tag"
    deploy_db
    deploy "$deployment_type" "$tag"
    check_env "$deployment_type"
}

show_exit_prompt() {
    print_info "Press any key to exit..."
    read -n 1 -s -r
    exit 1
}

main() {
    case "$1" in
        deploy-db)
            deploy_db
            ;;
        deploy)
            if [ "$#" -ne 2 ] || [[ ! "$2" =~ ^(stable|beta)$ ]]; then
                print_error "Usage: $0 deploy <stable|beta>"
                show_exit_prompt
            fi
            handle_deployment "$2"
            ;;
        promote)
            print_header "Promoting Beta to Stable"
            beta_image=$(kubectl get deployment b-g-backend-beta -o jsonpath='{.spec.template.spec.containers[0].image}')
            deploy "stable" "${beta_image##*:}" # Extract tag from image
            print_success "Beta promoted to stable. New stable image tag: ${beta_image##*:}"
            check_env "stable"
            ;;
        status)
            show_status
            ;;
        teardown)
            if [ "$#" -ne 2 ] || [[ ! "$2" =~ ^(all|beta)$ ]]; then
                print_error "Usage: $0 teardown <all|beta>"
                show_exit_prompt
            fi
            teardown_resources "$2"
            ;;
        *)
            print_error "Usage: $0 {deploy-db|deploy <stable|beta>|promote|status|check-env <stable|beta>|teardown <all|beta>}"
            show_exit_prompt
            ;;
    esac

    if [[ "$1" != "teardown" && "$1" != "check-env" && "$1" != "status" ]]; then
        show_status
    fi

    print_header "Deployment Script Completed"
    show_exit_prompt
}

main "$@"