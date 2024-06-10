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