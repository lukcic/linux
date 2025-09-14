# iptables

`Linux: & na końcu komendy odpala ją w tle`

```sh
tcpdump -i eth0 -n -e arp
-n wylacz rozw nazw
-e adresy fizyczne
arp - pokaz tylko arp

ip neighbor show
# zapamietane hosty po arp

ip r s
ip route show

ip route add default via GATEWAY-IP
# dodanie bramy domyślnej
# default = 0.0.0.0/24

apt install -y mtr-tiny
# usuniecie adresu ip powoduje wyczyszczenie tablicy routingu

# Sprawdzanie otwartego portu
nc -vzn IP_ADDRESS PORT
-v verbose
-z sprawdz czy port jest otwarty
-n nie rozwiązuj dns

!!! iptables
iptables -L -n
-L list
pokaże domyślną tablicę FILTER

iptables -L -t filter
iptables -L -t nat - nat i port forwarding
iptables -L -t mangle - modyfikacja nagłówków pakietów

chain -łańcuchy
INPUT - pakiety przychodzące do maszyny
FORWARD - filtorowanie pakietów przechodzących przez maszynę (jądro)
OUTPUT - filtrowanie pakietów wychodzących z maszyny, dropowane na poziomie kernela, wiec pakietów nie widać w tcpdump

-I -wrzuca regułę na początek łańcucha
-A -wrzuca regułę na koniec łańcucha
jak w VIM!

-D usuwa regułę - musi być cały zapis, np:
iptables -D INPUT -s 10.0.0.1 -d 10.0.0.1 -p tcp --dport 53 -j ACCEPT

policy ACCEPT - domyślne zachowanie firewalla
```
---
Enabling IPTABLES
# whitelisting my IP
iptables -I INPUT -s my_ip -j ACCEPT
iptables -I OUTPUT -d my_ip -j ACCEPT

# blocking all incoming traffic (change default policy)
iptables -P INPUT DROP
iptables -P OUTPUT DROP

# allwing dns traffic from my host internally (stateles)
iptables -I OUTPUT -s 10.0.0.1 -d 10.0.0.1 -p tcp --dport 53 -j ACCEPT
iptables -I OUTPUT -s 10.0.0.1 -d 10.0.0.1 -p udp --dport 53 -j ACCEPT
iptables -I OUTPUT -s 10.0.0.1 -d 10.0.0.1 -p tcp --sport 53 -j ACCEPT
iptables -I OUTPUT -s 10.0.0.1 -d 10.0.0.1 -p udp --sport 53 -j ACCEPT

iptables -I INPUT -s 10.0.0.1 -d 10.0.0.1 -p tcp --dport 53 -j ACCEPT
iptables -I INPUT -s 10.0.0.1 -d 10.0.0.1 -p udp --dport 53 -j ACCEPT
iptables -I INPUT -s 10.0.0.1 -d 10.0.01 -p tcp --sport 53 -j ACCEPT
iptables -I INPUT -s 10.0.0.1 -d 10.0.0.1 -p udp --sport 53 -j ACCEPT

dla każdej regułu na łańcuchu output musi być odpowiadająca reguła na łańcuchu input

bezstanowy - dla każdego wychodzącego pakietu musi byc przychodzący
---
Logowanie ruchu
iptables -A OUTPUT -j LOG
/var/log/syslog
---
Działanie IPTABLES

...
Chain OUTPUT (policy DROP)
target.   prot.   opt.   source.   destination
ACCEPT   all   --    0.0.0.0/0    10.0.0.1
LOG.   all   --    0.0.0.0/0   0.0.0.0/0   Log flags 0 level 4

przejdzie po kolei: ACCEPT -> LOG -> DROP (default policy), 
LOG musi być na końcu, zeby nie logować przechodzących pakietów

---
cleanup 
iptables -L -n --line-numbers # pokaże indexy reguł
iptables -D INPUT 1 # 1=index reguły, przesuwają się po usuwaniu
---
conntrack - firewall stanowy
moduł w kernelu, który śledzi każde połączenie, zeby powiązać przychodzące z wychodzącym

iptables -A INPUT -m conntrack --ctstate ESTABILISHED, RELATED -j ACCEPT
-m -module
--ctstatue - conntrack state

iptables -I OUTPUT 2 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
2 - put rule with index 2

ESTABLISHED - połączenie zestawione, czyli wyszło OUTPUTem, dzięki czemu odpowiedź może przyjść na INPUT

RELATED - połączenia powiązane - np pośredni router odpowiadający usłudze traceroute - ma inny adres IP niż docelowy, ale odp od niego jest powiązana z wychodzącym połączeniem

bez tego traceroute czy mtr pokaże tylko ping do docelowego ip, bez pośredniczących

--- 
Replacing rules
iptables -L -n --line-numbers
iptables -R OUTPUT 1 -p tcp --dport 53 -j ACCEPT
# allow all 53 outbound (root dns servers)
1 - replace rule #1

--- 
zapisywanie reguł
iptables-save > rules.txt

edytowanie vimem

iptables-restore < rules.txt

---
IPSET - hurtowe whitelistowanie adresów

---
Otwów połączenia wychodzące z danego interfejsu
iptables -I OUTPUT -o eth0 -j ACCEPT





