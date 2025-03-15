# Wireguard

https://www.procustodibus.com/blog/2021/02/wireguard-with-aws-private-subnets/

## Example

```toml
[Interface]
# Name = office1.mydomain.org
PrivateKey = ......
Address = 10.82.85.1/24
ListenPort = 19628

[Peer]
# Name = office2.mydomain.org
PublicKey = ...
AllowedIPs = 10.82.85.2/32, 192.168.200.0/24
PersistentKeepalive = 60
```

`AllowedIPs` does two things:

- It adds a route to the given networks, i.e. packets addressed to 10.82.85.2/32 or to 192.168.200.0/24 will be routed through the WireGuard interface to that peer
- It will allow packets with the source IPs 10.82.85.2/32 or 192.168.200.0/24 to be routed from the given peer on the
  WireGuard interface.

Note especially the second point. Any packet from the given peer with a source IP address which is not listed in AllowedIPs **will be discarded!**While this does not replace a firewall, it serves a an integral part of Wireguard’s security model.