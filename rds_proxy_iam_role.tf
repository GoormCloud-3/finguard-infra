# RDS Proxy
data "aws_iam_policy_document" "rds_proxy_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]  # ← 핵심 포인트
    }
  }
}

data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}

data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}

data "aws_iam_policy_document" "rds_proxy_secret_access" {
  statement {
    sid     = "SecretsManagerAccess"
    effect  = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [ 
      aws_secretsmanager_secret.rds_secret.arn
    ]
  }

  statement {
    sid     = "KMSDecryptForSecretsAndSSM"
    effect  = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      data.aws_kms_key.secretsmanager.arn,
      data.aws_kms_key.ssm.arn
    ]
  }
}

# RDS Proxy Role
resource "aws_iam_role" "rds_proxy_secret_access" {
  name = "${var.project_name}-rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json
}

resource "aws_iam_policy" "rds_secret_access" {
  name = "${var.project_name}-secret-access"
  policy = data.aws_iam_policy_document.rds_proxy_secret_access.json
}

resource "aws_iam_role_policy_attachment" "secret_attach" {
  role = aws_iam_role.rds_proxy_secret_access.name
  policy_arn = aws_iam_policy.rds_secret_access.arn
}