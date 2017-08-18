#!/bin/bash

# Generate a unique name for this build
RELEASE_PREFIX="vault"
UNIQUE_NAME=$RELEASE_PREFIX-$GO_PIPELINE_LABEL

echo "Creating namespace: $UNIQUE_NAME..."
kubectl create namespace $UNIQUE_NAME
kubectl label namespace $UNIQUE_NAME \
  trigger=$GO_TRIGGER_USER \
  pipeline=$GO_PIPELINE_NAME \
  stage-name=$GO_STAGE_NAME \
  job-name=$GO_JOB_NAME \
  branch-name=$BRANCH_NAME

echo "Installing vault: $UNIQUE_NAME..."
helm install \
  --name $UNIQUE_NAME \
  --namespace $UNIQUE_NAME \
  ./helm_charts/vault

# Wait for Consul to come up ready
CONSUL_NUM_REPLICAS=$(kubectl get statefulset -l component=consul -n $UNIQUE_NAME -o json | jq .items[].spec.replicas)
echo "Waiting for $CONSUL_NUM_DESIRED_PODS Consul pods to be ready..."
COUNT=1
while true
do
  CONSUL_CONTAINERS_RUNNING=$(kubectl get po -l component=consul -n $UNIQUE_NAME -o json | jq '.items[].status.containerStatuses[].state | has("running")' | grep -c "true")
  CONSUL_CONTAINERS_READY=$(kubectl get po -l component=consul -n $UNIQUE_NAME -o json | jq .items[].status.containerStatuses[].ready | grep -c "true")
  if [[ $CONSUL_CONTAINERS_RUNNING -eq $CONSUL_NUM_REPLICAS && $CONSUL_CONTAINERS_READY -eq $CONSUL_NUM_REPLICAS ]]; then
    echo "Consul is ready!"
    break
  elif [[ $COUNT -gt 60 ]]; then
    echo "Consul did not come up in time!"
    exit 1
  else
    echo "Waiting ($CONSUL_CONTAINERS_RUNNING/$CONSUL_NUM_REPLICAS running; $CONSUL_CONTAINERS_READY/$CONSUL_NUM_REPLICAS ready)..."
  fi

  COUNT=$((COUNT+1))
  sleep 1
done

# Wait for Vault pod to come up ready (3 pods running, 3 containers ready, 3 containers not ready)
VAULT_NUM_REPLICAS=$(kubectl get deployment -l component=vault -n $UNIQUE_NAME -o json | jq .items[].spec.replicas)
VAULT_NUM_CONTAINERS=$(($VAULT_NUM_REPLICAS * 2))
echo "Waiting for $VAULT_NUM_DESIRED_PODS Vault pods to be ready..."
COUNT=1
while true
do
  VAULT_CONTAINERS_RUNNING=$(kubectl get po -l component=vault -n $UNIQUE_NAME -o json | jq '.items[].status.containerStatuses[].state | has("running")' | grep -c "true")
  VAULT_CONTAINERS_READY=$(kubectl get po -l component=vault -n $UNIQUE_NAME -o json | jq .items[].status.containerStatuses[].ready | grep -c "true")
  if [[ $VAULT_CONTAINERS_RUNNING -eq $VAULT_NUM_CONTAINERS && $VAULT_CONTAINERS_READY -eq $VAULT_NUM_REPLICAS ]]; then
    echo "Vault is ready!"
    break
  elif [[ $COUNT -gt 60 ]]; then
    echo "Vault did not come up in time!"
    exit 1
  else
    echo "Waiting ($VAULT_CONTAINERS_RUNNING/$VAULT_NUM_CONTAINERS running; $VAULT_CONTAINERS_READY/$VAULT_NUM_CONTAINERS ready)..."
  fi

  COUNT=$((COUNT+1))
  sleep 1
done
