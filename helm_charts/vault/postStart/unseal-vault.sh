#!/bin/sh

# Three scenarios
# * Vault is not running yet
# ** Just wait...
# * Vault is running but not initialized
# ** Exit, it needs to be initialized and unsealed manually
# * Vault is running and initialized but sealed
# ** Take action and unseal the vault, then exit
# * Vault is running, initialized and unsealed
# ** all is good, exit

COUNT=1
LIMIT=30
while [ 1 ]
do
  echo "Checking if Vault is up and running (try $COUNT)..." &> /proc/1/fd/1
  VAULT_STATUS=$(vault status $1 2>&1)
  EXIT_STATUS=$?
  if echo "$VAULT_STATUS" | grep "server is not yet initialized"; then
    echo "Vault not initialized.  Must be manually unsealed. Exiting..." &> /proc/1/fd/1
    exit 0
  elif [ $EXIT_STATUS -eq 2 ]; then
    echo "Vault Sealed.  Unsealing..." &> /proc/1/fd/1
    for i in `seq 1 3`
    do
      vault operator unseal $1 $(cat /etc/vault/keys/key$i) &> /proc/1/fd/1
    done
    exit 0
  elif [ $COUNT -ge $LIMIT ]; then
    # Dont know what happened... Exiting
    echo "$VAULT_STAUS" &> /proc/1/fd/1
    exit 1
  else
    # For debugging
    echo "$VAULT_STATUS" &> /proc/1/fd/1
    ps aux &> /proc/1/fd/1
  fi
  COUNT=$((COUNT+1))
  sleep 1
done
