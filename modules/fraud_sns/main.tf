# SNS Topic
resource "aws_sns_topic" "fraud-notification" {
  name = "${var.project_name}-${var.env}-fraud-notification"
}
