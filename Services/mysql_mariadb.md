# MySQL/MariaDB

<https://www.linuxshelltips.com/mysql-database-commands-cheat-sheet-for-linux/>

<https://phoenixnap.com/kb/install-mysql-ubuntu-20-04>

<https://phoenixnap.com/kb/how-to-create-new-mysql-user-account-grant-privileges>

<https://phoenixnap.com/kb/mysql-server-through-socket-var-run-mysqld-mysqld-sock-2>

<https://www.linuxshelltips.com/allow-remote-access-mysql/>

## MySQL

Installation:

```sh
sudo apt install mysql-server
sudo apt install mysql-client
```

Config:

```sh
sudo mysql_secure_installation
sudo mysql -u root -p
```

Database creation:

```sql
CREATE DATABASE test character set utf8 collate utf8_bin;
CREATE USER 'testuser'@'%' IDENTIFIED BY 'P@ssword123!';
GRANT ALL PRIVILEGES ON *.* TO 'testuser'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### Root password crack

```sh
mysql # works if there`s /root/.my.cnf file
history | grep 'mysql' 
# check if there's no history entry on root user with password passed as a parameter

ls -al ~/.mysql_history # mysql commands history
```

Changing password:

```sh
systemctl stop mysqld
/usr/sbin/mysqld --skip-grant-tables&
# run mysql in background with disabled priviledges
mysql
```

In mysql cli:

```sql
flush privileges;
alter user 'root'@'localhost' identified by 'NewPassword';
flush privileges;
```

Re-enable service

```sh
mysqladmin -u root -p NewPassword shutdown
systemctl enable --now mysqld
```

## MariaDB

No default root password.

Packages:
mariadb -client programs
mariadb-server -server software
MySQL-python -MySQL Python Interface

/etc/my.cnf.d -configuration directories
