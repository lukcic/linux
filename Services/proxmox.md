# Proxmox

## VM settings best practices

Windows machines

* add additional drive for VirtIO drivers (iso)
  * <https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers>
* add TPM storage
* set VirtIO-GPU graphics card for GUI virtual machines
* set Machine type (System) as `q35` (PCI Express support) and `OVMF` UEFI instead legacy BIOS

Linux Machines

* SCSI controller - set VirtIO SCSI Single
* enable Qemu Guest Agent (IP address, ballooning, etc)
* set VirtIO-GPU graphics card for GUI virtual machines
* for older machines use Machine (System) as `i440fx` and `SeaBios`
* when `PCI-Passthrough` used, set Machine type (System) as `q35` (PCI Express support) and `OVMF` UEFI instead legacy
  BIOS
* disable 'use tablet for pointer' if no gui

## Resize VM Proxmox

```sh
qm shutdown 190 && qm wait
qm resize 190 scsi0 +8G
qm start 190
```

## Disable zfs atime

```sh
zfs set atime=off $POOL_NAME
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

## Cluster

### Networking

1. Add all NICs to the bond (LACP 802.3ad).

    Hash policy 3+4. MTU 9000.

2. Create bridge vmbr0, VLAN aware, bridge ports: bond0.
3. Create VLAN interfaces for:

* for VMs to use vmbr0.111
* for the cluster vmbr0.112
* for the storage vmbr0.113, Jumbo Frames 9000.

VLAN RAW device: vmbr0.
4. All names to the host files on all nodes.
5. Disable enterprise repo, add free one.
6. Check NTP: `/etc/chrony/sources`:

```sh
vim /etc/chrony/sources.d/custom.sources
```

```config
server time.lmg.gg iburst
pool time.cloudflare.com iburst
```

```sh
chronyc reload sources
chronyc sources list
```

7. Create cluster.

Use cluster network.

8. Quorum

* if 3 nodes, one can be offline
* if 4 nodes, one can be offline
* if 2 nodes, ZERO can be offline! Add tiebreaker (RaspberryPi).

9. Clustering the storage. Ceph can be used or external package as `Linstor DRBD`.
    [](https://linbit.com/blog/linstor-setup-proxmox-ve-volumes/)

## Templates

<https://gist.github.com/zidenis/dfc05d9fa150ae55d7c87d870a0306c5>
