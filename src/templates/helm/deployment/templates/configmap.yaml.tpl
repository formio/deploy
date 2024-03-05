<% if (package.server && options.pdfServerUrl) { %>
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  labels:
    tier: backend
data:
  config : |
    client_header_timeout   300;
    client_body_timeout     300;
    send_timeout            300;
    proxy_connect_timeout   300;
    proxy_read_timeout      300;
    proxy_send_timeout      300;
    server {
      listen 80;
      client_max_body_size 20M;
      client_body_buffer_size 20M;
      location / {
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_read_timeout  300;
        proxy_pass          http://api-server:3000;
        proxy_redirect      http://api-server:3000 http://$host;
      }
      location /pdf/ {
        rewrite ^/pdf/(.*)$ /$1 break;
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_read_timeout  300;
        proxy_pass          <%- options.pdfServerUrl %>;
        proxy_redirect      <%- options.pdfServerUrl %> http://$host;
      }
    }
    
<% } %>

<% if (package.server && !options.pdfServerUrl) { %>
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  labels:
    tier: backend
data:
  config : |
    client_header_timeout   300;
    client_body_timeout     300;
    send_timeout            300;
    proxy_connect_timeout   300;
    proxy_read_timeout      300;
    proxy_send_timeout      300;
    server {
      listen 80;
      client_max_body_size 20M;
      client_body_buffer_size 20M;
      location / {
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_read_timeout  300;
        proxy_pass          http://api-server:3000;
        proxy_redirect      http://api-server:3000 http://$host;
      }
    }
<% } %>