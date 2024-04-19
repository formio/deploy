This is the application bundle the terraform script will zip and push to s3 during deployment.

## Contents
* docker-compose.yml -- docker compose file that includes entries for 
    * api-server
    * pdf-server
    * minio
    * nginx

## Environment Variables
For environment variables that need to be passed into the containers inside the elastic beanstalk instance, Elastic beanstalk will generate a `.env` file during deployment.  The docker-compose file referenences this .env file to make them availble to the application servers.  Any other environment variables should be defined as an elastic beanstalk environment variable.  They should not be referenced in the docker-compose.yml file.  
