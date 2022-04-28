FROM ghcr.io/nukib/misp:latest

RUN ln -sf /dev/stderr /var/log/httpd/access_log && \
    ln -sf /dev/stdout /var/log/httpd/error_log

COPY rds-combined-ca-bundle.pem /var/www/MISP
COPY database.php /var/www/MISP/Config
