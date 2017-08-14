#!/bin/bash

# For testing, and "un-initing"
# kubectl exec vault-local-vault-consul-0 -n vault-local -- sh -c "consul kv delete -ca-file=/etc/consul/ca/ca.crt.pem -client-cert=/etc/consul/tls/tls.crt -client-key=/etc/consul/tls/tls.key -http-addr=https://127.0.0.1:8500 -tls-server-name=vault-local-vault-consul -recurse vault"

RELEASE_PREFIX="vault"
UNIQUE_NAME=$RELEASE_PREFIX-$GO_PIPELINE_LABEL

# Disable if doing a true test
SKIP_TLS_FLAG="-tls-skip-verify"

FIRST_VAULT_POD=$(kubectl get po -l component=vault,release=$UNIQUE_NAME -n $UNIQUE_NAME | awk '{if(NR==2)print $1}')
INIT_MESSAGE=$(kubectl exec -n $UNIQUE_NAME -c $UNIQUE_NAME-vault-vault $FIRST_VAULT_POD -- sh -c "vault init $SKIP_TLS_FLAG" 2>&1)
echo "$INIT_MESSAGE"
KEYS=$(echo "$INIT_MESSAGE" | grep "Unseal Key" | awk '{print $4}')
for i in ${KEYS[@]};
do
   kubectl get po -l component=vault -n $UNIQUE_NAME \
       | awk '{if(NR>1)print $1}' \
       | xargs -I % kubectl exec -n $UNIQUE_NAME -c $UNIQUE_NAME-vault-vault % -- sh -c "vault unseal $SKIP_TLS_FLAG $i";
done
