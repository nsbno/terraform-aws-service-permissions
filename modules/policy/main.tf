data "aws_iam_policy_document" "this" {
  statement {
    effect = "allow"

    resources = [var.role_arn]

    actions = flatten([
      # All uses of this permissions will always get the default permissions.
      # This makes for less setup for the end user
      var.default_permissions,
      # By looking up the permissions this way, we get free error checking.
      # If the user uses a permission that does not exist, they will get an error.
      # This is an OK solution for terraform lack of proper argument validation.
      flatten([
        for permission in var.permissions :
          var.explicit_permissions[permission]
      ])
    ])
  }
}

resource "aws_iam_role_policy" "this" {
  role   = var.role_arn
  policy = data.aws_iam_policy_document.this.json
}
