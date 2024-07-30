data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "default" {
  name               = var.function_role_name
  assume_role_policy = data.aws_iam_policy_document.default.json
  inline_policy {
    name = var.function_policy_name
    policy = jsonencode({
      "Version" : "2012-10-17"
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.function_name}:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:GetItem"
          ],
          "Resource" : "arn:aws:dynamodb:${local.region}:${local.account_id}:table/${var.dynamodb_table_name}"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ce:GetCostAndUsage"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}

resource "aws_lambda_function" "function" {
  function_name = var.function_name
  role          = aws_iam_role.default.arn
  image_uri     = "${var.image_uri}:latest"
  package_type  = "Image"
  timeout       = var.timeout
  memory_size   = var.memory_size

  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  image_config {
    command = ["lambda_function.lambda_handler"]
  }

  logging_config {
    log_format = var.log_format
  }

  environment {
    variables = {
      COST_METRICS_VALUE = var.cost_metrics_value
      SETTINGS_TABLE     = var.dynamodb_table_name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.log,
    aws_iam_role.default
  ]
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
}