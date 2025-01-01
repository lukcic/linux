NC
Check connection on given port:
nc -zv 172.16.34.136 1514 1515 55000
Connection to 172.16.34.136 1514 port [tcp/*] succeeded!
Connection to 172.16.34.136 1515 port [tcp/*] succeeded!
______________________________________________________________________________________________________________
BOUNDING
TUNNELING -ASI movies

ifconfig command (obsolete)

ifconfig #show interfaces
-a       #show disabled

ifconfig [UP/DOWN] [INTERFACE]  #enabling/disabling given interface, needs sudo
ifconfig up eth0

ifconfig eth0 allmulti # enabling all multicast
ifconfig eth0 multicast # enabling multicast

arp     #show arp table

______________________________________________________________________________________________________________
iproute2 (actual)
ip [COMMAND] list|show      #show details

ip link set [INTERFACE] [UP/DOWN]                 # enabling/disabling interface
ip link set dev [INTERFACE] address [MAC_ADDRESS] # adding MAC addres
ip link set dev eth0 promisc on                   # enebling promiscous mode
ip neigh                                          # show arp table
man ip-link                                       # man page

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ip address      #shows all network interfaces
ip a            #short version
ip addr [ADD/DEL] [IP_ADDRESS] dev [INTERFACE]  #adding/removing ip address

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ip route show   #show routing table
ip route add [NETWORK_IP]/[MASK] via [GATEWAY_IP] dev [LOCAL_INTERFACE]   # adding static route for given network
ip route add default via [GATEWAY_IP] dev [LOCAL_INTERFACE]               # adding default route (0.0.0.0/0)

ip route add 132.236.220.64/26 via 132.236.212.6 dev eth1
ip route add default via 132.236.227.1 dev eth0

ip route flush          #clear all entries
ip route del [NETWORK]  #delete entry

______________________________________________________________________________________________________________
Static IP:

Debian & Ubuntu 16.04:
/etc/network/interfaces

auto eth0                           # auto - interface will enabled while system starts
iface eth0 inet static              # inet = IPv4, inet6 = IPv6
        address 192.0.2.7
        netmask 255.255.255.0
        gateway 192.0.2.254
        dns-nameservers 8.8.8.8

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Ubuntu 20.04
/etc/netplan/00-installer-config.yaml

Ubuntu 18.04
/etc/netplan/01-netcfg.yaml

network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:      #check card number!
      dhcp4: no
      dhcp6: no
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]

sudo netplan apply

______________________________________________________________________________________________________________

DHCP:

dhclient -r        #release addres
dhclient           #take address

Debian & Ubuntu 16.04:
/etc/network/interfaces

auto lo eth0
iface lo inet loopback
iface eth0 inet dynamic     # or: iface eth0 inet dhcp

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Ubuntu 20.04
/etc/netplan/00-installer-config.yaml

Ubuntu 18.04
/etc/netplan/01-netcfg.yaml
'''
network:
 version: 2
 renderer: networkd
 ethernets:
   ens33:
     dhcp4: yes
     dhcp6: yes
'''
sudo netplan apply
______________________________________________________________________________________________________________

Disabling IPv6:
Edit:  /etc/default/grub

'''
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash ipv6.disable=1"
GRUB_CMDLINE_LINUX="ipv6.disable=1"
'''
sudo update-grub ! ! !
______________________________________________________________________________________________________________

RHEL and CentOS:
/etc/sysconfig/network                              # hostname, default gateway (interface independent)
NETWORKING=yes
NETWORKING_IPV6=no
HOSTNAME=redhat.toadranch.com
DOMAINNAME=toadranch.com #optional
GATEWAY=192.168.1.254

/etc/sysconfig/network-scripts/ifcfg-[INTERFACE]    # IP, mask
DEVICE=eth0
IPADDR=192.168.1.13
NETMASK=255.255.255.0
NETWORK=192.168.1.0
BROADCAST=192.168.1.255
MTU=1500
ONBOOT=yes

#if DHCP:
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes

/etc/sysconfig/network-scripts/route-[INTERFACE]    # routes for interfaces

sudo service network restart  # or
sudo ifdown eth0 && sudo ifup eth0

______________________________________________________________________________________________________________
NETSTAT (obsolete):
sudo apt install net-tools

netstat -tulpn #shows open TCP and udp ports
l       # show listening sockets
t       # display tcp connections
n       # show numerical addresses
p       # showing process ID and process name
netstat -ltnp | grep -w ':80' - shows which process listning on port 80

netstat -rn # show routing table, -n will not use DNS

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SS - Socket Statiscics (actual):

ss -tapun
-t      # tcp ports
-a      # show all sockets
-p      # show process (use with sudo)
-u      # udp ports
-n      # do not resolve port names
______________________________________________________________________________________________________________

ping [HOST]
-n -do not use reverse DNS
-c 10 -stop after 10 packets
-s 1500 -send ICMP package with given weight (testing packets fragmentation)

______________________________________________________________________________________________________________

TRACEROUTE:
sudo apt install traceroute

Traceroute by default use udp packets. Sets low TTL to ICMP packets and increase it, remote hosts responds with TTL error.
If output gives only *. try --icmp parameter - will use icmp packets like Windows Tracert. If still, router doesn`t send ICMP responses.
Three pings for every host on the way. If all times the same, its possible that 3 packets goes different ways (paths redundancy).
!N - network unreachable
!H - host unreachable
!P - protocol unreachable

traceroute [DESTINATION_IP]     #check hops to given address
--icmp                          #use icmp, need sudo
______________________________________________________________________________________________________________

MTR (My traceroute)
Cobines ping and traceroute tools. Gives reponse times for all hops in path for given IP. q for quit.

mtr [IP]
-c 5    #send just 5 pings
______________________________________________________________________________________________________________

ROUTE

route #show host routing table
route add default gw [GATEWAY_IP] [LOCAL_INTERFACE]                   #adding default route (0.0.0.0/0)
route add -net [NETWORK_IP]/[MASK] gw [GATEWAY_IP] [LOCAL_INTERFACE]  #add new route
route del -net [NETWORK_IP]                                           #delete given route
______________________________________________________________________________________________________________
NMCLI - Network Manager Client #implemantation of networking GUI

nmcli             #list devices and cofig
nmcli device show #complete information about devices
cncli dev status  #show connections on all devices

______________________________________________________________________________________________________________

NC (NetCat) also referred to as the “Network Swiss Army knife”, is a powerful utility used for almost any task related to TCP, UDP, or UNIX-domain sockets.
It is used to open TCP connections, listen on arbitrary TCP and UDP ports, perform port scanning plus more.

You can also use it as a simple TCP proxy, for network daemon testing, to check if remote ports are reachable, and much more.
Furthermore, you can employ nc together with pv command to transfer files between two computers.
______________________________________________________________________________________________________________

TCPDump - commandline network sniffer. Stores packets in libpcap format.

tcpdump -i [INTERFACE]  #listening on given interface
-n                      #do not use DNS
-v                      #verbosity
-c 5                    #packet limit (5)
-w [FILENAME]           #save output to file, only headers by default
-r [FILENAME]           #read file with saved packets

tcpdump host [HOSTNAME] #list only pachages for given host (sended. received)
$ sudo tcpdump host bull
12:35:23.519339 bull.41537 > nubark.domain: A? atrust.com. (28) (DF)
12:35:23.519961 nubark.domain > bull.41537: A 66.77.122.161 (112) (DF)

41537 - local port
.domain - service name (DNS)

Filtering:
tcpdump src net 192.168.1.0/24 and dst port 80
______________________________________________________________________________________________________________

BMON - commandline graph of network interface usage
sudo apt install bmon
bmon
______________________________________________________________________________________________________________

NMAP:

nmap localhost -list all open ports on localhost
nmap [IP_ADDRES] -shows open ports from outside

nmap -sT [HOST] -scan firsth 1024 TCP ports on given host
-p  -define ports

nmap -sV -O [HOST]  -check OS on host

nmap --script ssl-cert -p 443 [HOSTNAME]
- show HTTP server ssl cert details

nmap --script ssl-enum-ciphers -p 443 [HOSTNAME]
- show ciphers used by this ssl cert
______________________________________________________________________________________________________________

iperf3 - network bandwidth measuring tool

iperf -s -p [PORT_NUMBER]
# server

iperf -c [SERVER_IP] -p [SERVER_PORT]
# client
______________________________________________________________________________________________________________
NESSUS - vulnerability scaner
METASPLOIT
LYNIS - sec scan from inside
John the Ripper - cracking user passwords
sudo ./john /etc/shadow

Fail2Ban - blocking sources from attacks
fail2ban.org

BRO - network intrusion detection (active and passive)
SNORT (Aanval) -NIDS with simply config

OSSEC - intrusion detection on host   #ossec.github.io
-rootkit tetection
-filesystems integrity control
-log analysis

Application works as eyes and ears of admin. Use manager and agents.
Config: /var/ossec/etc/ossec.conf.
ossec.github.io/docs/manual/monitoring/index.html#configuration-options.

______________________________________________________________________________________________________________

IPTABLES - pilot for Linux Firewall (Netfilter).

/etc/services - file with services and ports definition

https://www.tecmint.com/basic-guide-on-iptables-linux-firewall-tips-commands/
https://www.tecmint.com/linux-iptables-firewall-rules-examples-commands/
https://www.tecmint.com/configure-iptables-firewall/
https://www.tecmint.com/block-ping-icmp-requests-to-linux/
______________________________________________________________________________________________________________

FIREWALLD - pilot for linux Firewall (Netfilter). In new RHEL firewalld replace iptables.
Stores xml service description in /usr/lib/firewalld/services.
Zones (describes accepted services for incoming connection) are stored in /etc/firewalld.

systemctl enable firewalld
systemctl start firewalld

firewall-cmd --list-all
firewall-cmd --add-service=[SERVICENAME] -adding service temporarly
firewall-cmd --add-service=[SERVICENAME] --permanent -adding service permanently
firewall-cmd --remove-service=[SERVICENAME] --permanent -deletes service permanently
firewall-cmd --get-services -list known services
firewall-cmd --add-port=[PORT/tcp] --permanent -adding open port permanently

firewalld-cmd --reload

https://www.tecmint.com/firewalld-rules-for-centos-7/
https://www.tecmint.com/configure-firewalld-in-centos-7/
https://www.tecmint.com/start-stop-disable-enable-firewalld-iptables-firewall/
https://www.tecmint.com/setup-samba-file-sharing-for-linux-windows-clients/
______________________________________________________________________________________________________________

UFW - Uncomplicated Firewall. Debian & Ubuntu firewall software

ufw status              #check firewall status
ufw enable/disable      #enaling/disabling ufw firewall

https://www.tecmint.com/setup-ufw-firewall-on-ubuntu-and-debian/

______________________________________________________________________________________________________________

Router:
https://www.cyberciti.biz/tips/linux-as-router-for-dsl-t1-line-etc.html

Kernel:
/proc/sys/net/ipv4    # network variables, /conf - parameters for unique interfaces, for all and default
/proc/sys/net/ipv6

Setting network variables (temporary):
sudo sh -c "echo 1 > icmp_echo_ignore_broadcasts"   # -c menas taka command form string not from stdin
sysctl net.ipv4.icmp_echo_ignore_broadcasts=1

sudo echo 1 > icmp_echo_ignore_broadcasts - will not work because file will be opened before "sudo echo"

Setting network variables persistent:
 "'net.ipv4.ip_forward=1' >> /etc/sysctl.conf"   # sysctl.conf is read by sysctl while boot

______________________________________________________________________________________________________________
Ethernet:

Ehternet Header 14B | IPv4 Header 20B | UDP Header 8B | Data 100B | CRC 4B

1  Phisical layer
2. Data link layer:
  -MAC (Media Access Control) - medium & sending data
  -LLC (Link Layer Control) - framing data
3. IP layer

A 1 – 126 S.H.H.H bardzo wczesne sieci albo zarezerwowane dla Departamentu Obrony Stanów Zjednoczonych
B 128 – 191 S.S.H.H dla bardzo dużych ośrodków, zwykle podzielonych na podsieci, trudne do uzyskania
C 192 – 223 S.S.S.H łatwe do uzyskania, często przyznawane w zestawach
D 224 – 239 — adresowanie grupowe, brak stałego przypisania
E 240 – 255 — adresy eksperymentalne

Klasa IP  Od          Do                Zakres CIDR
Klasa A   10.0.0.0    10.255.255.255    10.0.0.0/8
Klasa B   172.16.0.0  172.31.255.255    172.16.0.0/12
Klasa C   192.168.0.0 192.168.255.255   192.168.0.0/16

IPv6 128B = 8B S | 8B H

MTU - Maximum Transfer Unit, default 1500B. Packets can have "Do not fragment" flag.
With VPN tuneling frames can have increased sise to 1540B and must be fragmented, option of lowering MTU should be used.

ipcalc 24.8.175.69/28

ETHTOOL:
sudo apt install ethtool

ethtool [interface] #show Ethernet layer info
ethtool –r          # renegotiate NIC parameters with switch
ethtool -s eth0 speed 100 duplex full

13.12. ROZWIĄZYWANIE PROBLEMÓW Z SIECIĄ 464
492
