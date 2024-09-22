```sh
docker run -d --restart=unless-stopped \
    --name upsnap --net=host \
    -v upsnap:/app/pb_data -p 8090:8090 \
    -e  TZ=Europe/Warsaw -e UPSNAP_INTERVAL='@every 10s' \
    ghcr.io/seriousm4x/upsnap:4.3.2
```