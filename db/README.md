# Steps


1. `kubectl apply -f mariadb-deployment.yaml`
2. `kubectl get pods`
3. `kubectl exec -it <REPLACE_WITH_POD_NAME. E.g. mariadb-deployment-XXXXX> -- /bin/sh`
4. `mysql -u root -p` 
    If received `/bin/sh: 1: mysql: not found`
    3a. `apt-get update`
    3b. `apt-get install mysql-client`
        - Enter `y` on `Do you want to continue? [Y/n]`
    3c. `mysql -u root -p`
5. Enter `password` on `Enter password:`
    4a. If failed, try again starting at step 3.
6. `SELECT NOW();`
7. `SHOW DATABASES;`