# Kubernetes Secrets used by Vault

Five secrets must be created to spin up a new vault instance
1. `gossip-key` which Consul uses to encrypt gossip communications
1. `vault-consul.ca` which contains a PEM-encoded CA cert to use to verify the Vault server SSL certificate
1. `vault-consul.tls` which contains a PEM-encoded client certificate for TLS authentication to the Vault server along with an unencrypted PEM-encoded private key matching the client certificate
1. `vault.ca` which contains a PEM-encoded CA cert to use to verify the Vault server SSL certificate
1. `vault.tls` which contains a PEM-encoded client certificate for TLS authentication to the Vault server along with an unencrypted PEM-encoded private key matching the client certificate

### Create/Update Vault Secrets

1. Generate new CA and Consul certs
  1. TBD - Ryan Wilcox
1. Ensure the following files are in the `certs/` directory and are up to date
  1. `consul.ca` - Consul CA Cert
  1. `consul.crt` - Consul TLS Cert
  1. `consul.key` - Consul TLS Private Key
  1. `vault.ca` - Vault CA Cert
  1. `vault.crt` - Vault TLS Cert
  1. `vault.key` - Vault TLS Private Key
1. Run the following to replace all consul/vault K8S secrets
```
./apply.sh <vault_cluster_name> <namespace>
```
Add a `true` parameter at the end if you also want to create/replace the Consul gossip key with a new auto-generated one.  **-*WARNING*-** replacing the gossip key should not be done on a running cluster as it may cause inconsistent keys between Consul nodes. This should only be done when creating or completely destroying/re-creating a Vault cluster.
```
./apply.sh <vault_cluster_name> <namespace> true
```
