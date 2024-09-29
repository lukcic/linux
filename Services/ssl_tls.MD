Cert browser:
crt.sh

https://kbrzozova.medium.com/all-you-need-to-know-about-ssl-certificates-part-1-1f6f9b665650

# HTTP with TLS
TLS (Transport Security Layer) - independent layer between HTTP and TCP (TLS is not interfering in HTTP). 
Used because HTTP do not handle security - messages are send in plain text. 
Client application is checking server identity while connecting. 

SSL certificates:
-encryption of data transfered between server and browser
-make sure that taken data are not changed
-ensure that you connected right host

SSL verification types:
* DV -Domain Validation, make sure that domain is valid (Let`s Encrypt)
* OV -Organization Validation, make sure that company is valid, company name seeing in browser 
* EV -Extended Validation, make sure that you are owner of trademark (uded  by banks etc.) 

Mozilla SSL Config Generator
https://ssl-config.mozilla.org

## Openssl
openssl s_client -connect google.com:443            # checking server TLS cert info
openssl x509 -noout -text -in localadmin.pl.pem     # info about cert file

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj /CN=localhost -keyout files/nginx.key -out files/nginx.crt

SNI (server Name Indication) - client sends virtual host name in the beginning of TLS connection, to check which domain is request for, before http header decryption.   

openssl:
https://www.ibm.com/support/pages/openssl-commands-check-and-verify-your-ssl-certificate-key-and-csr


## Let's Encrypt in Amazon Linux:
```sh
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum-config-manager --enable epel
sudo yum install certbot
```
Certbot with DNS challenge (manual):
```
sudo certbot -v -a manual --email 'email@example.com' -d 'your.domain' --preferred-challenges dns --agree-tos certonly
```
Add DNS record manually. 

Add renew command to crontab
```
sudo crontab -e
0 12 * * * /usr/bin/certbot renew --quiet
```

### Certbot with DNS automation

Create policy, role and attach it to EC2.

Policy: `allowCertbotUpdateSERVICENAMEDnsEntry`

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:GetChange",
                "route53:ListHostedZones"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/Z0900...",
            "Condition": {
                "ForAllValues:StringEquals": {
                    "route53:ChangeResourceRecordSetsNormalizedRecordNames": [
                        "_acme-challenge.yourdomain.com"
                    ],
                    "route53:ChangeResourceRecordSetsRecordTypes": [
                        "TXT"
                    ],
                    "route53:ChangeResourceRecordSetsActions": [
                        "CREATE",
                        "UPSERT"
                    ]
                }
            }
        }
    ]
}
```

Role:
`ec2RoleForSERVICENAMECertbot`

Installation:
```sh
sudo yum install epel-release
sudo yum install certbot
sudo yum install -y python2-certbot-dns-route53
```
Provisioning certificate:
```sh
sudo certbot certonly --dns-route53 --dns-route53-propagation-seconds 60 -d DOMAIN.NAME
```
Renewing certificae:
```sh
sudo /usr/bin/certbot renew --dns-route53 --dns-route53-propagation-seconds 60
```
Crontab:
```sh
00 3 * * 1 /usr/bin/certbot renew --dns-route53 --dns-route53-propagation-seconds 60
```