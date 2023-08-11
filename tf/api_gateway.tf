resource "aws_api_gateway_rest_api" "ec2_provisionning_api" {
  name = "ec2_provisionning_api"
}
resource "aws_api_gateway_resource" "provision_resource" {
  rest_api_id = aws_api_gateway_rest_api.ec2_provisionning_api.id
  parent_id   = aws_api_gateway_rest_api.ec2_provisionning_api.root_resource_id
  path_part   = "provision"
}
resource "aws_api_gateway_method" "provision_method" {
  rest_api_id   = aws_api_gateway_rest_api.ec2_provisionning_api.id
  resource_id   = aws_api_gateway_resource.provision_resource.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.ec2_provisionning_api.id
  resource_id             = aws_api_gateway_resource.provision_resource.id
  http_method             = aws_api_gateway_method.provision_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${module.create_schedule.lambda_arn}/invocations"
}
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.create_schedule.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.aws_deploy_account_number}:${aws_api_gateway_rest_api.ec2_provisionning_api.id}/*/${aws_api_gateway_method.provision_method.http_method}${aws_api_gateway_resource.provision_resource.path}"
}
resource "aws_api_gateway_deployment" "provision_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ec2_provisionning_api.id
  triggers    = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ec2_provisionning_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.provision_method, aws_api_gateway_integration.integration]
}


resource "aws_api_gateway_stage" "provision_stage" {
  deployment_id = aws_api_gateway_deployment.provision_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ec2_provisionning_api.id
  stage_name    = var.deploy_account
}