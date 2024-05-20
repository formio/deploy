data "aws_iam_policy_document" "ec2_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eb_ec2_role" {
  name               = "eb_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_role.json

}
resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "eb_instance_profile"
  role = aws_iam_role.eb_ec2_role.name
}



resource "aws_iam_role_policy_attachment" "eb_WebTier_policy" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
resource "aws_iam_role_policy_attachment" "eb_WorkerTier_policy" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}


resource "aws_iam_role_policy_attachment" "eb_multicontinter_docker_policy" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

data "aws_iam_policy_document" "eb_service_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["elasticbeanstalk.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}
resource "aws_iam_role" "service_role" {
  name               = "formio-ebs-service-role"
  assume_role_policy = data.aws_iam_policy_document.eb_service_role.json
}
resource "aws_iam_role_policy_attachment" "eb_health_policy" {
  role       = aws_iam_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}
resource "aws_iam_role_policy_attachment" "eb_service_policy" {
  role       = aws_iam_role.service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}
resource "aws_iam_role_policy_attachment" "eb_s3_policy" {
  role       = aws_iam_instance_profile.eb_instance_profile.role
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_security_group" "eb_app_sg" {
  vpc_id = var.vpc_id
  name   = "formio-eb-app-sg"
}
