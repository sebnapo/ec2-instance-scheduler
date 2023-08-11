module "start_ec2_instances" {
  source = "./modules/lambda"

  environment            = var.deploy_account
  function_name          = "start-ec2-instances"
  handler_name           = "src.start_ec2_instances_handler.lambda_handler"
  lambda_package         = "../${path.root}/lambda.zip"
  s3_bucket_id           = aws_s3_bucket.builds.id
  lambda_environment_var = {
    "REGION" = var.region
  }

  lambda_role_arn = aws_iam_role.iam_for_lambda_start_instances.arn
}

module "stop_ec2_instances" {
  source = "./modules/lambda"

  environment            = var.deploy_account
  function_name          = "stop-ec2-instances"
  handler_name           = "src.stop_ec2_instances_handler.lambda_handler"
  lambda_package         = "../${path.root}/lambda.zip"
  s3_bucket_id           = aws_s3_bucket.builds.id
  lambda_environment_var = {
    "REGION" = var.region
  }

  lambda_role_arn = aws_iam_role.iam_for_lambda_stop_instances.arn
}

module "create_schedule" {
  source = "./modules/lambda"

  environment            = var.deploy_account
  function_name          = "create-schedule"
  handler_name           = "src.create_ec2_schedule_handler.lambda_handler"
  lambda_package         = "../${path.root}/lambda.zip"
  s3_bucket_id           = aws_s3_bucket.builds.id
  lambda_environment_var = {
    "REGION"                    = var.region,
    "START_EC2_LAMBDA_ARN"      = module.start_ec2_instances.lambda_arn,
    "STOP_EC2_LAMBDA_ARN"       = module.stop_ec2_instances.lambda_arn,
    "EXECUTE_SCHEDULE_ROLE_ARN" = aws_iam_role.iam_for_lambda_execute_schedule.arn,
  }

  lambda_role_arn = aws_iam_role.iam_for_lambda_create_schedule.arn
}