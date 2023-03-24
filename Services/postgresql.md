Reset user's password:

```sql
ALTER USER user_name WITH PASSWORD 'new_password';

```

DB backup:

```sh
pg_dump -c -U tecmint -h 10.10.20.10 -p 5432 tecmintdb > tecmintdb.sql
```
-c creates entries for backup is needed

```sh
docker-compose exec postgres \
    pg_dump -c hammerhead_production --no-acl --no-owner --clean \
    -U  retool_internal_user -f retool_db_dump.sql
```

Dump will be saved on containers FS, to copy it:
```sh
sudo docker cp retoolonpremise_postgres_1:/retool_db_dump_09_03_2023.sql ./retool_db_dump_09_03_2023.sql
```

Restoring:

```sh
docker-compose exec postgres \
    psql $DB_CONNECTION_URI -f retool_db_dump.sql    
```

Copy content from one db to another:

```
pg_dump -c -U tecmint -h 10.10.20.10 tecmintdb | pqsl -U tecmint -h 10.10.20.30 tecmintdb
```

Restoring remote DB:

```sh
psql -U retool_internal_user -h hostname.eu-central-1.rds.amazonaws.com -p 5432 -d hammerhead_production -f  retool_db_dump.sql
```

Killing hanging sessions:
```sql
select * from pg_stat_activity;

select pg_terminate_backend(pid) 
from pg_stat_activity
where pid = '611';

select * from pg_stat_activity;
```