# Vault

This project sets up [Vault by Hashicorp](https://www.vaultproject.io/) on Kubernetes using Helm in a HA configuration.  It create its own private Consul backend and secures the Consul and Vault traffic. Also, optionally, a Consul UI and Vault UI can be enabled.

It isn't hard to [get started](https://www.vaultproject.io/intro/getting-started/install.html) with Vault. There is also [charts](https://github.com/kubernetes/charts/tree/master/stable/consul) that will get Consul running in K8S. AWS has a solution if you want to use [CloudFormation templates](https://aws.amazon.com/quickstart/architecture/vault/). Putting this all together yourself in a secure way turns out to be much harder. This projects takes on a lot of the tasks that would normally be manual. From unsealing Vault to TLS creation for client and backend communication. Also automatically backing up the Consul data to AWS S3. The default setup will create 5 Consul replicas and 3 Vault replicas.

##### Tech stack
[Vault](https://www.vaultproject.io/), [Consul](https://www.consul.io/), [K8S](https://kubernetes.io/), [Helm](https://github.com/kubernetes/helm), [AWS S3](https://aws.amazon.com/s3/), Bash, OpenSSL, [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), [Let's Encrypt](https://letsencrypt.org/docs/)

### Contents
<!-- TOC depthFrom:2 depthTo:2 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Installing Vault](#installing-vault)
- [Upgrading Vault](#upgrading-vault)
- [Testing Vault](#testing-vault)
- [Concepts (Work in progress)](#concepts-work-in-progress)
- [Security](#security)
- [Backup and recovery](#backup-and-recovery)
- [Deleting Vault](#deleting-vault)
- [Future Work](#future-work)

<!-- /TOC -->

## Installing Vault

### Prerequisites
* Kubernetes 1.5.x
* Helm 2.5.x
* LetsEncrypt Account and Route53 access (optional)
* Amazon S3 access (optiona, for backups)

### Helm Install
To install the chart with the release name `vault-prod` in namespace `vault` with the `values-prod` configuration (see [helm_charts/vault](helm_charts/vault) for values definitions):

```bash
helm install --values helm_charts/vault/values-prod.yaml --name vault-prod --namespace vault helm_charts/vault
```

It will take a minute or two for the pre-installation steps to run. Then Helm will finish installing all the necessary resources.

To check the status run `kubectl get po -l release=vault-prod,component=vault -n vault` and all pods should have a `Running` status.

> **Notes on pre-install steps**: This Helm chart has pre-install jobs that create certain Kubernetes secrets before the rest of the application get set up.  See the READMEs in [helm_charts/vault/init/preInstallConsul](helm_charts/vault/init/preInstallConsul) and [helm_charts/vault/init/preInstallVault](helm_charts/vault/init/preInstallVault) for more information on what is going on here.  If there is a failure while running the install, it could be due to the pre-install scripts failing. To look at the pre-install resources:
```
kubectl get po,jobs,cm,secrets -l 'component in (consul-preinstall,vault-preinstall),release=vault-prod' -n vault --show-all
```

### Initialize Vault
If this is a new instance of Vault, it needs to be initialized.  To do this, run

```
./init/vault-init.sh vault-prod vault
```

This script does 3 things:
* Initializes Vault
* Displays the Vault Unseal Keys and Root Token
* Saves the Vault Unseal Keys as a Kubernetes secret

> **IMPORTANT**: You must save off the Unseal Keys and Root Token as this is the only time they will be shown.  The Unseal Keys are needed unseal vault in the case of failure and the Root Token is needed to auth with Vault for admin tasks.

### Unseal Vault

If this is a new instance of Vault, it will need to be unsealed manually.  Any pod restarts in the future will auto-unseal.

To manually unseal the vault, run

```
./init/vault-unseal.sh vault-prod vault
```

## Upgrading Vault
To upgrade vault with new configuration values, run

```
helm upgrade --values=helm_charts/vault/values-prod.yaml vault-prod helm_charts/vault/
```

> **Note when upgrading**
Certain components cannot be upgraded simply with a `helm upgrade`, primarily, anything that was created with the helm pre-installation process. This includes
* Consul TLS certificates
* Consul Gossip Keys
* LetsEncrypt TLS certificates

>Also if the Consul stateful set it being modified, it must be updated with a rolling restart *-process TBD--*.

## Testing Vault

Installation Variations
* CA Variation
** Self-signed CA
** LetsEncrypt Stage CA
* UI test

Upgrade Variations
* Upgraded from last minor release

Tests
* Consul Members
* Vault Read
* Vault Write
* Auto Unseal
* Backup and Restore


## Concepts (Work in progress)
* Multiple Vaults in 1 namespace
* Letsencrypt
* Ingress Controller
* Auto Unsealing
* Readiness

## Security

With this setup, all network communication is encrypted with TLS.  See the figure below for details.
![alt text](vault-security-model.png "Security Model")

## Backup and recovery

Backups work by creating a Consul client coupled with [awscli](https://aws.amazon.com/cli/). The Consul client is configured to connect to the cluster and then `consul snapshot` is ran in a given interval "SleepDuration". This file is then uploaded to AWS S3 with the given base path "S3URL". The file is then removed and the process starts over again.

To make the restoring process easy the Helm value was created "RestoreBackupFile". With that variable set `helm install` will pull down the snapshot and apply that to the cluster. NOTE: This variable only works for install and will not work for `helm upgrade`. This is a design feature to prevent restoring on top of a working Consul cluster. The following is an example of how you could use this setting:
```bash
helm install --values=values-prod.yaml --namespace=vault --name=vault-prod --set RestoreBackupFile=consul-20170815.065601.snap vault
```

At this time AWS S3 access is a assumed with AWS Roles given to the K8S cluster nodes. Future work might be done to pull from vault the needed access for it's own backups.

## Deleting Vault

To delete the chart:
```bash
helm delete vault-prod --purge
```

Also, due to the way helm does pre-installs and the way the vault/consul secrets are generated, you'll need to clean up these extra resources by running the following command:
```bash
kubectl delete po,jobs,cm,secrets -l 'component in (consul-preinstall,vault-preinstall),release=vault-prod' -n vault
```

Lastly, the ingress controller creates a configmap that needs to be cleaned up as well.
```
kubectl delete cm ingress-controller-leader-nginx -n vault
```

## Future Work

### Cleanup
* Add Helm default vaules
* Document Helm values

### Security
* Secure Consul UI
** Access to the consul ui should be restricted via some kind of auth or, at a minimum, set to read-only

### High Availability
* Updating LetsEncrypt Certs
* Updating Consul certs via custom CA
** The Consul server/client certs, as well as the CA, will need to be rotated out periodically.  Need to figure out how to do this automatically with no downtime
* Add node affinity
** Ensure that consul and vault pods are spaced out amongst all the kubernetes nodes to ensure failure in one AZ doesn't disrupt service
