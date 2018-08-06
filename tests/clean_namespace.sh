#!/bin/bash

CLUSTER=$(kubectl config current-context)
NAMESPACE=$(kubectl config view -o json | jq -r '.contexts[] | select(.name=="'$(kubectl config current-context)'") | .context.namespace')
PODS=$(kubectl get po -n ${NAMESPACE} -l app=vault -o json | jq -r .items[].metadata.name)
JOBS=$(kubectl get jobs -n ${NAMESPACE} -l app=vault -o json | jq -r .items[].metadata.name)
SECRETS=$(kubectl get secrets -n ${NAMESPACE} -l app=vault -o json | jq -r .items[].metadata.name)
echo "Deleting the following resources on cluster ${CLUSTER} in namespace ${NAMESPACE}"
echo "Pods:" 
echo ${PODS}
echo "Jobs:"
echo ${JOBS}
echo "Secrets:"
echo ${SECRETS}
read -r -p "Continue? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
  echo $PODS | xargs kubectl delete po
  echo $JOBS | xargs kubectl delete job
  echo $SECRETS | xargs kubectl delete secrets
fi
