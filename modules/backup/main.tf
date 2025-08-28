# Vault
resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-${var.env}-backup-vault"
  kms_key_arn = var.kms_key_arn
  # 실수 방지하려면:
  # lifecycle { prevent_destroy = true }
  tags = { Project = var.project_name, Env = var.env }
}

# Plan
resource "aws_backup_plan" "daily" {
  name = "${var.project_name}-${var.env}-daily-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.schedule_cron
    start_window      = var.start_window_minutes
    completion_window = var.completion_window_minutes

    lifecycle {
      cold_storage_after = var.cold_storage_after_days
      delete_after       = var.retention_days
    }

    dynamic "copy_action" {
      for_each = var.destination_vault_arn == null ? [] : [1]
      content {
        destination_vault_arn = var.destination_vault_arn
        lifecycle { delete_after = var.retention_days }
      }
    }
  }

  tags = { Project = var.project_name, Env = var.env }
}

# Selection: 태그 기반 + (옵션) 리소스 ARN
resource "aws_backup_selection" "selection" {
  name         = "${var.project_name}-${var.env}-selection"
  iam_role_arn = var.iam_role_arn
  plan_id      = aws_backup_plan.daily.id

  # 태그 선택
  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.selection_tag_key
    value = var.selection_tag_value
  }

  # 명시적 ARN도 추가로 포함(있으면)
  resources = var.resource_arns
  
}