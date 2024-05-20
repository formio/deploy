resource "aws_elastic_beanstalk_application" "formio-app" {
  name = "formio-app"

}
resource "aws_elastic_beanstalk_application_version" "formio-app-version" {
  name        = "formio-app-version-${var.app_version}"
  application = aws_elastic_beanstalk_application.formio-app.name
  description = "formio app version"
  bucket      = aws_s3_object.deployment_bundle.bucket
  key         = aws_s3_object.deployment_bundle.key
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "formio-app-env"
  application         = aws_elastic_beanstalk_application.formio-app.name
  description         = "formio app"
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.0 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.formio-app-version.name
  ##################### VPC Settings ##################### 
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private_subnets)
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ElbSubnets"
    value     = join(",", var.public_subnets)
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  ##################### Launch Configuration Settings #####################
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.private_security_group_id
    resource  = ""
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
    resource  = ""
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp2"
    resource  = ""
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = "12"
    resource  = ""
  }


  ##################### AutoScaling Settings #####################
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.asg_min_count
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.asg_max_count
    resource  = ""
  }


  ##################### EB Environment Settings #####################
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.service_role.id
    resource  = ""
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
    resource  = ""
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health"
  }

  ##################### Environment Variables #####################
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MONGO"
    value     = var.db_connection_string
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "JWT_SECRET"
    value     = var.jwt_secret
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ADMIN_EMAIL"
    value     = var.admin_email
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ADMIN_PASS"
    value     = var.admin_password
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PDF_SERVER"
    value     = var.pdf_server
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORTAL_ENABLED"
    value     = var.portal_enabled
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = var.port
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LICENSE_KEY"
    value     = var.formio_license_key
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MONGO_CA"
    value     = "/data/global-bundle.pem"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FORMIO_S3_BUCKET"
    value     = var.pdf_s3_bucket
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEBUG"
    value     = "*.*"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FORMIO_S3_REGION"
    value     = var.s3_region
  }



}
output "eb_deployment_source" {
  value = "${aws_elastic_beanstalk_application_version.formio-app-version.bucket}/${aws_elastic_beanstalk_application_version.formio-app-version.key}"
}

output "archive_file_path" {
  value = data.archive_file.deployment_zip.output_path

}