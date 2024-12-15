
#provider "aws" {
#  region = "eu-central-1"
#}

variable "trainees" {
  type    = list(string)
  default = ["train-000", "train-001", "train-002", "train-003","train-004", "train-005"] # Replace with trainee names
}

# Permission Boundary Policy
resource "aws_iam_policy" "permission_boundary" {
  name        = "TraineePermissionBoundary"
  description = "Restrict IAM actions for trainees"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DenyIAMPermissions",
        Effect = "Deny",
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:UpdateUser",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:UpdatePolicy"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowAllOtherActions",
        Effect = "Allow",
        Action = "*",
        Resource = "*"
      }
    ]
  })
}

# Create IAM Users
resource "aws_iam_user" "trainees" {
  for_each = toset(var.trainees)

  name = each.value
  permissions_boundary = aws_iam_policy.permission_boundary.arn
  tags = {
    Owner = each.value
  }
}

# Attach Permission Boundary to Users
# resource "aws_iam_user_policy_attachment" "permission_boundary" {
#  for_each            = aws_iam_user.trainees
#  user                = each.value.name
#  permissions_boundary = aws_iam_policy.permission_boundary.arn
#}

# IAM Policy for Resource Management
resource "aws_iam_policy" "trainee_management_policy" {
  name        = "TraineeManagementPolicy"
  description = "Allows trainees to manage resources with tag restrictions"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "*",
        Resource  = "*",
        Condition = {
          StringEqualsIfExists = {
            "aws:RequestTag/Owner": "aws:username"
          }
        }
      }
    ]
  })
}

# Attach Resource Management Policy to Users
resource "aws_iam_user_policy_attachment" "trainee_policy_attachment" {
  for_each = aws_iam_user.trainees

  user       = each.value.name
  policy_arn = aws_iam_policy.trainee_management_policy.arn
}

# Create Access Keys for Programmatic Access
resource "aws_iam_access_key" "trainee_keys" {
  for_each = aws_iam_user.trainees

  user = each.value.name
}

# Output Access Keys (Be careful with security!)
output "trainee_access_keys" {
  value = {
    for name, key in aws_iam_access_key.trainee_keys :
    name => {
      access_key = key.id
      secret_key = key.secret
    }
  }

  sensitive = true
}

