#!/bin/sh

# Generate a unique name for this build
RELEASE_PREFIX="vault"
UNIQUE_NAME=$RELEASE_PREFIX-$GO_PIPELINE_LABEL

echo "Deleting namespace: $UNIQUE_NAME..."
kubectl delete namespace $UNIQUE_NAME

echo "Deleting helm installation: $UNIQUE_NAME..."
helm delete $UNIQUE_NAME --purge

echo "Waiting for cleanup to finish in Kubernetes..."
COUNT=1
while true
do
  kubectl get namespace $UNIQUE_NAME &>/dev/null
  if [ $? -eq 1 ]; then
    echo "All clean!..."
    break
  elif [ $COUNT -gt 300 ]; then
    echo "Timeout exit (try $COUNT)..."
    exit 1
  else
    echo "Waiting for cleanup to finish (try $COUNT)..."
  fi

  COUNT=$((COUNT+1))
  sleep 1
done
