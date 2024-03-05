<% if (package.server && options.pdfServerUrl !== 'http://pdf-server:4005') { %>
######################################################
## Will deploy the API server in single namespace
## served by the Nginx proxy. Configmap will
## include the ability to route traffic to a single 
## PDF server in its own env for multiple environments 
######################################################
---
##  API Server | Deployment
kind: Deployment
apiVersion: apps/v1
metadata:
  name: api-server
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
  labels:
    app: api-server
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api-server
        image: {{ .Values.image.repository }}
        ports:
          - containerPort: 3000
        env:
          - name: REDEPLOY_TIMESTAMP ## Used for forcing updates when env vars change
            value: "{{ now }}"
          - name: APP_NAME
            value : Form.io
          - name: DEBUG
            value: "formio.*"
          - name: NODE_ENV
            value : {{ .Values.appEnv }}
<% if (!options.portalSecret) { %>
          - name: PRIMARY
            value : "true"
          - name: PORTAL_ENABLED
            value: {{ .Values.portalEnabled | quote }}
<% } else { %>
          - name: PORTAL_SECRET
            value: {{ .Values.portalSecret | quote }}
<% } %>
          - name: PORT
            value : {{ .Values.port | quote }}
          - name: MONGO
            value: {{ .Values.mongo }}
          - name: ADMIN_EMAIL
            value: {{ .Values.adminEmail }}
          - name: ADMIN_PASS
            value: {{ .Values.adminPass }}
          - name: DB_SECRET
            value: {{ .Values.dbSecret }}
          - name: JWT_SECRET
            value: {{ .Values.jwtSecret }}
          - name: LICENSE_KEY
            value: {{ .Values.licenseKey }}
          - name: PDF_SERVER
            value: {{ .Values.pdfServer }}
          - name: BASE_URL
            value: {{ .Values.baseUrl }}

---
##  Nginx | Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      volumes:
      - name: config
        configMap:
          name: nginx-config
          items:
          - key: config
            path: default.conf
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        env:
        - name: REDEPLOY_TIMESTAMP ## Used for forcing updates when env vars change
          value: "{{ now }}"
<% } %>
     



<% if (package.pdf && !options.pdfServerUrl) { %>
######################################################
## Mean't to be served in it's own namespace so it can
## be accessed by multiple API server enviornments 
######################################################
---
##  PDF Server | Deployment    
kind: Deployment
apiVersion: apps/v1
metadata:
  name: pdf-server
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
  labels:
    app: pdf-server
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: pdf-server
  template:
    metadata:
      labels:
        app: pdf-server
    spec:
      containers:
      - name: pdf-server
        image: {{ .Values.pdf.repository }}
        ports:
          - containerPort: 4005
        env:
          - name: REDEPLOY_TIMESTAMP ## Used for forcing updates when env vars change
            value: "{{ now }}"
          - name: FORMIO_PDF_PORT
            value: "4005"
          - name: MONGO
            value: {{ .Values.mongo }}
          - name: LICENSE_KEY
            value: {{ .Values.licenseKey }}
          - name: DEBUG
            value: "pdf.*"
<% if (package.azure) { %>
          ### Azure Blob Storage
          - name: FORMIO_AZURE_CONTAINER
            value: {{ .Values.formioAzureContainer }}
          - name: FORMIO_AZURE_CONNECTION_STRING
            value: {{ .Values.formioAzureConnectionString }}
<% } %>    
<% if (package.aws) { %>
          ### AWS S3
          - name: FORMIO_S3_KEY
            value: {{ .Values.formioS3Key }}
          - name: FORMIO_S3_SECRET
            value: {{ .Values.formioS3Secret }}
          - name: FORMIO_S3_BUCKET
            value: {{ .Values.formioS3Bucket }}
          - name: FORMIO_S3_REGION
            value: {{ .Values.formioS3Region }}
          - name: TEXTRACT_OUTPUT_FOLDER
            value: {{ .Values.textractOutputFolder }}
          - name: TEXTRACT_ROLE_ARN
            value: {{ .Values.textractRoleArn }}
          - name: TEXTRACT_SNS_TOPIC_ARN
            value: {{ .Values.textractSnsTopicArn }}
<% } %>   
<% } %>




