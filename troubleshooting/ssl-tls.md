# SSL/TLS certs

```sh
openssl x509 -in 75642a80baf96f7e6499fa2f816935ae.crt -text
# show certificate details (cert file)

openssl s_client -connect wp.pl:443
# show cert details (remote server)

openssl s_client -connect wp.pl:443 | openssl x509 -noout -dates
# show remote cert dates
```

## SNI

SNI - SSL cert is given as the second step of connection. Initial handshake is made with universal (SNI) certificate,
used by for example Cloudflare.
