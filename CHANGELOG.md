# v0.1.1

## Changelog since v0.1.0

### Action Required

* ACTION REQUIRED: In-place upgrades from chart 0.1.0 will require migrating consul data to the new statefulset contained in this release (updated labels to stay with the current Helm way of doing things).  Ensure your Vault/Consul data is backed up before attempting is as it destroy your Consul cluster if not done right.  It may be easier to do a fresh install + restore if possible.

###
* Remove Consul UI options (in an effort to migrate to the official Consul helm chart)
