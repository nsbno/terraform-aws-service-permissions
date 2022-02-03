terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

/*
 * == SQS Queue Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonsqs.html
 */
module "sqs_queue" {
  source = "modules/policy"

  default_permissions = ["sqs:GetQueueAttributes"]
  explicit_permissions = {
    receive = ["sqs:ReceiveMessage"]
    send = ["sqs:SendMessage"]
    delete = ["sqs:DeleteMessage"]
  }

  for_each = { for value in var.sqs_queues : value.arn => value.permissions }

  role_arn = var.role_arn

  resource_arns = [each.key]
  permissions = each.value
}

/*
 * == SNS Topic Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonsns.html
 */
module "sns_topic" {
  source = "modules/policy"

  default_permissions = ["sqs:GetQueueAttributes"]
  explicit_permissions = {
    publish = ["sns:Publish"]
    subscription = [
      "sns:Subscribe",
      "sns:ConfirmSubscription",
      "sns:Unsubscribe",
    ]
  }

  for_each = { for value in var.sns_topics : value.arn => value.permissions }

  role_arn = var.role_arn

  resource_arns = [each.key]
  permissions = each.value
}

/*
 * == S3 Bucket Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazons3.html
 */
module "s3_bucket" {
  source = "modules/policy"

  default_permissions  = [
    # Allow users to see which region the bucket is in.
    # There isn't really any risk to this.
    "s3:GetBucketLocation",
    # Listing is quite often needed.
    # Though it does potentially give a malicious actor the ability to see what
    # kind of data is in the bucket. However, this is such a small risk, that
    # we'll blanket allow it.
    "s3:ListBucket"
  ]
  explicit_permissions = {
    get = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    put = [
      "s3:PutObject"
    ]
    delete = [
      "s3:DeleteObject"
    ]
  }

  for_each = {for value in var.s3_buckets : value.arn => value.permissions}

  role_arn = var.role_arn

  resource_arns = concat([each.key], formatlist("%s/*", [each.key]))
  permissions  = each.value
}
