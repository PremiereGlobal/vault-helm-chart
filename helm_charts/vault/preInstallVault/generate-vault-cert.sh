#!/bin/bash

# Join string by characters
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

IFS=',' read -ra NAMES <<< "$VAULT_TLS_ALT_SERVER_NAMES"
ALT_NAME_STRING=$(join_by '","' "${NAMES[@]}")
if [ -n "$ALT_NAME_STRING" ]; then
  ALT_NAME_STRING=',"'$ALT_NAME_STRING'"'
fi

if [ "$ACME_ENVIRONMENT" == "production" ]; then
  ACME_DIRECTORY_URL="https://acme-v01.api.letsencrypt.org/directory"
else
  ACME_DIRECTORY_URL="https://acme-staging.api.letsencrypt.org/directory"
fi

export LETSENCRYPT_AWS_CONFIG='{"acme_account_key": "'$ACME_ACCOUNT_KEY'","acme_directory_url": "'$ACME_DIRECTORY_URL'","domains": [{ "hosts": ["'$VAULT_TLS_SERVER_NAME'"'$ALT_NAME_STRING'],"key_type": "rsa" }]}'
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
export AWS_DEFAULT_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
mkdir -p /certs
.venv/bin/python letsencrypt-aws.py update-certificates
