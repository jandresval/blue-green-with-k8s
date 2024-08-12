# Blue-Green Deployment

The `deploy-manager.sh` script automates the blue-green deployment process for your Kubernetes application.

## Main Workflow

### 1. Deploy Stable Environment

```
./deploy-manager.sh deploy stable
```

This command:
- Builds Docker images with a random tag
- Deploys the MariaDB database
- Deploys the backend and frontend to Kubernetes in the stable environment

### 2. Deploy Beta Environment

```
./deploy-manager.sh deploy beta
```

Similar to deploying stable, but creates a separate beta environment.

### 3. Promote Beta to Stable

```
./deploy-manager.sh promote
```

Promotes the current beta deployment to stable.

### 4. Teardown Resources

```
./deploy-manager.sh teardown all
```

Removes all deployed resources (use `beta` instead of `all` to remove only beta resources).

## Deployment Verification

- **API Check:** Open `http://localhost:<backend-port>/greeting` to verify the API.
- **Application Access:** Open `http://localhost:<frontend-port>` to access the full application.

Note: The actual ports will be displayed in the script output after deployment.

## Additional Features and Commands

- **Deploy Database Only:**
  ```
  ./deploy-manager.sh deploy-db
  ```
  Deploys only the MariaDB database.

- **Check Deployment Status:**
  ```
  ./deploy-manager.sh status
  ```
  Displays current status of all deployments, services, and access URLs.

- **Color-coded output** for easy reading and error identification.
- **Detailed error messages** and deployment information for troubleshooting.
- **Automatic image tagging** for version control.
- **Environment variable inspection** for both stable and beta deployments (performed during deployment).

## Deployment Process Details

The deployment process includes:
- Building backend and frontend Docker images with a random tag.
- Deploying the MariaDB database.
- Deploying the backend to Kubernetes with the generated tag.
- Deploying the frontend to Kubernetes with the generated tag.
- Displaying the deployment status of all components.

## Manual Deployment and Management

If you prefer step-by-step manual deployment, refer to the following section:

### Step-By-Step Manual Deployment

Follow these steps from your project root to deploy services locally:

1. **Deploy the Database (MariaDB):**
    - Applies the MariaDB configuration.

    ```
    kubectl apply -f ./deployments/local/db.yaml
    ```

2. **Build and Tag Images:**
    - Builds and tags frontend and backend Docker images. Confirm with: "Build and tag completed." Also, ensure there are no errors, which will appear in RED.

    ```
    .\build-images.sh
    ```

3. **Deploy the Backend:**  

    ```
    kubectl apply -f ./deployments/local/backend.yaml
    ```

4. **Deploy the Frontend:**
    ```
    kubectl apply -f ./deployments/local/frontend.yaml
    ```

5. **Verify Deployments:**
    - Checks deployment status. Expect all services to show as `1/1 READY`.

    ```
    kubectl get deployments
    ```
    
    - You should see:

        | NAME         | READY | UP-TO-DATE | AVAILABLE |
        |--------------|-------|------------|-----------|
        | b-g-backend  | 1/1   | 1          | 1         |
        | b-g-frontend | 1/1   | 1          | 1         |
        | b-g-mariadb  | 1/1   | 1          | 1         |

## Cleanup
To remove services, execute:

1. **Delete the Database (MariaDB) deployment:**
    ```
    kubectl delete -f ./deployments/local/db.yaml
    ```
2. **Delete the Backend deployment:**
    ``` 
    kubectl delete -f ./deployments/local/backend.yaml
    ```
3. **Delete the Frontend deployment:**
    ```
    kubectl delete -f ./deployments/local/frontend.yaml
    ```

# Database Connection

## Local Connection Guide

For local connection instructions to MariaDB, see [./deployments/db-verification.sh](./deployments/db-verification.sh).

### Quick Verification

1. **Database Status Check:**

    ```sh
    ./check-db.sh
    ```

### Detailed Verification
Follow these steps for a detailed verification process:

1. **Check Pod Status:**

    ```sh
    kubectl get pods  # Wait until STATUS becomes Running otherwise investigate and troubleshoot.
    ```
2. **Access Pod:**
    
    ```sh
    kubectl exec -it <REPLACE_WITH_POD_NAME> -- bash
    ```
    
    >Example: 
    >`kubectl exec -it mariadb-deployment-XXXXX -- bash`

3. **MySQL Connection:** 
    
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

4. **Password Prompt:**
    
    ```
    Enter password: password
    ```
    
    >If the password fails, retry from step 3.

5. **Test Commands:**
    
    ```sh
    SELECT NOW(); # Should return the current server timestamp
    ```

    ```sh
    SHOW DATABASEs; # Lists all databases
    ```