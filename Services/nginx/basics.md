# NGINX

## Installation

Packages in apt:

- nginx-core – minimal version without modules
- nginx-full – all available options are active
- nginx-extras – external modules (3rd party)

## Config

### Basics

NGINX doesn't support `else` in config files!

#### Sites available

`/etc/nginx/sites-available/default`

```nginx
server {
    listen 80 default_server; # makes this server default, only one default
    listen [::]:80 default_server;

        root /var/www/html; # directory of html files

        index index.html index.htm; # which file will be an index
        server_name _; # domain _ means all domains
        
        location / {
            try_files $uri $uri/ =404;
            # nginx first is looking for file with name given in path, next to directory, last will return 404
        }
}
```

Any domain pointing t the server which is not directly configured in config will be hosting default site. Consider
deleting this default.

Multiple domains to one site

```nginx
server_name domain1.xyz domain2.xyz;
````

Error page

```nginx
error_page 404 /error404.html;
```

Location

```nginx
location /files {
    autoindex on;
    #fancyindex on;

    allow 192.168.1.1;  # whitelisting for path
    deny all;
}
```

`fancyindex` - visual add-on

#### Enabling site

```sh
ln -s /etc/nginx/sites-available/second_page /etc/nginx/sites-enabled/second-page
```

#### Reloading nginx

Changing configuration requires reload of nginx service, changing hosted files doesn't.

```sh
nginx -t
# check config before restart

nginx -s reload
# reload service
```

#### Snippets

`/etc/nginx/snippets/test.conf`

Snipped stores code snippets that can be included in other config files.

```nginx
include snippets/test.conf
```

### Docker proxy

Delete `root` entry.

```nginx
location / {
    proxy_set_header Host $host;
    # without this proxied app won't know the host provided by client

    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # without this header docker logs won't include real client ip
    
    proxy_pass http://localhost:8080;
}
```

#### Modifying proxied page

```nginx
location / {
    proxy_set_header Host 'www.wp.pl';
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass https://www.wp.pl;

    sub_filter 'original_word' 'replaced_world';
}
```

### One config file for multiple domains

#### Regex

Default config file:

```nginx
set $dom /var/www/default;
# default root

if ($host ~ ^sub([0-9])\.test\.xyz$){
    set $dom /var/www/sub$1;
}

# if hosts is like sub3.test.xyz, root for this domain is /var/www/sub3

root $dom;

server_name _;
```

#### Maps

Mapping Host to specific config, each of them listens on individual port.

Definition:

```nginx
variable variable {
    how to map them
}
```

```nginx
map $host $target {
  sub1.test.xyz 127.0.0.1:8001;
  sub2.test.xyz 127.0.0.1:8002;
  sub3.test.xyz 127.0.0.1:8003;
  # add default value!
}

server {
    ...
    location / {
        proxy_pass http://$target;
    }
}
```

## Certbot

### Certbot installation

```sh
apt install certbot python3-certbot-nginx -y
```

`python3-certbot-nginx` - will reconfigure nginx automatically

Requesting new cert

```sh
cerbot --nginx -d domain.xyz
```

### Https redirect

```nginx
server {
    if ($host = test.xyz) {
        return 301 https://$host$request_uri;
    }

    listen 80;
    ...
}
```

### Dynamic https

```sh
certbot --nginx -d abc.test.xyz -d sub1.test.xyz -d sub2.test.xyz -d sub3.test.xyz
```

Certbot asks about https redirection.

## PHP

### PHP installation

```sh
apt install php-fpm -y
```

Nginx forward php traffic to FPM server.

Config

```nginx
location ~ \.php$ { # ~ any matching files, later regex
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php7.4-fpm.sock;
}
```

## Rewrites

Overwriting urls. Nginx it needs config. In apache use `.htaccess` file.

`https://test.xyz/example` ---> `https://example.com`

```nginx
rewrite ^/example$ https://example.com last;
```

`https://test.xyz/example/newsletter` ---> `https://example.com/newsletter`

