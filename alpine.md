https://alpinelinux.org/downloads/

Virtual iso is live cd, sa must be installed.

1. root
2. setup-alpine
3. Installing docker:

```sh
apk add vim
vim /etc/apk/repositories  #uncomment line with ...community
apk update
apk add doker
rc-update add docker boot  #adding docker service to autostart
reboot
```
