#!/bin/sh

HERITAGE=$(grep "heritage=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
RELEASE=$(grep "release=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
CHART=$(grep "chart=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
COMPONENT=$(grep "component=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
APP=$(grep "app=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')

kubectl delete secrets -l release=$RELEASE compontent=$COMPONENT

# Create k8s Secret for Consul Gossip Key
GOSSIPKEY=$(cat /dev/urandom | head -c 24 | base64; echo)
kubectl create secret generic \
  $FULL_NAME-consul-gossip-key \
  --from-literal=gossip-key=$GOSSIPKEY
kubectl label secret \
  $FULL_NAME-consul-gossip-key \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT \
  app=$APP

# Create K8s Secret for Consul Gossip Key in a json format so it can be mounted
kubectl create secret generic \
  $FULL_NAME-consul-gossip-json \
  --from-literal=encrypt.json="{\\"encrypt\\": \\"$GOSSIPKEY\\"}"
kubectl label secret \
  $FULL_NAME-consul-gossip-json \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT \
  app=$APP

# Create k8s Secret for Consul CA
kubectl create secret generic \
  $FULL_NAME-consul.ca \
  --from-file=/certs/cert/ca.crt.pem
kubectl label secret \
  $FULL_NAME-consul.ca \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT \
  app=$APP

# Create k8s Secret for Consul TLS Cert
kubectl create secret tls \
  $FULL_NAME-consul.tls \
  --cert=/certs/cert/consul.crt.pem \
  --key=/certs/private/consul.key.pem
kubectl label secret \
  $FULL_NAME-consul.tls \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT \
  app=$APP

