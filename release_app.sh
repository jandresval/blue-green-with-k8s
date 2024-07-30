#!/bin/bash

# build images
if ! [[ -x "build-images.sh" ]]; then
    chmod +x build-images.sh
fi

array=()
for i in {a..z}; 
   do
   array[$RANDOM]=$i
done
RANDOMTAG=$(printf %s ${array[@]::8} $'\n')

./build-images.sh true $RANDOMTAG

# add DB
kubectl apply -f ./db/mariadb-deployment.yaml

# release backend
template=`cat "./k8s-local/local-backend-deployment.yaml.template" | sed "s/{{TAG}}/$RANDOMTAG/g"`
echo "$template" | kubectl apply -f -
#kubectl apply -f ./k8s-local/local-backend-deployment.yaml

#release frontend
template=`cat "./k8s-local/local-frontend-deployment.yaml.template" | sed "s/{{TAG}}/$RANDOMTAG/g"`
echo "$template" | kubectl apply -f -
#kubectl apply -f ./k8s-local/local-frontend-deployment.yaml

#check release
#kubectl get deployments