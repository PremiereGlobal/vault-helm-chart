## Helm Configuration

> **Important**: Component names should be less than 24 characters

The following tables lists the configurable parameters of the vault chart and their default values.

### Vault
| Parameter               | Description                           | Default                                                    |
| ----------------------- | ----------------------------------    | ---------------------------------------------------------- |
| `Consul.ComponentName`                  | Used for resource names and labeling               | `consul`                                                   |
| `Consul.Cpu`                   | container requested cpu               | `100m`                                                     |
| `Consul.Datacenter`         | Consul datacenter name          | `dc1`                                                     |
| `Consul.Image`                 | Container image name                  | `consul`                                                   |
| `Consul.ImageTag`              | Container image tag                   | `0.9.0`                                                   |
| `Consul.ImagePullPolicy`       | Container pull policy                 | `IfNotPresent`                                                   |
| `Consul.Memory`                | container requested memory            | `512Mi`                                                    |
| `Consul.Replicas`         | Container replicas          | `5`                                                     |
| `Consul.HttpPort`              | Consul http listening port            | `8500`                                                     |
| `Consul.SerflanPort`           | Container serf lan listening port     | `8301`                                                     |
| `Consul.SerflanUdpPort`        | Container serf lan UDP listening port | `8301`                                                     |
| `Consul.SerfwanPort`           | Container serf wan listening port     | `8302`                                                     |
| `Consul.SerfwanUdpPort`        | Container serf wan UDP listening port | `8302`                                                     |
| `Consul.ServerPort`            | Container server listening port       | `8300`                                                     |
| `Consul.ConsulDnsPort`         | Container dns listening port          | `8600`                                                     |
| `Consul.PreInstall.ComponentName`         | Used for resource names and labeling          | `consul-preinstall`                                                     |
| `Consul.PreInstall.JobDeadline`         | Timeout for Consul pre-install job (seconds)          | `30`                                                     |
| `Consul.PreInstall.Tls.CountryName`         | TLS cert country name          | ``                                                     |
| `Consul.PreInstall.Tls.LocalityName`         | TLS cert locality name          | ``                                                     |
| `Consul.PreInstall.Tls.EmailAddress`         | TLS cert email address          | ``                                                     |
| `Consul.PreInstall.Tls.OrganizationName`         | TLS cert organization name          | ``                                                     |
| `Consul.PreInstall.Tls.StateOrProvinceName`         | TLS cert state         | ``                                                     |
| `Consul.PreInstall.Tls.OrganizationUnitName`         | TLS cert organization unit name          | ``                                                     |
| `Consul.Ui.ComponentName`         | Used for resource names and labeling          | `consul-ui`                                                     |
| `Consul.Ui.Enabled`         | Enable the Consul Web UI          | `false`                                                     |
| `Consul.Ui.Host`         | Host name to respond to (for ingress)          | `localhost`                                                     |
| `Consul.Ui.AlternateServerNames`         | Alternate host names to respond to (for ingress)          | `127.0.0.1`                                                     |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml vault
```

> **Tip**: You can use the default [values.yaml](values.yaml)
