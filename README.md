# blue-green-deployment

# Local Kubernetes Deployment
# Step By Step Manual Deployment
To deploy services in your local Kubernetes environment, execute the following steps from the project root:

1. Apply the MariaDB Kubernetes configuration:
    ```
    kubectl apply -f ./deployments/local/db.yaml
    ```

2. Build and tag the Frontend and Backend Docker images:
    ```
    .\build-images.sh
    ```
    >Ensure that the output shows `Build and tag completed`.

3. Deploy the backend:
    ```
    kubectl apply -f ./deployments/local/backend.yaml
    ```

4. Deploy the frontend:
    ```
    kubectl apply -f ./deployments/local/frontend.yaml
    ```

5. Verify the deployments:

    ```
    kubectl get deployments
    ```
    > You should see:
    > - `b-g-backend    1/1     1`
    > - `b-g-frontend   1/1     1`
    > - `b-g-mariadb    1/1     1`

## Local Kubernetes Deployment Verification
Check the API deployment: `curl http://localhost:30001/greeting`  
Access the full application: `http://localhost:30002`

## Local Kubernetes Cleanup
Run the following commands to dispose of created services: 

1. Delete the MariaDB deployment:
    ```
    kubectl delete -f ./deployments/local/db.yaml
    ```
2. Delete the backend deployment:
    ``` 
    kubectl delete -f ./deployments/local/backend.yaml
    ```
3. Delete the frontend deployment:
    ```
    kubectl delete -f ./deployments/local/frontend.yaml
    ```

# Automated Script Deployment
1. Run the deployment script:
   ```
   .\deploy-app.sh
   ```
   
   This script performs the following steps:
   > Builds `b-g-backend` and `b-g-frontend` Docker images with a random tag.  
   > Deploys MariaDB.  
   > Deploys the `b-g-backend` to Kubernetes with the random tag.  
   > Deploys the `b-g-frontend` to Kubernetes with the random tag.  
   > Displays the deployment status of all components.  

    after deployment, You should see:
    > - `b-g-backend    1/1     1`
    > - `b-g-frontend   1/1     1`
    > - `b-g-mariadb    1/1     1`

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


# Steps for MariaDB Deployment in Kubernetes

## Deploy MariaDB
```sh
kubectl apply -f mariadb-deployment.yaml
```

# Remove Deployment Resource
```sh
kubectl delete -f mariadb-deployment.yaml
```

## Local Database Connection
For instructions on how to connect to the MariaDB database locally, please refer to the `check-db.sh` script. This script includes the necessary commands and steps for establishing a local connection.

## Verify Deployment (Easy Method)
Run the provided script to check the database status:
```sh
./check-db.sh
```

## Verify Deployment (Detailed Method)
Follow these steps for a detailed verification process:

1. Check the pod status:
    ```sh
    kubectl get pods  # Wait until STATUS becomes Running otherwise investigate and troubleshoot.
    ```
2. Access the MariaDB pod:
    ```sh
    kubectl exec -it <REPLACE_WITH_POD_NAME> -- bash
    ```
    
    >Example: 
    >`kubectl exec -it mariadb-deployment-XXXXX -- bash`

3. Try to connect to MariaDB: 
    ```
    mysql -u root -p
    ```
    >If you receive an error similar to following: `/bin/sh: 1: mysql: not found`, install the MySQL client:
    >
    >```sh
    >apt-get update
    >apt-get install mysql-client
    >```
    > Enter `y` when prompted: "Do you want to continue? [Y/n]"
    >
    > Run the following again:
    >```sh
    >mysql -u root -p
    >```

4. Enter the password when prompted:
    ```
    Enter password: password
    ```
    
    >If the password fails, retry from step 3.

5. Run SQL commands to test the connection:
    ```sh
    SELECT NOW(); # Should return the current server timestamp
    ```

    ```sh
    SHOW DATABASEs; # Lists all databases
    ```