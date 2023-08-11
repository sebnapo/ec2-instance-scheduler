data "aws_iam_policy_document" "assume_role_policy_lambda" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "assume_role_policy_scheduler" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "assume_role_policy_scheduler_execution" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["scheduler.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy_start_instances" {
  statement {
    sid     = "Ec2StartInstancesPolicy"
    effect  = "Allow"
    actions = [
      "ec2:StartInstances"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*"
    ]
  }

  statement {
    sid     = "LambdaLoggingPolicy"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "policy_stop_instances" {
  statement {
    sid     = "Ec2StopInstancesPolicy"
    effect  = "Allow"
    actions = [
      "ec2:StopInstances"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*"
    ]
  }

  statement {
    sid     = "LambdaLoggingPolicy"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "policy_execute_schedule" {
  statement {
    sid     = "Ec2StartInstancesPolicy"
    effect  = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:eu-west-1:${var.aws_deploy_account_number}:function:start-ec2-instances",
      "arn:aws:lambda:eu-west-1:${var.aws_deploy_account_number}:function:stop-ec2-instances"
    ]
  }

  statement {
    sid     = "LambdaLoggingPolicy"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "policy_create_schedule" {
  statement {
    sid     = "Ec2StartInstancesPolicy"
    effect  = "Allow"
    actions = [
      "scheduler:CreateSchedule"
    ]
    resources = [
      "arn:aws:scheduler:${var.region}:${var.aws_deploy_account_number}:schedule/default/ec2-schedule-*"
    ]
  }
  statement {
    sid     = "IamPassRolePolicy"
    effect  = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::${var.aws_deploy_account_number}:role/lambda-execute-schedule-ec2-role"
    ]
  }
  statement {
    sid     = "LambdaLoggingPolicy"
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role" "iam_for_lambda_start_instances" {
  name               = "lambda-stop-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json
}

resource "aws_iam_role_policy" "lambda_policy_start_instances" {
  policy = data.aws_iam_policy_document.policy_start_instances.json
  role   = aws_iam_role.iam_for_lambda_start_instances.id
}

resource "aws_iam_role" "iam_for_lambda_stop_instances" {
  name               = "lambda-start-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_lambda.json
}

resource "aws_iam_role_policy" "lambda_policy_stop_instances" {
  policy = data.aws_iam_policy_document.policy_stop_instances.json
  role   = aws_iam_role.iam_for_lambda_stop_instances.id
}

resource "aws_iam_role" "iam_for_lambda_create_schedule" {
  name               = "lambda-create-schedule-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_scheduler.json
}

resource "aws_iam_role_policy" "lambda_policy_create_schedule" {
  policy = data.aws_iam_policy_document.policy_create_schedule.json
  role   = aws_iam_role.iam_for_lambda_create_schedule.id
}

resource "aws_iam_role" "iam_for_lambda_execute_schedule" {
  name               = "lambda-execute-schedule-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_scheduler_execution.json
}

resource "aws_iam_role_policy" "lambda_policy_execute_schedule" {
  policy = data.aws_iam_policy_document.policy_execute_schedule.json
  role   = aws_iam_role.iam_for_lambda_execute_schedule.id
}