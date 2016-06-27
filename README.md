# C2is container for Apache SSL Reverse Proxy  

### Usage  

##### With docker-compose (use image already built from docker's hub)
```
# In your docker-compose.yml file
reverseproxy:
    build:  c2is/docker-debian-apache-reverseprox
    ports:
        - "443:443"
    environment:
        - PROXY_TARGET=192.168.99.100:82
        - CERTIFICAT_CNAME=www.example.com
```

