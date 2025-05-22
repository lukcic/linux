# Networking

Troubleshooting.

## Check DNS servers

1. Ping IP address instead FQDN.
2. Check DNS config.
3. Check if not override in `/etc/hosts` file 

```sh
cat /etc/resolv.conf
# nameserver 1.1.1.1
```

4. Use dig to check if your servers resovle name.

5. Check using different DNS server (1.1.1.1) with dig.

```sh
dig +short wp.pl @1.1.1.1
```

# Check firewall

Check iptables for DROPS:

```sh
iptables -L -n

iptables-save
# list rules in format used to configure iptables
# -A - append
# -D - delete
# -j DROP - drop queue
```

## Use MTR

```sh
mtr wp.pl
# no route to host
```

## Routing

If ping works, dns works, check routing table

```sh
ip r s
ip route show

ip r g wp.pl
ip route get wp.pl
```

# tcpdump

Use tcpdump to check traffic

```sh
tcpdump -n port not 22 -vvvv
# show all traffic without ssh, full verbose
# seq 1 - sequence number, server will respond with the same

tcpdump -n port not 22 and host wp.pl -A -s0
# -A -s0 - show packets in ASCII (like Wireshark)

# Flags
# [S] - SYN
# [S.] - SYN ACK
# [.] - ACK
# [P] - PUSH - this package sends some data
# [F] - FIN - finish connection
```

## check SSL cert 

```sh
openssl x509 -in 75642a80baf96f7e6499fa2f816935ae.crt -text
# show certificate details (cert file)

openssl s_client -connect wp.pl:443
# show cert details (remote server)

openssl s_client -connect wp.pl:443 | openssl x509 -noout -dates
# show remote cert dates
```

## SSH tunelling

```sh
ssh -L <TUNEL_PORT>:<DEST_IP>:<DEST_PORT> -fN uername@ssh_server
ssh -L 1234:172.17.0.2:80 -fN root@192.168.1.20

# -L - listen
# -f - background
# -N - do nothing after ssh 

curl localhost:1234

# serves HTTP from destination container
```

UWAGA: Jeśli chcesz rozszerzyć swoją wiedzę, to poczytaj o odwrotności parametry -L (local), którą jest -R (remote). Ta opcja wystawia Twój lokalny port na zdalnym serwerze w taki sposób, aby np. ludzie z Internetu mieli dostęp do usługi uruchomionej w Twojej sieci lokalnej (za tzw. NATem).
