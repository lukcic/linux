UTC = 17

CEST = UTC +2 = 19

CET - Central Europe Time
CEST - Central Europe Summer Time

---

## Setting time (Debian):

```sh
timedatectl
timedatectl list-timezones
sudo timedatectl set-timezone Europe/Warsaw
timedatectl
```

## Timezone:

```
TZ='Europe/Warsaw'; export TZ
```

```
cd /usr/share/zoneinfo
tzselect
```
