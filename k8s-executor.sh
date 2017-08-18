#!/bin/bash

# KOPS_NAME and KOPS_STATE_STORE need to be set

# Env variables from GOCD or defaulted for local builds
GO_TRIGGER_USER="${GO_TRIGGER_USER:-"local"}"
GO_PIPELINE_LABEL="${GO_PIPELINE_LABEL:-local}"
GO_PIPELINE_NAME="${GO_PIPELINE_NAME:-"local"}"
GO_STAGE_NAME="${GO_STAGE_NAME:-"local"}"
GO_JOB_NAME="${GO_JOB_NAME:-"local"}"
BRANCH_NAME="${GO_SCM_GITBRANCHES_CURRENT_BRANCH:-"local"}"
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# If running locally, use user's kubeconfig
KUBE_CONFIG_MOUNT=""
KUBE_CONFIG_EXPORT_COMMAND="true"
if [ "$GO_TRIGGER_USER" == "local" ]; then
  echo "Loading kube config from local env..."
  KUBE_CONFIG_MOUNT="-v ${HOME}/.kube:/root/.kube"
else
  echo "Loading kube config from AWS..."
  KUBE_CONFIG_EXPORT_COMMAND="kops export kubecfg --name $KOPS_NAME"
fi

echo "Deploying Application w/ Helm..."
docker pull bartlettc/docker-kubectl
docker run \
  --rm \
  -e "KOPS_STATE_STORE=$KOPS_STATE_STORE" \
  -e "KOPS_NAME=$KOPS_NAME" \
  -e "GO_PIPELINE_LABEL=$GO_PIPELINE_LABEL" \
  -e "GO_TRIGGER_USER=$GO_TRIGGER_USER" \
  -e "GO_PIPELINE_NAME=$GO_PIPELINE_NAME" \
  -e "GO_STAGE_NAME=$GO_STAGE_NAME" \
  -e "GO_JOB_NAME=$GO_JOB_NAME" \
  -e "BRANCH_NAME=$BRANCH_NAME" \
  $KUBE_CONFIG_MOUNT \
  -v $SOURCE_DIR:/workdir \
  -w /workdir \
  bartlettc/docker-kubectl \
  bash -c "$KUBE_CONFIG_EXPORT_COMMAND && $@"
