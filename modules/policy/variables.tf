variable "role_arn" {
  description = "The role to attach the policy to"
  type = string
}

variable "resource_arn" {
  description = "The ARN of the resource we're using"
  type        = string
}

variable "default_permissions" {
  description = "IAM Permissions that will be granted whatever the permissions specified are."
  type = list(string)
}

variable "explicit_permissions" {
  description = "Permissions that the user must explicitly state in var.permissions"
  type = map(list(string))
}

variable "permissions" {
  description = "Permissions to grant"
  type        = list(string)
}
