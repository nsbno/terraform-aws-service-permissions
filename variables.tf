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