```nginx
rewrite ^/example/(.+)$ https://example.com/$1 last;
```

`last` - no more rewrites for this address, do not check for next ones

### .htaccess

Nginx need module for `.htaccess`, Lua must be enabled.

```sh
cd /tmp
git clone https://github.com/e404/htaccess-for-nginx
cd htaccess-for-nginx
cp htaccess.lua /etc/nginx
cd /etc/nginx
vim nginx.conf
```

`nginx.conf` in section `html` add:

```nginx
lua_shared_dict htaccess 16m;
rewrite_by_lua_file /etc/nginx/htaccess.lua;
```

`.htaccess` in site directory:

```nginx
RewriteEngine On 
#enabling rewrites

RewriteRule ^info$ /a.php [L]
# requests for `info` will be rewrited to 'a.php' file.
# [L] - last in Apache syntax 
```

## Cache

Control values of `Cache-Control` headers. Dynamic pages should't be cached and static files should have appropriate
cache times set.

```nginx
set $expires 1h;
# default cache expiration

if ($host = "abc.test.xyz"){
    set $expires 3h;
    # cache expiration for 'abc'test.xyz'
}

expires $expires;
```

### Pools

`Proxy-cache-path`

```nginx
proxy_cache_path /test levels=1:2 keys_zone=CACHE-NAME:10m max_size=1G inactive=60m

location / {
  proxy_pass http://1.2.3.4/;
  proxy_cache CACHE-NAME;
  proxy_cache_valid 200 10s; 
  # all returned statuses 200 will be cached for 10s

  proxy_ignore_headers Expires;
  # used if upstream server returns cache control headers
  # these headers won't be forwarded to client? 
}
```

`/test` - catalog on disk to store cache\
`levels=1:2` how deep catalogs in cache are nested\
`keys-zone` - zone name, user defined\
`:10m` - 10MB of caching keys\
`max_size=1G` - cache size on disk\
`inactive=60m` - delete unused keys after 60 mins

## Limits

Limiting download speed of large file.

```nginx
location /large_file {
    limit_rate 50k;
}
```

## Headers

Adding headers to responses. Add all headers to the snipped and include it to config files.

```nginx
add_header X-Frame-Options "DENY";
```

## Blocking

Blocking bots using maps

```nginx
map $http_user_agent $bad_user {
  default 0; # all user agents are ok
  ~*bot 1;  # user agents ending with 'bot' are blocked
}

map $host $target {
  sub1.test.xyz 127.0.0.1:8001;
  sub2.test.xyz 127.0.0.1:8002;
  sub3.test.xyz 127.0.0.1:8003;
}

server {
    ...
    location / {
        if ($bad_user){
            return 403;
        }
        proxy_pass http://$target;
    }
}
```

## Load balancer

### Upstream 

Multiple `proxy_pass` servers in config represented as one symbolic name.

It will work like load balancer (round robin) or weight can be set.

```nginx
upstream target {
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

server {
    ...
    location / {
        proxy_pass http://target; # $ is not needed
    }
}
```

Weights

```nginx
# higher weight has higher priority
upstream target {
  random; # randomized order with weights respected

  #server 127.0.0.1:8001 down; # server is disabled
  server 127.0.0.1:8001 weight=1;
  server 127.0.0.1:8002 weight=10;
  server 127.0.0.1:8003 weight=3;
}
```

Backup upstream

Backup cannot be used with `random`.

```nginx
upstream target {
  server 127.0.0.1:8001;
  server 127.0.0.1:8003 backup;
}
```

## Basic auth

Installing `htpasswd` from Apache packages.

```sh
apt install apache2-utils -y
```

Creating password database

```sh
htpasswd -c /etc/nginx/users user01
# user01 will be used, password must be typed

htpasswd /etc/nginx/users user02
# adding next user
```

Nginx config

```pwsh
location / {
  auth_basic "Some name";
  # user defined name

  auth_basic_user_file /etc/nginx/users;
  # password database
}
```

Testing

```sh
curl -u user01:passw0rd localhost
```
