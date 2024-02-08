# Split horizon DNS master/slave with Bind

Split horizon is the ability for a DNS-server to give a different answer to a query based on the source of the query. A common use-case is when using the same DNS-server for internal and external queries. When your DNS is publicly available, you really don’t want to enable recursion to the outside world but internally it could be handy. Besides security there are also examples where resolving a certain name needs to return an internal IP while externally that IP is useless and it’s better to return something else.

Why split horizon?

One way to accomplish the above scenario would be to set up two DNS-servers. One to use internally, another to be public. This works fine but creates a lot of administrative overhead. Not to mention having slave-servers would require you to have another two machines extra. Split horizon allows you to have only one DNS-server, with or without a slave, that replies different based on some conditions (usually the source of a request)
Set up split horizon

To set up split horizon with bind, we will use acl’s and views. In this example, I’m assuming that a basic knowledge of bind exists and I will use the example that was set up in a previous post about master/slave DNS.

What we would like to create is two different answers for some zones, based on the source IP of a request. So if a host with an IP in the subnet 192.168.202.0/24 (let’s call that internal) queries our DNS, he should be returned an internal IP-address as answer. When the same query is initiated by a machine outside that subnet (let’s call that external), the DNS-server should return another IP-address. Some zones should return equal information for internal and external IP’s.

Taking the previous example (from the previous post), we will use zone blaat.test which will be different for internal and external and zone miauw.test which will be common to internal and external.

As a first step, we will create the split horizon master DNS. For now we will ignore the slave and correct the configuration of the slave later to avoid too much complexity.
Bind configuration of the master

We’ll start by changing our /etc/named.conf drastically. To avoid the need to maintain duplicate zone information for zones that are equal regardless of where the request came from, we will import the zone configuration for all zones.

/etc/named.conf on the master

```
options {
        listen-on port 53 { 127.0.0.1; 192.168.202.101;};
        #listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any;};
        recursion no;
        dnssec-enable no;
        dnssec-validation no;
        dnssec-lookaside auto;
        bindkeys-file "/etc/named.iscdlv.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
        notify yes;
        also-notify { 192.168.202.102; };
        allow-transfer { 127.0.0.1; 192.168.202.102; };
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
acl internal-acl {
   192.168.202.0/24;
};
// INTERNAL
view "internal-view" {
        match-clients {internal-acl; };
        include "/etc/named.internal.zones";
        include "/etc/named.common.zones";
};
// EXTERNAL
view "external-view" {
        match-clients { any; };
        include "/etc/named.external.zones";
        include "/etc/named.common.zones";
};
```

The basic options and logging remain as they were. The rest of the configuration is changed.

27-29: contains an ACL. Here you can list the host or subnets that are matched by that ACL named internal-acl
31-35: contains the view called internal-view and it matches the ACL internal-acl. So hosts that are in the subnet 192.168.202.0/24 will end up in this view
37-41: contains the view called external-view and it matches all hosts that weren’t matched before. So hosts that are not valid for the internal-acl will end up here.
Zone configuration

As you can see, the zone configuration is excluded from named.conf so we can re-use the common zone definitions (in /etc/named.common.zones) for both views. A restriction of using views is that all zones must be part of one or more views.

As mentioned earlier, we want the zone blaat.test to be different for the external and internal view so we need to define this zone twice.

The internal zone definitions are made in /etc/named.internal.zones:

```
zone "blaat.test" {
        type master;
        file "/var/named/data/db_internal.blaat.test";
        check-names fail;
        allow-update { none; };
        allow-query { any; };
};
```

The external zone definitions are made in /etc/named.external.zones:

```
zone "blaat.test" {
        type master;
        file "/var/named/data/db_external.blaat.test";
        check-names fail;
        allow-update { none; };
        allow-query { any; };
};
```

Finally, the common zone definitions are made in /etc/named.common.zones:

```
zone "miauw.test" {
        type master;
        file "/var/named/data/db.miauw.test";
        check-names fail;
        allow-update { none; };
        allow-query { any; };
};
zone "." IN {
        type hint;
        file "named.ca";
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

When looking at the zones defined in named.internal.zones and named.external.zones, you can see that both files contain the same zone configuration except for the files that contains the zone data:

```
/var/named/data/db_internal.blaat.test

