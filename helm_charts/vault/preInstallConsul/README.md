# Kubernetes Secrets used by Consul

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Overview](#overview)
- [Testing TLS](#testing-tls)
	- [Install openssl](#install-openssl)
	- [Test the TLS connection without a client cert](#test-the-tls-connection-without-a-client-cert)
	- [Test the client cert](#test-the-client-cert)

<!-- /TOC -->


## Overview
Consul uses [two forms of encryption](https://www.consul.io/docs/agent/encryption.html) which require secrets; Gossip Encryption and RPC Encryption.  These secrets are automatically created via a Kubernetes Job during the the Helm preInstall process.

Three secrets are created for Consul:
* `consul-gossip-key` contains the encryption key for the gossip protocol
* `consul.ca` contains the self-signed CA cert
* `consul.tls` contains a certificate signed by the CA that is used for client-server RPC communication between Consul agents.

The Kubernetes secret names are prefixed by the Helm release name and chart name.

### Gossip Encryption
`consul-gossip-key` is created by simply generating a random 24-byte string.

### RPC Encryption


## Consul RPC TLS Certificate


## Testing TLS

To make sure the ports that can be accessed with only clients that have a trusted signed cert the following are notes to verify this case.

### Install openssl
```bash
apk update
apk add openssl
```

### Test the TLS connection without a client cert

```bash
openssl s_client -connect 127.0.0.1:8500 -CAfile /etc/consul/ca/ca.crt.pem
```

You will see the following:
```bash
---
SSL handshake has read 1763 bytes and written 138 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-GCM-SHA384
    Session-ID:
    Session-ID-ctx:
    Master-Key: 15B3B6D02423D33B329824EF3B5C3493FFD697EA1CC8727968D501EAA59CD5B6DD63119AF3A529F489716617DA9D4DD7
    Key-Arg   : None
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1501618926
    Timeout   : 300 (sec)
    Verify return code: 0 (ok)
---
```

### Test the client cert

```bash
openssl s_client -connect 127.0.0.1:8500 -CAfile /etc/consul/ca/ca.crt.pem -cert /etc/consul/tls/tls.crt -key /etc/consul/tls/tls.key
```

When you use a working client cert you will see the following

```bash
    Start Time: 1501620123
    Timeout   : 300 (sec)
    Verify return code: 0 (ok)
---

HTTP/1.1 400 Bad Request
Content-Type: text/plain; charset=utf-8
Connection: close

400 Bad Requestclosed
```

Note there is alot more info passed to your screen. You will also see some http communication as well. This shows that with a good signed client cert you will get further in the client server exchange.
