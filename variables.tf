variable "role_name" {
  description = "The role to attach the permissions to"
  type = string
}

variable "sqs_queues" {
  description = "Permissions for SQS resources"
  type = list(object({
    arn = string
    permissions = list(string)
  }))

  default = []
}

variable "sns_topics" {
  description = "Permissions for SNS Topics"
  type = list(object({
    arn = string
    permissions = list(string)
  }))

  default = []
}

variable "s3_buckets" {
  description = "Permissions for S3 buckets"
  type = list(object({
    arn = string
    permissions = list(string)
  }))

  default = []
}

variable "dynamodb_tables" {
  description = "Permissions for DynamoDB Tables"
  type = list(object({
    arn = string
    permissions = list(string)
  }))

  default = []
}

variable "kms_keys" {
  description = "Permissions for KMS Keys"
  type = list(object({
    arn = string
    permissions = list(string)
  }))

  default = []
}

variable "ssm_parameters" {
  description = "Permissions for SSM Parameters"
  type = list(object({
    arn = string
    permissions = list(string)
  }))

  default = []
}

variable "cloudwatch_metrics" {
  description = "Permissions for CloudWatch Metrics. These endpoints don't care about the ARN, so * is recommended."
  type = list(object({
    arn = string
    permissions = list(string)
  }))

  default = []
}
