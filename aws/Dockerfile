FROM ghcr.io/nukib/misp:latest

COPY rds-combined-ca-bundle.pem /var/www/MISP
COPY database.php /var/www/MISP/Config
COPY misp.conf /etc/httpd/conf.d/misp.conf
