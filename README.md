# blue-green-deployment

# Local Kubernetes Deployment
To deploy services in your local Kubernetes environment, execute the following steps from the project root:
1. Apply the MariaDB Kubernetes configuration:
    ```
    kubectl apply -f ./db/mariadb-deployment.yaml
    ```

2. Build and tag the Docker image:
    ```
    ./build-image.sh
    ```
    >Ensure that the output shows `Build and tag completed`.

3. Deploy the web application:
    ```
    kubectl apply -f ./k8s-local/local-webapp-deployment.yaml
    ```

3. Build and tag the Docker image for frontend:
    ```
    cd /src/frontend
    ./build-image.sh
    ```
    >Ensure that the output show `Build and tag completed`.

4. Deploy the frontend:
    ```
    kubectl apply -f ./k8s-local/local-frontend-deployment.yaml
    ```

5. Verify the deployments:

    ```
    kubectl get deployments
    ```
    > You should see:
    > - `mariadb-deployment`
    > - `simple-frontend`
    > - `simple-webapp`

## Local Kubernetes Deployment Verification
Confirm the API deployment by running: `curl http://localhost:30001/greeting`
Access the full application integration at: `http://localhost:30002`

## Local Kubernetes Cleanup
Run the following commands to dispose of created services: 
1. Delete the MariaDB deployment:
    ```
    kubectl delete -f .\db\mariadb-deployment.yaml
    ```
2. Delete the web application deployment:
    ``` 
    kubectl delete -f .\k8s-local\local-webapp-deployment.yaml
    ```
3. Delete the frontend deployment:
    ```
    kubectl delete -f .\k8s-local\local-frontend-deployment.yaml
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
