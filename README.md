# blue-green-deployment

# Local Kubernetes Deployment
# Step By Step Manual Deployment
To deploy services in your local Kubernetes environment, execute the following steps from the project root:
1. Apply the MariaDB Kubernetes configuration:
    ```
    kubectl apply -f ./db/mariadb-deployment.yaml
    ```

2. Build and tag the Frontend and Backend Docker images:
    ```
    .\build-images.sh
    ```
    >Ensure that the output shows `Build and tag completed`.

3. Deploy the backend:
    ```
    kubectl apply -f ./k8s-local/local-backend-deployment.yaml
    ```

4. Deploy the frontend:
    ```
    kubectl apply -f ./k8s-local/local-frontend-deployment.yaml
    ```

5. Verify the deployments:

    ```
    kubectl get deployments
    ```
    > You should see:
    > - `backend`
    > - `frontend`
    > - `mariadb`

## Local Kubernetes Deployment Verification
Ckeck the API deployment: `curl http://localhost:30001/greeting`  
Access the full application: `http://localhost:30002`

## Local Kubernetes Cleanup
Run the following commands to dispose of created services: 
1. Delete the MariaDB deployment:
    ```
    kubectl delete -f ./db/mariadb-deployment.yaml
    ```
2. Delete the backend deployment:
    ``` 
    kubectl delete -f ./k8s-local/local-backend-deployment.yaml
    ```
3. Delete the frontend deployment:
    ```
    kubectl delete -f ./k8s-local/local-frontend-deployment.yaml
    ```

# Automated Script Deployment
1. Run the eployment script:
   ```
   .\deploy-app.sh
   ```
   
   This script performs the following steps:
   > Builds `backend` and `frontend` Docker images with a random tag.  
   > Deploys MariaDB.  
   > Deploys the `backend` to Kubernetes with the random tag.  
   > Deploys the `frontend` to Kubernetes with the random tag.  
   > Displays the deployment status of all components.  

   after deployment, you should see:
   > - `backend`
   > - `frontend`
   > - `mariadb`  

## Local Kubernetes Deployment Verification
Check the API deployment: `curl http://localhost:30001/greeting`  
Access the full application: `http://localhost:30002`  

# Undeploy all
1. Clean up Kubernetes by running:
    ```
    .\teardown-app.sh
    ```

# K8s Terraform Deployment (DELETE)
To deploy the infrastructure using Terraform, execute the following steps from the project root:
1. `cd k8s-terraform`
2. `terraform init`
3. `terraform apply`

## K8s Terraform Verification
Run the following command to validate api deployment: `curl http://localhost`

## Cleanup
Run the following command to dispose of created services: `terraform destroy`
