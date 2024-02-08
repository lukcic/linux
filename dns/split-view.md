# Configure BIND DNS Split View

Configure BIND DNS Views and Split to respond to different DNS clients with different answers based on their IP address. If you have many computers connected via LAN among which one is a web server, within the local network you may want domain names to resolve to private IP addresses and from the internet it should resolve to the public IP address. This can be done with BIND’s split-horizon feature. Based on a list of IP addresses of clients the DNS server replies with the appropriate answer. Take note that if you decide to configure split view all zones should come under a view.

We’ll be creating two views as follows

    private: This will contain zones with zone files pointing to private IP addresses
    public: This view will contain the same zone but different zone files pointing to public IP addresses

As said earlier all zones should be in any one view, this includes the “.(root)” zone too. Start by opening the file corresponding to your Linux installation

```
BIND: /etc/named.conf
BIND chroot: /var/named/chroot/etc/named.conf
```

Add the following lines to the file for private and public view with example.com being your zone

```
view "private" {
match-clients { localhost; 192.168.0.0/24; };
zone "example.com" {
type master;
file "example.com-private.zone"
};
//Add other zone configurations one below another
};

view "public" {
match-clients { any; };
zone "example.com" {
type master;
file "example.com-public.zone"
};
//Add other zone configurations one below another
};
```

Replace the IP address in match-clients option to suit your network. Make sure you place all the zones including the default zones created by bind like localhost, “.” etc in the private view.

Now as usual create zone files in the appropriate location

```
BIND: /var/named/example.com-private.zone
BIND chroot: /var/named/chroot/var/named/example.com-private.zone
```

Create DNS zone records with private IP addresses in A records

```
@ IN A <private-ip-address>
```

Open the corresponding zone file for public view

```
BIND: /var/named/example.com-public.zone
BIND chroot: /var/named/chroot/var/named/example.com-public.zone
```

Create DNS zone records with public IP addresses

```
@ IN A <public-ip-address>
```

Now reload the named service

```
service named reload
```

If you get errors during reload look into the log files you’ll possible encounter the following error.

`when using view statements all zones must be in views`

It tells you that there are zones which haven’t been placed inside any view this includes the “.” zone, localhost and other default zones like these. You can see the results for private view by using dig command in your network itself, for public view use the DNS Lookup Tool.
