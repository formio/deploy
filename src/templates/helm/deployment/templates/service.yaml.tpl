<% if (package.server && options.pdfServerUrl !== 'http://pdf-server:4005') { %>
##  API Server | Service
kind: Service
apiVersion: v1
metadata:
  name: api-server
  labels:
    app: api-server
spec:
  selector:
    app: api-server
  ports:
    - name: http
      protocol: TCP
      port: 3000
      targetPort: 3000

---
##  Nginx | Service
kind: Service
apiVersion: v1
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  selector:
    app: nginx
  ports:
    - name: nginx
      port: 80
      targetPort: 80
<% } %>

<% if (package.pdf && options.pdfServerUrl !== 'http://pdf-server:4005') { %>
##  PDF Server | Service
kind: Service
apiVersion: v1
metadata:
  name: pdf-server
  labels:
    app: pdf-server
spec:
  selector:
    app: pdf-server
  ports:
    - name: pdf-server
      protocol: TCP
      port: 4005
      targetPort: 4005
<% } %>

<% if (package.server && options.pdfServerUrl === 'http://pdf-server:4005') { %>
##  API Server | Service
kind: Service
apiVersion: v1
metadata:
  name: api-server
  labels:
    app: api-server
spec:
  selector:
    app: api-server
  ports:
    - name: http
      protocol: TCP
      port: 3000
      targetPort: 3000

---
##  PDF Server | Service
kind: Service
apiVersion: v1
metadata:
  name: pdf-server
  labels:
    app: pdf-server
spec:
  selector:
    app: pdf-server
  ports:
    - name: pdf-server
      protocol: TCP
      port: 4005
      targetPort: 4005

---
##  Nginx | Service
kind: Service
apiVersion: v1
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  selector:
    app: nginx
  ports:
    - name: nginx
      port: 80
      targetPort: 80

<% } %>