<% if (package.server && options.pdfServerUrl === 'http://pdf-server:4005') { %>
########################################################
## Will create a full deployment for a single namespace
## Use for environment that do not intend on using 
## multiple API server environments.
########################################################
---
##  API Server | Deployment
kind: Deployment
apiVersion: apps/v1
metadata:
  name: api-server
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
  labels:
    app: api-server
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api-server
        image: {{ .Values.image.repository }}
        ports:
          - containerPort: 3000
        env:
          - name: REDEPLOY_TIMESTAMP ## Used for forcing updates when env vars change
            value: "{{ now }}"
          - name: APP_NAME
            value : Form.io
          - name: DEBUG
            value: "formio.*"
          - name: NODE_ENV
            value : {{ .Values.appEnv }}
<% if (!options.portalSecret) { %>
          - name: PRIMARY
            value : "true"
          - name: PORTAL_ENABLED
            value: {{ .Values.portalEnabled | quote }}
<% } else { %>
          - name: PORTAL_SECRET
            value: {{ .Values.portalSecret | quote }}
<% } %>
          - name: PORT
            value : {{ .Values.port | quote }}
          - name: MONGO
            value: {{ .Values.mongo }}
          - name: ADMIN_EMAIL
            value: {{ .Values.adminEmail }}
          - name: ADMIN_PASS
            value: {{ .Values.adminPass }}
          - name: DB_SECRET
            value: {{ .Values.dbSecret }}
          - name: JWT_SECRET
            value: {{ .Values.jwtSecret }}
          - name: LICENSE_KEY
            value: {{ .Values.licenseKey }}
          - name: PDF_SERVER
            value: {{ .Values.pdfServer }}
          - name: BASE_URL
            value: {{ .Values.baseUrl }}

---
##  PDF Server | Deployment    
kind: Deployment
apiVersion: apps/v1
metadata:
  name: pdf-server
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
  labels:
    app: pdf-server
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: pdf-server
  template:
    metadata:
      labels:
        app: pdf-server
    spec:
      containers:
      - name: pdf-server
        image: {{ .Values.pdf.repository }}
        ports:
          - containerPort: 4005
        env:
          - name: REDEPLOY_TIMESTAMP ## Used for forcing updates when env vars change
            value: "{{ now }}"
          - name: FORMIO_PDF_PORT
            value: "4005"
          - name: MONGO
            value: {{ .Values.mongo }}
          - name: LICENSE_KEY
            value: {{ .Values.licenseKey }}
          - name: DEBUG
            value: "pdf.*"
<% if (package.azure) { %>
          ### Azure Blob Storage
          - name: FORMIO_AZURE_CONTAINER
            value: {{ .Values.formioAzureContainer }}
          - name: FORMIO_AZURE_CONNECTION_STRING
            value: {{ .Values.formioAzureConnectionString }}
<% } %>    
<% if (package.aws) { %>
          ### AWS S3
          - name: FORMIO_S3_KEY
            value: {{ .Values.formioS3Key }}
          - name: FORMIO_S3_SECRET
            value: {{ .Values.formioS3Secret }}
          - name: FORMIO_S3_BUCKET
            value: {{ .Values.formioS3Bucket }}
          - name: FORMIO_S3_REGION
            value: {{ .Values.formioS3Region }}
          - name: TEXTRACT_OUTPUT_FOLDER
            value: {{ .Values.textractOutputFolder }}
          - name: TEXTRACT_ROLE_ARN
            value: {{ .Values.textractRoleArn }}
          - name: TEXTRACT_SNS_TOPIC_ARN
            value: {{ .Values.textractSnsTopicArn }}
<% } %>           

---
##  Nginx | Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      volumes:
      - name: config
        configMap:
          name: nginx-config
          items:
          - key: config
            path: default.conf
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        env:
        - name: REDEPLOY_TIMESTAMP ## Used for forcing updates when env vars change
          value: "{{ now }}"
<% } %>