resource "aws_s3_bucket" "builds" {
  bucket = "ec2-scheduler-lambda-packages-${var.deploy_account}"
}