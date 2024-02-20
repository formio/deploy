APP_ENV=development
<% if (package.server) { %>
API_IMAGE=<%- package.server %>
<% } %>
<% if (package.pdf) { %>
PDF_IMAGE=<%- package.pdf %>
<% } %>

LICENSE_KEY=<%- options.license %>
MONGO=""
<% if (package.server) { %>
PORT=3000
<% if (options.portal) { %>
PORTAL_ENABLED=1
<% } else { %>
PORTAL_SECRET=<%- options.portalSecret %>
<% } %>
ADMIN_EMAIL=<%- options.adminEmail %>
ADMIN_PASS=<%- options.adminPass %>
<% if (options.dbSecret) { %>
DB_SECRET=<%- options.dbSecret %>
<% } else { %>
DB_SECRET=CHANGEME
<% } %>
<% if (options.jwtSecret) { %>
JWT_SECRET=<%- options.jwtSecret %>
<% } else { %>
JWT_SECRET=CHANGEME
<% } %>
BASE_URL=<%- options.baseUrl %>
PDF_SERVER=<%- options.pdfServerUrl %>
<% } %>

<% if (package.pdf && package.azure) { %>
## Azure Blob
FORMIO_AZURE_CONNECTION_STRING=
FORMIO_AZURE_CONTAINER=
<% } %>

<% if (package.pdf && package.aws) { %>
## AWS S3 Bucket Settings
FORMIO_S3_KEY=
FORMIO_S3_SECRET=
FORMIO_S3_BUCKET=formio-files
FORMIO_S3_REGION=us-east-1

## Only required if utilizing Textract Field Recognition
# TEXTRACT_OUTPUT_FOLDER=textract
# TEXTRACT_ROLE_ARN=
# TEXTRACT_SNS_TOPIC_ARN=
<% } %>