@       IN SOA  ns.blaat.test admin.blaat.test. (
                                2014082202      ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@                       NS      ns.blaat.test.
ns                      IN      A               192.168.202.101
blaat.test.             IN      A               192.168.202.1
host1.blaat.test.       IN      A               192.168.202.10
host2.blaat.test.       IN      A               192.168.202.20

/var/named/data/db_external.blaat.test

@       IN SOA  ns.blaat.test admin.blaat.test. (
                                2014082202      ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@                       NS      ns.blaat.test.
ns                      IN      A               192.168.202.101
blaat.test.             IN      A               10.10.10.1
host1.blaat.test.       IN      A               10.10.10.10
host2.blaat.test.       IN      A               10.10.10.20
```

The common zone miauw.test remains unchanged.

After changing all of the above files, reload the changes:

```
[jensd@master ~]$ sudo systemctl reload named
```

Test to see if the server replies different when the request originates from a source within the specified subnet or from outside the subnet:

```
[jensd@master ~]$ nslookup host1.blaat.test localhost
Server: localhost
Address: 127.0.0.1#53
Name: host1.blaat.test
Address: 10.10.10.10

[jensd@master ~]$ nslookup host1.blaat.test 192.168.202.101
Server: 192.168.202.101
Address: 192.168.202.101#53
Name: host1.blaat.test
Address: 192.168.202.10
```

As you can see in the example, the server gives a different answer for a query that originated to localhost (so using 127.0.0.1 as source) or it’s real IP (so using 192.168.202.101 as source) which matches the internal-acl.

As a last test, we can check if the common zone is known from within both views and that the answer is equal:

```
[jensd@master ~]$ nslookup host1.miauw.test localhost
Server: localhost
Address: 127.0.0.1#53
Name: host1.miauw.test
Address: 192.168.202.10

[jensd@master ~]$ nslookup host1.miauw.test 192.168.202.101
Server: 192.168.202.101
Address: 192.168.202.101#53
Name: host1.miauw.test
Address: 192.168.202.10
```

The next step: add a slave for the split horizon master

Until now, the changes involved in comparison with a regular setup are not very complicated. It’s only at the moment when a slave comes into the picture that it’s getting (a little) more complicated.

We need to make sure that, in the slave’s configuration, the same zone get’s transferred twice. Once for each view. Since the zone’s name is equal for both views, it can easily be confused at the slave level because zone transfers are not aware of views. When we wouldn’t take any measures, the last updated zone, regardless of which view it was updated for, would overwrite the zone data of both views on the slave.

To resolve this problem, we will need to create the same views on the slave and restrict the zone transfer to the slave for each of those views. There are multiple ways to do this but for this example, I will use TSIG (Transaction SIGnatures). The key used for the zone-transfer will be different for each view ensuring that the correct zone+view get’s transferred to the same one on the slave.

The first step is to generate two keys for TSIG, one for the internal-view transfers and the other for the external-view transfers. For that, you can use the dnssec-keygen:

```
[jensd@master ~]$ dnssec-keygen -a HMAC-MD5 -n HOST -b 128 internal
Kinternal.+157+64609
[jensd@master ~]$ dnssec-keygen -a HMAC-MD5 -n HOST -b 128 external
Kexternal.+157+25576
```

The keygen generates two files, a.key and a .private. We only need they key which is generated in the .key file:

```
[jensd@master ~]$ ls -l K*
-rw-------. 1 jensd jensd 52 Aug 25 10:52 Kexternal.+157+25576.key
-rw-------. 1 jensd jensd 165 Aug 25 10:52 Kexternal.+157+25576.private
-rw-------. 1 jensd jensd 52 Aug 25 10:51 Kinternal.+157+64609.key
-rw-------. 1 jensd jensd 165 Aug 25 10:51 Kinternal.+157+64609.private
[jensd@master ~]$ cat Kexternal.+157+25576.key
external. IN KEY 512 3 157 DLYrQqPB6ZJMCO/yYQP7/w==
[jensd@master ~]$ cat Kinternal.+157+64609.key
internal. IN KEY 512 3 157 j10uJPBhPhhmmDhUwZmqQg==
```

Now that we have our keys, we can start adjusting our /etc/named.conf on the master to restrict zone-transfers to the slave, depending on the key.

```
options {
        listen-on port 53 { 127.0.0.1; 192.168.202.101;};
        #listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any;};
        recursion no;
        dnssec-enable no;
        dnssec-validation no;
        dnssec-lookaside auto;
        bindkeys-file "/etc/named.iscdlv.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
        notify yes;
        also-notify { 192.168.202.102; };
        allow-transfer { 127.0.0.1; 192.168.202.102; };
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
acl internal-acl {
   192.168.202.0/24;
};

key "external-key" {
        algorithm hmac-md5;
        secret "DLYrQqPB6ZJMCO/yYQP7/w==";
};

key "internal-key" {
        algorithm hmac-md5;
        secret "j10uJPBhPhhmmDhUwZmqQg==";
};

// INTERNAL
view "internal-view" {
        match-clients { key internal-key; !key external-key; internal-acl; };
        server 192.168.202.102 { keys internal-key; };
        include "/etc/named.internal.zones";
        include "/etc/named.common.zones";
};
// EXTERNAL
view "external-view" {
        match-clients { key external-key; !key internal-key;  any; };
        server 192.168.202.102 { keys external-key; };
        include "/etc/named.external.zones";
        include "/etc/named.common.zones";
};
```

Explanation of the changes:

31-34: key definition of key named external-key for the external-view transfers
36-39: key definition of key named internal-key for the internal-view transfers
43: the internal-key matches the internal-view (en the external-key doesn’t match)
44: matches the slave-server to the internal-key
50: the external-key matches the external-view (en the internal-key doesn’t match)
51: matches the slave-server to the external-key

On the slave, we need to make similar changes as we first did to our master to make it view-aware plus the changes involved for doing the correct zone-transfer. The changes of the slave are made on the configuration which was explained in a previous post about master/slave DNS.

First, we’ll change the /etc/named.conf of the slave:

```
options {
        listen-on port 53 { 127.0.0.1; 192.168.202.102;};
        #listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any;};
        recursion no;
        dnssec-enable no;
        dnssec-validation no;
        dnssec-lookaside auto;
        bindkeys-file "/etc/named.iscdlv.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
acl internal-acl {
   192.168.202.0/24;
};

key "external-key" {
        algorithm hmac-md5;
        secret "DLYrQqPB6ZJMCO/yYQP7/w==";
};

key "internal-key" {
        algorithm hmac-md5;
        secret "j10uJPBhPhhmmDhUwZmqQg==";
};

// INTERNAL
view "internal-view" {
        match-clients { key internal-key; !key external-key; internal-acl; };
        server 192.168.202.101 { keys internal-key; };
        include "/etc/named.internal.zones";
        include "/etc/named.common.zones";
};
// EXTERNAL
view "external-view" {
        match-clients { key external-key; !key internal-key;  any; };
        server 192.168.202.101 { keys external-key; };
        include "/etc/named.external.zones";
        include "/etc/named.common.zones";
};
```

The only difference between the slave and master’s configuration, besides the standard options, is the IP-address of the server-statement in both views. The real zone defintions are made in the included files (named.external.zones, named.internal.zones & named.common.zones). Those files need to be created on the slave:

/etc/named.internal.zones

```
zone "blaat.test" {
        type slave;
        file "/var/named/data/db_internal.blaat.test";
        masters { 192.168.202.101; };
        check-names fail;
        allow-update { none; };
        allow-query { any; };
};
```

/etc/named.external.zones

```
zone "blaat.test" {
        type slave;
        file "/var/named/data/db_external.blaat.test";
        masters { 192.168.202.101; };
        check-names fail;
        allow-update { none; };
        allow-query { any; };
};
```

/etc/named.common.zones

```
zone "miauw.test" {
        type slave;
        file "/var/named/data/db.miauw.test";
        masters { 192.168.202.101; };
        check-names fail;
        allow-update { none; };
        allow-query { any; };
};
zone "." IN {
        type hint;
        file "named.ca";
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

After changing the configuration on both the slave and master, we can reload the configuration to make the changes active. To prevent incorrect zone transfers, it’s better to first stop the slave.

```
[jensd@slave ~]$ sudo systemctl stop named

[jensd@master ~]$ sudo systemctl reload named

[jensd@slave ~]$ sudo systemctl start named
```

After reload the configuration of the master and restarting the slave, the /var/named/data/-directory, where we chose to store our zone-data on the slave should contain some data, transferred from the master:

```
[jensd@slave ~]$ sudo ls -l /var/named/data
total 20
-rw-r--r--. 1 named named 338 Aug 25 11:32 db_external.blaat.test
-rw-r--r--. 1 named named 338 Aug 25 11:32 db_internal.blaat.test
-rw-r--r--. 1 named named 338 Aug 25 11:32 db.miauw.test
-rw-r--r--. 1 named named 7315 Aug 25 11:32 named.run
```

Since we have data here, the transfer between the master and slave is working fine. This should also be visible in /var/named/data/named.run. To test of the split horizon configuration works on the slave too, we can test it:

```
[jensd@slave ~]$ nslookup host1.blaat.test localhost
Server: localhost
Address: 127.0.0.1#53
Name: host1.blaat.test
Address: 10.10.10.10

[jensd@slave ~]$ nslookup host1.blaat.test 192.168.202.102
Server: 192.168.202.102
Address: 192.168.202.102#53
Name: host1.blaat.test
Address: 192.168.202.10
```

In case the transfer wouldn’t initiate correctly or the data isn’t correct while you are sure that your configuration is, you can force a retransfer of the zones with the follow commands:

```
[jensd@slave ~]$ sudo rndc retransfer blaat.test IN internal-view
[jensd@slave ~]$ sudo rndc retransfer blaat.test IN external-view
```

Be sure to check the ip-addresses of the master and slave in the /etc/named.conf on both the master and slave (they are different) if the zone transfer doesn’t work as expected.

After following this (rather long) example, creating a split horizon DNS with master and slave should be a piece of cake :)
