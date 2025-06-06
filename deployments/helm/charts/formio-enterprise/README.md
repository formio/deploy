# formio-enterprise

A chart for a Form.io Enterprise deployment

## **Values**

You will need to create a yaml file to define and override certain values used by this chart. When you’re ready to deploy the chart onto your cluster, you’ll run: `helm install {your-chart-dir-or-zip} {your-release-name} --namespace {your-formio-namespace} -f {your-custom-values-overrides-file.yaml}` where the values in your custom values file will override values in the base `Values.yaml` file. An example custom values file is provided at the end of this readme. 

### Use different versions

The default versions used for this chart are:

- [formio/formio-enterprise (API server) 9.5.0](https://hub.docker.com/layers/formio/formio-enterprise/9.5.0/images/sha256-b87bd9bd20ae55e9f714973b7845959c2c1c936578e1c28f18754ba918f832f7)
- [formio/pdf-server (PDF server) 5.10.15](https://hub.docker.com/layers/formio/pdf-server/5.10.15/images/sha256-440aca6dbd5b963e30fe8fec662f515c97ca58f74681f308299d53cd9201ff88)

To modify the API or PDF server versions used in this chart, specify different versions of the images using the `api.image.tag` and `pdf.image.tag` parameters. The default pull policy used for both images is `IfNotPresent`. 

### **Notes:**

1. Non-sensitive container environment variables for the API and PDF servers will be defined in your custom values file in one of three blocks: `api.env`, `pdf.env` or `common.env`. Variables shared between the API and PDF servers are defined in `common.env`.
    1. Known variables will be defined in camel case in your values file, but will be converted to upper + snake case before being passed into their respective containers. So, `portalEnabled` becomes `PORTAL_ENABLED`, and `formioS3Bucket` becomes `FORMIO_S3_BUCKET`.
    2. You can also pass environment variables directly into either container with the `extraVars` property (i.e. `api.env.extraVars`) in the following format (note the snake + upper casing since they are passed directly to the container):
        
        ```yaml
        api:
          env:
            portalEnabled: true
            ...
            extraVars: 
              - name: CUSTOM_VAR
                value: "somestring"
              - ...
        ```
        
2. See [this documentation](https://help.form.io/deployments/deployment-guide/enterprise-server#environment-variables) for API server environment variables.
    1. If using the PDF server, the API server’s `PDF_SERVER` env var will default to the PDF [service DNS name](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) if not provided and is therefore not required in this chart unless a different DNS configuration is used.
3. Use of the PDF server is optional. See [this documentation](https://help.form.io/deployments/deployment-guide/pdf-server#environment-variables-for-deployment) for PDF server environment variables.
4. Sensitive environment variables (both required and optional) are defined in the `secret` block. You can either create and manage a single Kubernetes secret (for both API and PDF servers) yourself, or allow the chart to create one for you. In either case, you should specify `secret.name` (the name of the K8s secret resource). To use an existing secret, all you need to do is set `secret.name` and `secret.existingSecret` to `true`: 
    
    ```yaml
    secret:
      name: formio-enterprise-secret
      existingSecret: true
    ```
    
    You then need to ensure your existing secret has the following required keys: 
    
    - Common secret keys: `mongo`, `licenseKey`, and `dbSecret`.
    - API server: `portalSecret`, `adminPass`, and `jwtSecret`.
    - PDF server: none are required in all scenarios, but depending on the file storage provider being used: `formioS3Key` and `formioS3Secret` (for all S3-compatible storage solutions) or `formioAzureContainer` and `formioAzureConnectionString` for Azure.
    - You’re existing secret (whether external or not) should look something like this, with all keys defined at the same level:
        
        ```yaml
        apiVersion: v1
        kind: Secret
        metadata:
          name: formio-enterprise-secret # secret.name in custom values
          namespace: formio # whatever your formio deployment namespace is
        type: Opaque
        data:
          mongo: ...
          licenseKey: ...
          dbSecret: ...
          portalSecret: ...
          ...
          formioS3Secret: ...
          ...
        ```
        
    - If there is a secret key that does not exist in the base values file that you would like to include, you can specify `extraExistingKeys` for the given category. This will let the chart know that **your existing secret has these additional keys** that should be passed as env vars to one or both of the containers.
        
        ```yaml
        secret:
          name: formio-enterprise-secret
          existingSecret: true
          common:
            extraExistingKeys: 
              - customSecretKey
              - anotherKey
          api:
            extraExistingKeys: 
              - customApiSecretKey
              - anotherApiKey
          ...
        ```
        
    
    If you opt to have the chart create a secret for you, you need to specify the keys and values in your values file like this:
    
    ```yaml
    secret:
      name: formio-enterprise-secret
      existingSecret: false
      common:
        mongo: "mongodb://..." # required
        licenseKey: "eyJhbG..." # required
        dbSecret: "CHANGEME" # required
      api:
        portalSecret: "CHANGEME" # required
        adminPass: "CHANGEME" # required
        jwtSecret: "CHANGEME" # required
      pdf:
        formioPdfAdminkey: "CHANGEME" # optional
        formioS3Key: "AKIAYG..." # required for S3-compatible file storage
        formioS3Secret: "M8icd00.../o2f..." # required for S3-compatible file storage
    ```
    
    For any secret keys not defined in the base values file, you can pass in `extraVars` to any secret category (when the chart is creating the secret for you) like this:
    
    ```yaml
    secret:
      name: formio-enterprise-secret
      existingSecret: false
      common:
        mongo: "mongodb://..." # required
        licenseKey: "eyJhbG..." # required
        dbSecret: "CHANGEME" # required
      api:
        portalSecret: "CHANGEME" # required
        adminPass: "CHANGEME" # required
        jwtSecret: "CHANGEME" # required
        extraVars:
          - name: EXTRA_API_VAR
            value: "somestring"
      pdf:
        formioPdfAdminkey: "CHANGEME" # optional
        formioS3Key: "AKIAYG..." # required for S3-compatible file storage
        formioS3Secret: "M8icd00.../o2f..." 
    ```
    

## **PDF Server File Storage Configurations**

If your deployment contains a PDF server, here are some file storage configuration options depending on your deployment environment/cloud provider. To specify the storage solution being used, set `pdf.env.fileStorageProviderName` to `“aws”`, `"azure"`, `"gcp"`, or `"minio"`. S3-named variables refer to any S3-compatible storage solution. Here are links to general documentation on file storage configuration in [Form.io](http://Form.io):

- [AWS, Azure, Minio](https://help.form.io/deployments/deployment-guide/pdf-server#file-storage-environment-variables)
- [GCP](https://help.form.io/deployments/deployment-guide/cloud-deployment/gcp-deployment/gcp-cloud-run#pdf-server-deployment) (scroll to section on PDF server environment variables)

### **AWS S3**

```yaml
secret:
	name: formio-enterprise-secret
  existingSecret: false
  pdf:
    formioS3Key: faR6Utb0sGi1fyIpLhN6
    formioS3Secret: DurHQbg5JpsmzaLrhQftSWfH5PaZ13XBTpXpo2Oc  
  ...

pdf:
  fileStorageProviderName: aws
  env:
    formioS3Bucket: demo-bucket
    formioS3Region: us-west-1
  ...
```

### **Azure Blob Storage**

```yaml
secret:
	name: formio-enterprise-secret
  existingSecret: false
  pdf:
    formioAzureConnectionString: DefaultEndpointsProtocol=https;AccountName=<accountname>;AccountKey=<accountkey>
    formioAzureContainer: demo-container    
  ...
  
pdf:
  fileStorageProviderName: azure
  ...
	  
```

### GCP GCS

```yaml
secret:
	name: formio-enterprise-secret
  existingSecret: false
  pdf:
    formioS3Key: G00GaR6Utb0sGi1fyIpLhM7
    formioS3Secret: SrB4PkZzv+xJPXpyc9/hQrDdo4gtTk3xPJpMQAZm
  ...

pdf:
	fileStorageProviderName: gcp
  env:
	  formioS3Bucket: demo-bucket
	  formioS3Server: https://storage.googleapis.com
  ...
```

### Minio

```yaml
secret:
	name: formio-enterprise-secret
  existingSecret: false
  pdf:
    formioS3Key: daK6Utb0sGi1fyIpLhP8
    formioS3Secret: ArB4PkZzv+xJPXpyc9/hFrDdo4gtTk3xKJpMQAZn
  ...

pdf:
  fileStorageProviderName: minio
  env:
	  formioS3Bucket: demo-bucket
	  formioS3Server: https://yourminioserverurl.com
	  formioS3Port: 9000
  ...
```

## Example Custom Values File

```yaml
secret:
  name: formio-enterprise-secret
  existingSecret: false
  common:
    mongo: "mongodb://..."
    licenseKey: "eyJhb..."
    dbSecret: "CHANGEME"
  api:
    portalSecret: "CHANGEME"
    adminPass: "CHANGEME"
    jwtSecret: "CHANGEME"
  pdf:
    formioPdfAdminkey: "CHANGEME"
    formioS3Key: "AKIA..."
    formioS3Secret: "N8icd.../o2..."

common:
  env:
    licenseRemote: true

api:
  image:
    tag: "9.5.0"
  env:
    portalEnabled: true
    adminEmail: admin@example.com
    debug: formio.*
  service:
    type: LoadBalancer
    port: 80
  ingress:
    enabled: true
    className: ""
    hosts:
      - host: ""
        path: /
        pathType: Prefix
    tls: []

pdf:
  enabled: true
  image:
    tag: "5.10.15"
  fileStorageProviderName: aws
  env:
    formioS3Bucket: dev-bucket
    formioS3Region: us-east-2   
    debug: pdf.*
```