# Links

https://www.linuxshelltips.com/remote-linux-backup/

https://www.linuxshelltips.com/backup-linux-filesystem-using-dump-command/

https://www.linuxshelltips.com/clone-linux-partition-with-dd-command/

https://www.tecmint.com/how-to-clone-linux-systems/

# Duplicati

https://docs.linuxserver.io/images/docker-duplicati
https://www.youtube.com/watch?v=JoA6Bezgk1c&list=WL&index=4&t=9s

```sh
docker run -d \
  --name=duplicati \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=Europe/Warsaw \
  -e CLI_ARGS= `#optional` \
  -p 8200:8200 \
  -v </path/to/appdata/config>:/config \
  -v </path/to/backups>:/backups \
  -v </path/to/source>:/source \
  --restart unless-stopped \
  lscr.io/linuxserver/duplicati
```

```yaml
---
version: '2.1'
services:
  duplicati:
    image: lscr.io/linuxserver/duplicati
    container_name: duplicati
    environment:
      - PUID=0
      - PGID=0
      - TZ=Europe/London
      - CLI_ARGS= #optional
    volumes:
      - </path/to/appdata/config>:/config
      - </path/to/backups>:/backups
      - </path/to/source>:/source
    ports:
      - 8200:8200
    restart: unless-stopped
```

---

## DB Container Backup Script Template

```sh
#!/bin/bash

# DB Container Backup Script Template

# ---

# This backup script can be used to automatically backup databases in docker containers.

# It currently supports mariadb, mysql and bitwardenrs containers.

#

DAYS=2
BACKUPDIR=/home/xcad/backup

# backup all mysql/mariadb containers

CONTAINER=$(docker ps --format '{{.Names}}:{{.Image}}' | grep 'mysql\|mariadb' | cut -d":" -f1)

echo $CONTAINER

if [ ! -d $BACKUPDIR ]; then
mkdir -p $BACKUPDIR
fi

for i in $CONTAINER; do
    MYSQL_DATABASE=$(docker exec $i env | grep MYSQL_DATABASE |cut -d"=" -f2)
    MYSQL_PWD=$(docker exec $i env | grep MYSQL_ROOT_PASSWORD |cut -d"=" -f2)

    docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$MYSQL_PWD \
        $i /usr/bin/mysqldump -u root $MYSQL_DATABASE \
        | gzip > $BACKUPDIR/$i-$MYSQL_DATABASE-$(date +"%Y%m%d%H%M").sql.gz

    OLD_BACKUPS=$(ls -1 $BACKUPDIR/$i*.gz |wc -l)
    if [ $OLD_BACKUPS -gt $DAYS ]; then
        find $BACKUPDIR -name "$i*.gz" -daystart -mtime +$DAYS -delete
    fi

done

# bitwarden backup

BITWARDEN_CONTAINERS=$(docker ps --format '{{.Names}}:{{.Image}}' | grep 'bitwardenrs' | cut -d":" -f1)

for i in $BITWARDEN_CONTAINERS; do
    docker exec  $i /usr/bin/sqlite3 data/db.sqlite3 .dump \
        | gzip > $BACKUPDIR/$i-$(date +"%Y%m%d%H%M").sql.gz

    OLD_BITWARDEN_BACKUPS=$(ls -1 $BACKUPDIR/$i*.gz |wc -l)
    if [ $OLD_BITWARDEN_BACKUPS -gt $DAYS ]; then
        find $BACKUPDIR -name "$i*.gz" -daystart -mtime +$DAYS -delete
    fi

done

echo "$TIMESTAMP Backup for Databases completed"
```

---

### db-container-backup.service:

```toml
[Unit]
Description=DB Container Backup Script
Wants=db-container-backup.timer

[Service]
Type=simple
ExecStart=sh db-container-backup.sh
User=xcad

[Install]
WantedBy=default.target
```

---

### db-container-backup.timer:

```toml
[Unit]
Description=DB Container Backup Daily Job

[Timer]
OnCalendar=daily
Persistent=true
Unit=db-container-backup.service

[Install]
WantedBy=timers.target
```
