terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

data "aws_iam_policy_document" "this" {}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.this.json
}

module "permissions" {
  source = "../../"

  role_name = aws_iam_role.this.name
}
