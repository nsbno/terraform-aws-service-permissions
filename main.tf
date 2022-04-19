terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0, < 4.0.0"
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
  source = "./modules/policy"

  default_permissions = ["sqs:GetQueueAttributes"]
  explicit_permissions = {
    receive = ["sqs:ReceiveMessage"]
    send    = ["sqs:SendMessage"]
    delete  = ["sqs:DeleteMessage"]
  }

  for_each = { for value in var.sqs_queues : index(var.sqs_queues, value) => value }

  role_name = var.role_name

  resource_arns = each.value.arns
  permissions   = each.value.permissions
}

/*
 * == SNS Topic Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonsns.html
 */
module "sns_topic" {
  source = "./modules/policy"

  default_permissions = ["sqs:GetQueueAttributes"]
  explicit_permissions = {
    publish = ["sns:Publish"]
    subscription = [
      "sns:Subscribe",
      "sns:ConfirmSubscription",
      "sns:Unsubscribe",
    ]
  }

  for_each = { for value in var.sns_topics : index(var.sns_topics, value) => value }

  role_name = var.role_name

  resource_arns = each.value.arns
  permissions   = each.value.permissions
}

/*
 * == S3 Bucket Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazons3.html
 */
module "s3_bucket" {
  source = "./modules/policy"

  default_permissions = [
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

  for_each = { for value in var.s3_buckets : index(var.s3_buckets, value) => value }

  role_name = var.role_name

  resource_arns = concat(each.value.arns, formatlist("%s/*", each.value.arns))
  permissions   = each.value.permissions
}

/*
 * == DynamoDB Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazondynamodb.html
 */
module "dynamodb_table" {
  source = "./modules/policy"

  default_permissions = []
  explicit_permissions = {
    get = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    put = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
    delete = [
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
    ]
  }

  for_each = { for value in var.dynamodb_tables : index(var.dynamodb_tables, value) => value }

  role_name = var.role_name

  resource_arns = each.value.arns
  permissions   = each.value.permissions
}

/*
 * == KMS Key Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_awskeymanagementservice.html
 */
module "kms_key" {
  source = "./modules/policy"

  default_permissions = [
    # Allow for services to see details about the key.
    # Shouldn't really give any surface area.
    "kms:DescribeKey"
  ]
  explicit_permissions = {
    data_key = [
      "kms:GenerateDataKey*"
    ]
    decrypt = [
      "kms:Decrypt"
    ]
    encrypt = [
      "kms:Encrypt"
    ]
  }

  for_each = { for value in var.kms_keys : index(var.kms_keys, value) => value }

  role_name = var.role_name

  resource_arns = each.value.arns
  permissions   = each.value.permissions
}

/*
 * == SSM Parameter Store Permissions
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_awssystemsmanager.html
 */
module "ssm_parameter_store" {
  source = "./modules/policy"

  default_permissions = []
  explicit_permissions = {
    get = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath"
    ]

    put = [
      "ssm:PutParameter"
    ]

    delete = [
      "ssm:DeleteParameter",
      "ssm:DeleteParameters",
    ]
  }

  for_each = { for value in var.ssm_parameters : index(var.ssm_parameters, value) => value }

  role_name = var.role_name

  resource_arns = each.value.arns
  permissions   = each.value.permissions
}

/*
 * == CloudWatch Metrics
 *
 * These endpoints don't care about the given ARN.
 * But we let the user pass in an ARN to keep a consistent API.
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazoncloudwatch.html
 */
module "cloudwatch_metrics" {
  source = "./modules/policy"

  default_permissions = []
  explicit_permissions = {
    get = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
    ]

    put = [
      "cloudwatch:PutMetricData"
    ]
  }

  for_each = { for value in var.cloudwatch_metrics : index(var.cloudwatch_metrics, value) => value }

  role_name = var.role_name

  resource_arns = each.value.arns
  permissions   = each.value.permissions
}

/*
 * == Secrets Manager
 *
 * Reference to available permissions can be found in the AWS docs:
 * https://docs.aws.amazon.com/service-authorization/latest/reference/list_awssecretsmanager.html
 */
module "secrets_manager" {
  source = "./modules/policy"

  default_permissions = [
  ]
  explicit_permissions = {
    get = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]

    create = [
      "secretsmanager:CreateSecret"
    ]

    manage = [
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:RotateSecret",
      "secretsmanager:CancelRotateSecret",
      "secretsmanager:GetRandomPassword",
    ]

    delete = [
      "secretsmanager:DeleteSecret",
      "secretsmanager:RestoreSecret"
    ]
  }

  for_each = { for value in var.secrets_manager : index(var.secrets_manager, value) => value }

  role_name = var.role_name

  resource_arns = each.value.arns
  permissions   = each.value.permissions
}
