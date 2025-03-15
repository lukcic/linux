# Disks

## Add new disk to OS

```sh
sudo fdisk /dev/xvdb
sudo parted /dev/xvdb
mklabel msdos
sudo mkfs.xfs /dev/xvdb1 
sudo mount /dev/xvdb1 /var/jenkins_home
(parted) mkpart primary xfs 1m 8G
```

## List devices

`lsscsi` - lists scsi devices

`lsblk` -list block devices (disks with partitions)
-f [FILESYSTEM] -query information about filesystem, eg. UUID

`lsusb` -list connected USB devices

`lspci` -list PCI devices
-v -driver details (-vv too)

## du

Disk usage:

```sh
du -h [DIRECTORY] 
# disk usage of files in directory and subdirectories in readable format
# -s -summary disk usage of directory
# -a -disk usage of all files & dirs in directory severally
# -c -total disk usage of dirs in directory
# -m -disk usage  in MB
# --exclude="*PATTERN*" - excludes files with given pattern (eg. "**.tmp*")
# --time - shows modification time
```

### Find the biggest directories:

`sudo du -hs /* | sort -rh | head -5`

## df

Disk free:

```sh
df -h [DIRECTORY] 
# shows used and free space of directory
# -a - all
# -T - shows filesystem type

df -hx tmpfs        
# shows disk free space excluding temp filesystems

df -i
# shows inodes info (file metadata)
```

## quota

`quota` -shows disks limits

## Partitions

`extended partition` - container for logical partitions (MBR)
`primary partition` - bootable disk, first partition in MBR must be primary, max 4 primary partitions (MBR)

### fdisk

`fdisk` - text program, only MBR partition tables

```sh
fdisk -l 
# list disks

fdisk /dev/sda  
# edit first disk
```

Commands:
q   -quit witout saving changes
w   -write changes
p   -print current partition table
F   -check unallocated space
n   -create partition (eg.: +300G)
d   -delete partition
t   -change partition type (not filesystem type!), 83 - Linux, 82 - Linux SWAP

### gdisk

`gdisk` -text version of fdisk with only GPT support (commands are the same)
s   -sort partition numbers

### parted

`parted` - text program for MBR & GPT partition tables

### gparted

`gparted` - GUI program for MBR & GPT partition tables

```sh
parted /dev/sda 
# editing disk

print devices
select /dev/sdb 
# changing disk to edit

print           # information about selected disk
print devices   # information about all block devices
print free      # show free space
```

#### Creating partition table

```sh
mklabel msdos   # create MBR
mklabel gpt     # create GPT
```

#### Creating partition

```sh
mkpart [PART_TYPE] [FSTYPE] [START] [END]

# Example:
(parted) mkpart primary ext4 1m 100m

# PARTTYPE: primary, logical, extended
# FSTYPE: parted will only make a flag, not create the filesystem, here should be SWAP (linux-swap) assigned too
# START: beginning of the partition in s(sectors), m(megabytes), B(bytes), %
# END: end of partition in s(sectors), m(megabytes), B(bytes), %

rm [number] 
# delete a partition with selected number
```

## Filesystems

```sh
mkfs.[TYPE] [PARTITION] 

# format partition in specific filesystem type, eg.: 
mkfs.ext4 /dev/sdb1

# or
mk2fs -t ext4 /dev/sdb1
-L [LABEL]   # add label to partition

ls -l /sbin/mkfs.* 
# list available filesystem types
```

## Mounting

Mounting is a process that assign mount point directory (in host filesystem) to root directory of connected filesystem. Mount is mostly alias of specific commands as `mount.ntfs` or `mount.ext4`.

```sh
mount           
# list mounted filesystems with  options

mount [DEVICE] [MOUNT_POINT] 
# mounting partition, when is in fstab, only one parameter

-t [TYPE]       # specific type of fs
-a              # will mount all filesystem stored in fstab
-o [OPTIONS]    # mount fs with specified options   
-r              # mount fs as read only
-w              # mount fs as writable
```

### Options

```sh
-noatime        # do not refresh access time (better performance)
-async          # asynchronized i/o (better performance)m default option
-sync           # synchronized i/o (more secure, system slows)
-exec           # execution of binary files
-noexec         # disabled execution of binary files
-remount        # mount again (with changed options)
-ro             # read only
-rw             # read/write
```

### Unmounting

```sh
unmnount [DEVICE/MOUNT_POINT] 
# unmounting partition

-l
# lazy unmount, filesystem will be unmounted when all programs ends interactions with files, no new files are accessed

-f          
# forced, eg. when remote fs is not accessible
```

`lsof [PARTITION]`  - list open files from specific partition

## SWAP

```sh
mkswap /dev/sda2
swapon /dev/sda2
```

SWAP as file:

```sh
dd if=/dev/zero of=myswap bs=1M count=1024
mkswap myswap
# Add swap file to /etc/fstab.
```

## Tools

### fsck

