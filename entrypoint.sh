#!/bin/bash
set -e


if [ -z "$PROXY_TARGET" ]; then
  PROXY_TARGET="192.168.99.100:80"
fi
if [ -z "$CERTIFICAT_CNAME" ]; then
  CERTIFICAT_CNAME="www.exemple.com"
fi

cat <<EOF > /etc/apache2/sites-available/proxy-reverse-ssl.conf
<VirtualHost *:443>
        ServerAdmin webmaster@localhost

        ErrorLog ${APACHE_LOG_DIR}/error-ssl.log
        CustomLog ${APACHE_LOG_DIR}/access-ssl.log combined

        SSLEngine on

        SSLCertificateFile    /etc/apache2/ssl/proxy.crt
        SSLCertificateKeyFile /etc/apache2/ssl/proxy.key

        BrowserMatch "MSIE [2-6]" \
                nokeepalive ssl-unclean-shutdown \
                downgrade-1.0 force-response-1.0
        BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

        RequestHeader set X-Forwarded-Proto "https"

        RewriteEngine on
        ProxyPreserveHost On
        ProxyRequests off
        ProxyPassReverse / http://$PROXY_TARGET/
        RewriteRule ^/(.*) http://$PROXY_TARGET/\$1 [P,L]
</VirtualHost>
EOF

/bin/ln -sf /etc/apache2/sites-available/proxy-reverse-ssl.conf /etc/apache2/sites-enabled/001-proxy-reverse-ssl.conf

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=FR/ST=c2is/L=Lyon/O=c2is/CN=$CERTIFICAT_CNAME" -keyout /etc/apache2/ssl/proxy.key -out /etc/apache2/ssl/proxy.crt

exec "$@"

