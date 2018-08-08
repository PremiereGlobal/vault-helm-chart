# v0.1.2 (Beta)

### Action Required

* ACTION REQUIRED: In-place upgrades from chart 0.1.0 will require migrating consul data to the new statefulset contained in this release (updated labels to stay with the current Helm way of doing things).  Ensure your Vault/Consul data is backed up before attempting is as it destroy your Consul cluster if not done right.  It may be easier to do a fresh install + restore if possible.

# v0.1.1

## Changelog since v0.1.0

### Major Updates
* Removed third party UI in favor of the build-in OSS UI
* Fixed many issues that occured in more recent Kubernetes releases

### Notable Issues Fixed
* [#14](https://github.com/ReadyTalk/vault-helm-chart/issues/14) Separated restore job so that it wouldn't run on each restart of the backup pod
* [#17](https://github.com/ReadyTalk/vault-helm-chart/issues/17) Added HostAlias value options
* [#18](https://github.com/ReadyTalk/vault-helm-chart/issues/18) Added NodePort value options
* [#20](https://github.com/ReadyTalk/vault-helm-chart/issues/20) Upgraded default Vault version to 0.9.5
* [#22](https://github.com/ReadyTalk/vault-helm-chart/issues/22) Added option to use your own custom TLS certificate
* [#38](https://github.com/ReadyTalk/vault-helm-chart/issues/38) Remove Consul UI options (in an effort to migrate to the official Consul helm chart)
* [#36](https://github.com/ReadyTalk/vault-helm-chart/issues/36) Removed third party UI in favor of the build-in OSS UI
* [#39](https://github.com/ReadyTalk/vault-helm-chart/issues/39) Removed option to enable the Consul UI
* [#43](https://github.com/ReadyTalk/vault-helm-chart/issues/43) Fixed ConfigMap read-only issue for Consul
