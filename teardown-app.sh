#!/bin/bash

kubectl delete -f ./deployments/local/frontend.yaml
kubectl delete -f ./deployments/local/backend.yaml
kubectl delete -f ./deployments/local/db.yaml