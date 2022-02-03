variable "role_arn" {
  description = "The role to attach the permissions to"
  type = string
}

variable "sqs_queues" {
  description = "Permissions for SQS resources"
  type = list(object({
    arn = string
    permissions = list(string)
  }))
}

variable "sns_topics" {
  description = "Permissions for SNS Topics"
  type = list(object({
    arn = string
    permissions = list(string)
  }))
}

variable "s3_buckets" {
  description = "Permissions for S3 buckets"
  type = list(object({
    arn = string
    permissions = list(string)
  }))
}

variable "dynamodb_tables" {
  description = "Permissions for DynamoDB Tables"
  type = list(object({
    arn = string
    permissions = list(string)
  }))
}

variable "kms_keys" {
  description = "Permissions for KMS Keys"
  type = list(object({
    arn = string
    permissions = list(string)
  }))
}
