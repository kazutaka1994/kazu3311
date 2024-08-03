module "dynamodb" {
  source                  = "./../../../terraform/aws/modules/dynamodb-table-only-hash/"
  dynamodb_table_name     = var.dynamodb_table_name
  dynamodb_billing_mode   = var.dynamodb_billing_mode
  dynamodb_read_capacity  = var.dynamodb_read_capacity
  dynamodb_write_capacity = var.dynamodb_write_capacity
  dynamodb_hash_key       = var.dynamodb_hash_key
  dynamodb_hash_key_type  = var.dynamodb_hash_key_type
}

module "ecr" {
  source               = "./../../../terraform/aws/modules/ecr/"
  image_name           = var.image_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  image_count          = var.image_count
}

module "lambda" {
  source                 = "./../../../terraform/aws/modules/lambda-simple/"
  function_role_name     = var.function_role_name
  function_policy_name   = var.function_policy_name
  function_name          = var.function_name
  image_uri              = module.ecr.ecr_repository_url
  timeout                = var.timeout
  memory_size            = var.memory_size
  ephemeral_storage_size = var.ephemeral_storage_size
  log_format             = var.function_log_format
  cost_metrics_value     = var.cost_metrics_value
  log_retention_in_days  = var.function_log_retention_in_days
  dynamodb_table_name    = module.dynamodb.dynamodb_table_name
}

module "eb-scheduler" {
  source                 = "./../../../terraform/aws/modules/eb-scheduler-lambda/"
  scheduler_role_name    = var.scheduler_role_name
  schdeuler_policy_name  = var.schdeuler_policy_name
  scheduler_name         = var.scheduler_name
  scheduler_state        = var.scheduler_state
  schedule_expression    = var.schedule_expression
  schedule_expression_tz = var.schedule_expression_tz
  flexible_time_window   = var.flexible_time_window
  scheduler_target_arn   = module.lambda.lamba_function_arn
  maximum_retry_attempts = var.maximum_retry_attempts
  maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
}
