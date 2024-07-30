#!/bin/bash

kubectl delete -f ./k8s-local/local-frontend-deployment.yaml
kubectl delete -f ./k8s-local/local-backend-deployment.yaml
kubectl delete -f ./db/mariadb-deployment.yaml