This utility checks the filesystem type and run corresponding check.

```sh
fsck [FILESYETEM] 
# check filesystem integrity, UNMOUNT FIRST!!!
-A  # check all filesystem listed in /etc/fstab
-C  # show progress bar
-R  # used with -A will skip the root filesystem
-V  # verbose mode

e2fsck [FILESYETEM] # check ext2-4 filesystems
-p   # automatically repair errors (possible to repair)
-y   # will answer 'yes' to all questions
-n   # will answer 'no' to all questions
-f   # will force check
```

### tune2fs

`tune2fs` -setting parameters to ext2-4 filesystems

```sh
-l [FILESYSTEM]  # will show info about device
-c X             # set amount of fs mounts without checking, after this value fs will be checked while booting
-i Xd            # set time (days), after this fs will be checked while booting
-L [LABEL]       # set the label (max 16ch.)
-U               # set the UUID
-e [BEHAVIOR]   # defines the kernel behavior, when the error is found (continue, remount-ro, panic)
-j [FILESYSTEM]   # convert ext2 to ext3 (add journal)
```

## Device files

Device files:

- `b -block device` -  Physical or virtual device (disk and other storage devices). Programs can read data from block devices only in constant size blocks

- `c -character device` (virtual or physical) - terminals or serial ports. Works on data strings. Programs can read/write characters from it. Doesn't have size.

- `p -pipe device`  - works on strings, but on the end there is another process not device.

- `s -socket device` - interface to make communication between two processes (programs).

## fstab

File System Table

`/etc/fstab`:

```sh
[DEVICE] [MOUNT_POINT] [TYPE] [OPTIONS] [DUMP] [FSCK]
```

- `DEVICE` - the device  containing the filesystem to be mounted. Instead of the device, you can specify the UUID or label of the partition.

- `MOUNT_POINT` - Where the filesystem will be mounted.

- `TYPE` - The filesystem type.

- `OPTIONS` - Mount options that will be passed to mount.

- `DUMP` - Indicates  whether  any  ext2,  ext3  or  ext4  filesystems  should  be  considered  for  backup  by the dump command. Usually it is zero, meaning they should be ignored.

- `FSCK` - When non-zero, defines the order in which the filesystems will be checked on boot-up. Usually it is zero.

### OPTIONS

- `atime and noatime`  - by  default,  every  time  a  file  is  read  the  access  time  information  is  updated.
  Disabling  this (with noatime)  can  speed up  disk  I/O.  Do  not  confuse  this with the modification  time,  which
  is updated every time a file is written to.

- `auto and noauto` - whether the filesystem can (or can not) be mounted automatically withmount -a.
defaults - this will pass the options rw,suid,dev,exec,auto,nouser and async to mount.

- `dev and nodev` - whether character or block devices in the mounted filesystem should be interpreted.

- `exec andn noexec` - allow or deny permission to execute binaries on the filesystem.

- `user and nouser` - allows (or not) an ordinary user to mount the filesystem.
group - allows a user to mount the filesystem if the user belongs to the same group which owns the device containing it.

- `owner` - allows a user to mount a filesystem if the user owns the device containing it.

- `suid and nosuid` - allow, or not, SETUID and SETGID bits to take effect.
ro and rw - mount a filesystem as read-only or writable.

- `remount` - this will attempt to remount an already mounted filesystem. This is not used on /etc/fstab, but as a
  parameter to mount -o. For example, to remount the already mounted partition /dev/sdb1 as read-only, you could use the
  command mount -o remount,ro /dev/sdb1. When remounting, you do not need to specify the filesystem type, only the
  device name or the mount point.

- `sync and async` - whether  to  do  all  I/O  operations  to  the  filesystem  synchronously  or  asynchronously.
  async is usually  the  default.  The  manual  page  for mount warns  that  using sync on  media  with  a  limited
  number of write cycles (like flash drives or memory cards) may shorten the life span of the device.

## dd

`dd` - read data from file or string and save this data to output file/string. dd copy data in blocks with given size.

```sh
dd if=oldFile of=newFile

dd if=/dev/zero of=[OUTPUT_FILE] bs=1024 count=1
# /dev/zero - endless string of zeros
# conv=ucase  -capitalize text when copying

dd if=/dev/sda of=backup.dd bs=4096
# this command will make a backup of disk and save it in file
```

### BTRFS

```sh
mkfs.btrfs /dev/sdb1

# Subvolumes:
btrfs subvolume create /mnt/disk/BKP

# Snapshots:
btrfs subvolume snapshot /mnt/disk /mnt/disk/snap
btrfs subvolume show /mnt/disk/BKP/
```

### Loop disk

`loop` - filesystem type that can mount single file as device file (dvd iso eg.)

```sh
dd if=/dev/zero of=/tmp/disk bs=1M count=100
mkfs.ext4 /tmp/disk
mount /tmp/disk /mnt/experiment

df -h
# /dev/loop0    93MB /mnt/experiment
```
