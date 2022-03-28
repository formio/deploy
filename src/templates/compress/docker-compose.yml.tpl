version: "3.8"
services:
<% if (package.local) { %>
  mongo:
    image: mongo
    restart: always
    volumes:
      - "./data/db:/data/db"
    environment:
      MONGO_INITDB_ROOT_USERNAME:
      MONGO_INITDB_ROOT_PASSWORD:
<% if (package.pdf) { %>
  minio:
    image: minio/minio
    restart: always
    volumes:
      - "./data/minio/data:/data"
      - "./data/minio/config:/root/.minio"
    environment:
      MINIO_ACCESS_KEY: CHANGEME
      MINIO_SECRET_KEY: CHANGEME
    command: server /data
<% } %>
<% } %>
<% if (package.server) { %>
  api-server:
    image: <%- package.server %>
    mem_limit: 1024m
    restart: always
<% if (package.local || package.pdf) { %>
    links:
<% if (package.local) { %>
      - mongo
<% } %>
<% if (package.pdf) { %>
      - pdf-server
<% } %>
<% } %>
<% if (package.mongoCertName) { %>
    volumes:
      - "./certs:/src/certs:ro"
<% } %>
<% if (package.local && !package.nginx) { %>
    ports:
      - "3000:3000"
<% } %>
    environment:
<% if (package.local) { %>
<% if (options.license) { %>
      LICENSE_KEY: <%- options.license %>
<% } %>
<% if (options.dbSecret) { %>
      DB_SECRET: <%- options.dbSecret %>
<% } %>
<% if (options.jwtSecret) { %>
      JWT_SECRET: <%- options.jwtSecret %>
<% } %>
<% if (options.adminEmail) { %>
      ADMIN_EMAIL: <%- options.adminEmail %>
<% } %>
<% if (options.adminPass) { %>
      ADMIN_PASS: <%- options.adminPass %>
<% } %>
<% } %>
<% if (package.mongo) { %>
      MONGO: <%- package.mongo %>
<% } %>
<% if (package.mongoCertName) { %>
      MONGO_CA: /src/certs/<%- package.mongoCertName %>
<% } %>
<% if (package.pdf) { %>
      PDF_SERVER: http://pdf-server:4005
<% } %>
<% if (package.proxy) { %>
      PROXY: "true"
<% } %>
<% if (package.portal) { %>
      PORTAL_ENABLED: 1
<% } %>
      PORT: 3000
<% if (package.local) { %>
    env_file:
      - data/.env
<% } else { %>
    env_file:
      - .env
<% } %>
<% } %>
<% if (package.pdf) { %>
  pdf-server:
    image: <%- package.pdf %>
    restart: always
    mem_limit: 1024m
<% if (package.local) { %>
    links:
      - mongo
      - minio
<% } %>
<% if (package.mongoCertName) { %>
    volumes:
      - "./certs:/src/certs:ro"
<% } %>
<% if (package.local && !package.nginx) { %>
    ports:
      - "4005:4005"
<% } %>
    environment:
<% if (package.local && options.license) { %>
      LICENSE_KEY: <%- options.license %>
<% } %>
<% if (package.mongo) { %>
      MONGO: <%- package.mongo %>
<% } %>
<% if (package.mongoCertName) { %>
      MONGO_CA: /src/certs/<%- package.mongoCertName %>
<% } %>
<% if (package.sslCert) { %>
      SSL_CERT: <%- package.sslCert %>
<% } %>
<% if (package.sslKey) { %>
      SSL_KEY: <%- package.sslKey %>
<% } %>
<% if (package.pdfLibs) { %>
      PDFLIBS_URL: http://pdf-libs:8080
<% } %>
<% if (package.local) { %>
      FORMIO_S3_SERVER: minio
      FORMIO_S3_PORT: 9000
      FORMIO_S3_BUCKET: formio
      FORMIO_S3_KEY: CHANGEME
      FORMIO_S3_SECRET: CHANGEME
<% } %>
      FORMIO_PDF_PORT: 4005
<% if (package.local) { %>
    env_file:
      - data/.env
<% } else { %>
    env_file:
      - .env
<% } %>
<% } %>
<% if (!package.local || package.nginx) { %>
  nginx-proxy:
    image: nginx
    restart: always
    mem_limit: 128m
    ports:
      - "<%- options.port %>:80"
    volumes:
<% if (package.ssl) { %>
      - "./certs:/src/certs:ro"
<% } %>
      - "./conf.d:/etc/nginx/conf.d:ro"
<% if (package.server || package.pdf) { %>
    links:
<% if (package.server) { %>
      - api-server
<% } %>
<% if (package.pdf) { %>
      - pdf-server
<% } %>
<% } %>
<% } %>