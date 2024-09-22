# Proxmox

## Resize VM Proxmox

```sh
qm shutdown 190 && qm wait
qm resize 190 scsi0 +8G
qm start 190
```

## Add NFS storage

```sh
pvesm add nfs true-backups --path /mnt/pve/true-backups  --server <Server IP> --options vers=4.2,nolock,tcp --export /mnt/main/Backup/pve1 --content images,iso,vztmpl,backup,rootdir

pvesm add nfs true-backups --path /mnt/pve/true-backups  --server <Server IP> --options vers=4.2,nolock,tcp --export /mnt/main/Backup/pve2 --content backup

pvesm add nfs iso-images --path /mnt/pve/iso  --server <Server IP> --options vers=4.2,nolock,tcp --export /mnt/main/iso --content iso
```

## Changing cluster nodes IP

All nodes must be updated!

```sh
systemctl stop pve-cluster
systemctl stop corosync
pmxcfs -l

vim /etc/network/interfaces
vim /etc/hosts

# update IP and config version
vim /etc/pve/corosync.conf

reboot
```
