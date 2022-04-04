NGINX_CONF = <<EOT
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

server {
    listen       80;
    listen       443 ssl http2;
    listen       [::]:443 ssl http2;
    server_name  _;

     ssl_certificate      /etc/nginx/server.crt;
     ssl_certificate_key  /etc/nginx/server.key;
     ssl_session_timeout  5m;

     ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
     ssl_ciphers    ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
     ssl_prefer_server_ciphers   on;

     location / {
       proxy_pass            http://localhost:51821;
       proxy_set_header      Host              \$host;
       proxy_set_header      X-Real-IP         \$remote_addr;
       proxy_set_header      X-Forwarded-For   \$proxy_add_x_forwarded_for;
       proxy_set_header      X-Client-Verify   SUCCESS;
       proxy_set_header      X-Client-DN       \$ssl_client_s_dn;
       proxy_set_header      X-SSL-Subject     \$ssl_client_s_dn;
       proxy_set_header      X-SSL-Issuer      \$ssl_client_i_dn;
       proxy_set_header      X-Forwarded-Proto http;
       proxy_read_timeout    1800;
       proxy_connect_timeout 1800;
     }
  }
}
EOT
