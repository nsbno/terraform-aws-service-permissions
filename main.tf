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

  role_name = var.role_name

  count = length(var.sqs_queues)
  resource_arns = var.sqs_queues[count.index].arns
  permissions   = var.sqs_queues[count.index].permissions
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

  role_name = var.role_name

  count = length(var.sns_topics)
  resource_arns = var.sns_topics[count.index].arns
  permissions   = var.sns_topics[count.index].permissions
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

  role_name = var.role_name

  count = length(var.s3_buckets)
  resource_arns = concat(var.s3_buckets[count.index].arns, formatlist("%s/*", var.s3_buckets[count.index].arns))
  permissions   = var.s3_buckets[count.index].permissions
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

  role_name = var.role_name

  count = length(var.dynamodb_tables)
  resource_arns = var.dynamodb_tables[count.index].arns
  permissions   = var.dynamodb_tables[count.index].permissions
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

  role_name = var.role_name

  count = length(var.kms_keys)
  resource_arns = var.kms_keys[count.index].arns
  permissions   = var.kms_keys[count.index].permissions
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

  role_name = var.role_name

  count = length(var.ssm_parameters)
  resource_arns = var.ssm_parameters[count.index].arns
  permissions   = var.ssm_parameters[count.index].permissions
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

  role_name = var.role_name

  count = length(var.cloudwatch_metrics)
  resource_arns = var.cloudwatch_metrics[count.index].arns
  permissions   = var.cloudwatch_metrics[count.index].permissions
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

  role_name = var.role_name

  count = length(var.secrets_manager)
  resource_arns = var.secrets_manager[count.index].arns
  permissions   = var.secrets_manager[count.index].permissions
}
