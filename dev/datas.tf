data "aws_s3_bucket" "selected" {
  bucket = "finguard-model-artifacts"
}
# Terraform이 plan/apply를 할 때, AWS에 가서 "finguard-model-artifacts" 라는 이미 존재하는 버킷을 조회합니다.
# 그 뒤 이 블록은 버킷 속성들을 제공