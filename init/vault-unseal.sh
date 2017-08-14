if [ $# -lt 2 ]
  then
    echo "Invalid arguments provided"
    echo "Valid usage: "`basename "$0"`" <release-name> <namespace> <flags(optional)>"
    exit 1
fi

RELEASE=$1
NAMESPACE=$2
FLAGS=${3:-""} # Primarily for -tls-skip-verify
COMPONENT="vault"
REQUIRED_KEY_COUNT=3

echo "Getting unseal keys from Kubernetes secret"
UNSEAL_KEYS=$(kubectl get secret -n $NAMESPACE $RELEASE-vault-keys -o yaml | grep -e "key[0-9]\:" | awk '{print $2}')

for i in `seq 1 $REQUIRED_KEY_COUNT`;
do
  KEY=$(echo "$UNSEAL_KEYS"  | sed "${i}q;d" | base64 --decode)
  kubectl get po -l component=$COMPONENT,release=$RELEASE -n $NAMESPACE \
      | awk '{if(NR>1)print $1}' \
      | xargs -I % kubectl exec -n $NAMESPACE -c $RELEASE-vault-$COMPONENT % -- sh -c "vault unseal $FLAGS $KEY";
done
