# NFS

## Configure server in Debian

```sh
sudo apt update
sudo apt install nfs-kernel-server
sudo systemctl status nfs-kernel-server

sudo mkdir /mnt/nfs_share
sudo chown -R nobody:nogroup /mnt/nfs_share
sudo chmod 777 /mnt/nfs_share

sudo vim /etc/exports
/mnt/nfs_share 192.168.254.50(rw,sync,no_subtree_check)
/mnt/nfs_share 192.168.254.0/24(rw,sync,no_subtree_check)

sudo exportfs -a
# -a -export all directories

sudo systemctl restart nfs-kernel-server
sudo ufw allow from 192.168.254.0/24 to any port nfs
```

## Configure client

```sh
sud apt install nfs-common
sudo mkdir -p /mnt/serverpath

sudo mount [SERVER_IP]:/mnt/nfs_share /mnt/server_path
```

## Commands

```sh
exportfs -vr
# -r -re-export
# -v -verbose
```

## Common NFS Export Options

- `rw` - Allow both read and write requests on the NFS volume
- `ro` - Allow only read requests on the NFS volume
- `sync` - Reply to requests only after changes are written to disk (safer but slower)
- `async` - Reply to requests before changes are written to disk (faster but riskier)
- `no_subtree_check` - Disable subtree checking (recommended, improves reliability)
- `subtree_check` - Enable subtree checking (can cause issues with file renames)
- `root_squash` - Map requests from uid/gid 0 to anonymous uid/gid (default)
- `no_root_squash` - Don't map root user (INSECURE - gives root access)
- `all_squash` - Map all user requests to the anonymous uid/gid
- `anonuid=UID` - Set the uid for anonymous user
- `anongid=GID` - Set the gid for anonymous user
- `secure` - Require requests from ports below 1024 (default)
- `insecure` - Allow requests from ports above 1024
---
- `ro` - read only
- `rw` - read/write
- `async` - server can buffer transactions before save confirmation, better performance
- `sync` - safer, immediately save transactions to disk (before confirmation)
- `root_squash` - map requests from root uid/gid to the anonymous uid/gid (65534) on NFS client connections
- `no_root_squash` - disables mapping client root to nobody (on server). Allows client root having full permissions on
  server (shares). `DANGEROUS!`
  options, every client root account has unrestricted rights the root account on the NFS server
- `all_squash` - maps all users to nobody, used when you don;t want to assign permissions
- `subtree_check` - checks if client has access to the specific part of catalog tree, can cause problems
- `no_subtree_check` - less issues when using share subdirectories, better performance
- `wdelay` - optimize write operations
- `no_wdelay` - disables write delays, used for writing small files.This option has no effect if async is also set.
- `sec` - security options
  - `sys` - use local user and group ids to authenticate NFS operations

## NFS ACL tools
