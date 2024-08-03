variable "aws_region" {
  default = "ap-northeast-1"
}

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  type    = number
  default = 1
}
variable "dynamodb_write_capacity" {
  type    = number
  default = 1
}

variable "dynamodb_hash_key" {
  type = string
}
variable "dynamodb_hash_key_type" {
  type = string
}


variable "image_name" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "image_count" {
  type    = number
  default = 3
}

variable "function_role_name" {
  type = string
}

variable "function_policy_name" {
  type = string
}

variable "function_name" {
  type = string
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "ephemeral_storage_size" {
  type    = number
  default = 512
}

variable "function_log_format" {
  type = string
}

variable "cost_metrics_value" {
  type = string
}

variable "function_log_retention_in_days" {
  type    = number
  default = 30
}

variable "scheduler_role_name" {
  type = string
}

variable "schdeuler_policy_name" {
  type = string
}

variable "scheduler_name" {
  type = string
}

variable "scheduler_state" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "schedule_expression_tz" {
  type = string
}

variable "flexible_time_window" {
  type = string
}

variable "maximum_retry_attempts" {
  type = number
  default = 0
}

variable "maximum_event_age_in_seconds" {
  type = number
  default = 60
}