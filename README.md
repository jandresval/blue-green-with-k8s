# blue-green-deployment

# K8s Terraform
To deploy, run the following commands from the project root:
1. `cd k8s-terraform`
2. `terraform init`
3. `terraform apply`

# Deployment Verification
Run the following command to validate api deployment: `curl http://localhost`

## Cleanup
Run the following command to dispose of created services: `terraform destroy`

# k8s Local
To deploy, run the following commands from the project root:
- `cd k8s-local`
- `kubectl apply -f .\deployment.yml`
- `kubectl get deployments` OR `kubectl describe deployment simple-webapp` to validate deployment creation.
- `kubectl apply -f .\service.yml`

# Deployment Verification
Run the following command to validate api deployment: `curl http://localhost`

## Cleanup
Run the following commands to dispose of created services: 
1. `kubectl delete service/simple-webapp`
2. `kubectl delete deployment/simple-webapp`