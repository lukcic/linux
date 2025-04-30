# Wireguard

https://www.procustodibus.com/blog/2021/02/wireguard-with-aws-private-subnets/

https://docs.github.com/en/actions/using-github-hosted-runners/connecting-to-a-private-network/using-wireguard-to-create-a-network-overlay

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

Note especially the second point. Any packet from the given peer with a source IP address which is not listed in
AllowedIPs **will be discarded!**While this does not replace a firewall, it serves a an integral part of Wireguard’s
security model. 

## Script

```sh
Install WireGuard via whatever package manager you use.  For me, I use apt.

$ sudo add-apt-repository ppa:wireguard/wireguard
$ sudo apt-get update
$ sudo apt-get install wireguard

MacOS
$ brew install wireguard-tools

Generate key your key pairs.  The key pairs are just that, key pairs.  They can be
generated on any device, as long as you keep the private key on the source and 
place the public on the destination.  

$ wg genkey | tee privatekey | wg pubkey > publickey
example privatekey - mNb7OIIXTdgW4khM7OFlzJ+UPs7lmcWHV7xjPgakMkQ=
example publickey - 0qRWfQ2ihXSgzUbmHXQ70xOxDd7sZlgjqGSPA9PFuHg=

One can also generate a preshared key to add an additional layer of symmetric-key cryptography to be mixed into the already existing public-key cryptography, for post-quantum resistance.

# wg genpsk > preshared

Take the above private key, and place it in the server.  And conversely, put the 
public key on the peer.  Generate a second key pair, and do the opposite, put the
public on the server and the private on the peer.  Put the preshared key in the client config if you choose to use it.

On the server, create a conf file - /etc/wireguard/wg0.conf (These are examples,
so use whatever IP ranges and CIDR blocks that will work for your network.
################################
[Interface]
Address = 10.0.0.1/24
DNS = 1.1.1.1
PrivateKey = [ServerPrivateKey]
ListenPort = 51820
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o enp9s0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o enp9s0 -j MASQUERADE

[Peer]
#Peer #1
PublicKey = [Peer#1PublicKey]
AllowedIPs = 10.0.0.3/32

[Peer]
#Peer #2
PublicKey = [Peer#2PublicKey]
AllowedIPs = 10.0.0.10/32

[Peer]
#Peer #3
PublicKey = [Peer#3PublicKey]
AllowedIPs = 10.0.0.2/32

[Peer]
#Peer #4
PublicKey = [Peer#4PublicKey] 
AllowedIPs = 10.0.0.11/32
##################################

On each client, define a /etc/wireguard/mobile_user.conf - 

###################################
[Interface]
Address = 10.0.0.3/24
PrivateKey = [PrivateKeyPeer#1]

[Peer]
PublicKey = [ServerPublicKey]
PresharedKey = [PresharedKey]
Endpoint = some.domain.com:51820
AllowedIPs = 0.0.0.0/0, ::/0 
# if you want to do split tunnel, add your allowed IPs
# for example if your home network is 192.168.1.0/24
# AllowedIPs = 192.168.1.0/24

# This is for if you're behind a NAT and
# want the connection to be kept alive.
PersistentKeepalive = 25
########################################

sudo wg show
#########################################
peer: Peer #1
  endpoint: 192.168.2.1:50074
  allowed ips: 10.0.0.2/32
  latest handshake: 4 minutes, 16 seconds ago
  transfer: 57.58 KiB received, 113.32 KiB sent

peer: Peer #2
  endpoint: 99.203.28.43:36770
  allowed ips: 10.0.0.10/32
  latest handshake: 5 minutes, 30 seconds ago
  transfer: 92.98 KiB received, 495.89 KiB sent
##################################################
  
Start/stop interface  
wg-quick up wg0
wg-quick down wg0

Start/stop service  
$ sudo systemctl stop wg-quick@wg0.service
$ sudo systemctl start wg-quick@wg0.service

Instead of having to modify the file for every client you want to add to the 
server you could also use the wg tool instead:

# add peer
wg set wg0 peer <client_pubkey> allowed-ips 10.0.0.x/32

# verify connection
wg

# save to config
wg-quick save wg0

######### EDIT ##############

I was setting up a relative with a Wireguard config, and figured I might as well use qrencode to do it since I have it installed on my local machine.

qrencode -t ansiutf8 < /etc/wireguard/mobile_user.conf
```