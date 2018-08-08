#!/bin/bash

BRANCH=${1-"master"}
NAMESPACE=${2-"vault-test"}
rm -rf .chart
mkdir -p .chart
git clone git@github.com:ReadyTalk/vault-helm-chart.git .chart

# ./clean_namespace.sh ${NAMESPACE}

helm upgrade --install \
  --namespace ${NAMESPACE} \
  vault-test \
  .chart/helm_charts/vault
