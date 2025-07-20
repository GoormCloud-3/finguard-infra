# FinGuard-Infra

금융 거래 이상 탐지를 위한 클라우드 기반 인프라를 Terraform으로 관리합니다.  
모듈화를 통해 서비스별 리소스를 명확히 분리하였으며, 개발/운영 환경은 디렉토리 단위로 분리되어 있습니다.

---

## 디렉터리 구조
```
/dev # 개발 환경용 Terraform 설정  
/main # 운영 환경(prod) 설정  
/modules # 공통 모듈 정의 디렉토리  
├── iam # IAM 역할 및 정책 공통 관리 모듈  
├── network # VPC, 서브넷, 라우팅 테이블 등 네트워크 공통 리소스 관리 모듈  
├── finance_caching # ElastiCache 구성  
├── finance_db # RDS 및 관련 설정  
├── finance_db_proxy # RDS Proxy 구성  
├── finance_ml # SageMaker 및 ML 추론 관련 리소스  
├── finance_noti_table # DynamoDB 기반 알림 테이블 구성  
├── finance_trading_queue# SQS 기반 거래 처리 큐 구성  
└── fraud_sns # 의심 거래 발생 시 알림용 SNS 구성

```

---

## 공통 리소스 관리 전략

- `/modules/iam`
	- 서비스 전반에서 사용하는 IAM Role, Policy, Instance Profile 등을 중앙에서 정의합니다.
	- 최소 권한 원칙을 기반으로 리소스 접근을 제어합니다.
	- 각 서비스는 이 모듈을 참조하거나 필요한 권한만 따로 정의하여 주입받습니다.

- `/modules/network`
	- 모든 환경에서 공통으로 사용하는 VPC, 서브넷 등을 정의합니다.
	- 퍼블릭/프라이빗 서브넷 구조 및 멀티 AZ 고가용성 구성을 기본으로 합니다.
	- EKS, Lambda, RDS 등은 이 네트워크 리소스에 의존합니다.

---

## 환경 분리 전략

- 환경별로 디렉토리를 분리하여 `.tfvars`, backend, 리소스 이름 등을 독립적으로 유지합니다.
- CI/CD에서는 브랜치와 디렉토리를 연계하여 배포합니다.


```

/dev # 개발 환경 (feature 브랜치 배포 대상)  
/main # 운영 환경 (main 브랜치 배포 대상)

```

---

## Terraform Backend 설정 (S3 + DynamoDB)

환경별로 S3를 사용하여 상태 파일을 저장하고, DynamoDB를 통해 상태 잠금(Locking)을 관리합니다.

```hcl
terraform {
  backend "s3" {
    bucket         = "finguard-terraform-backend"
    key            = "dev/terraform.tfstate" # prod는 prod/terraform.tfstate
    region         = "ap-northeast-2"
    dynamodb_table = "finguard-terraform-lock"
    encrypt        = true
  }
}

```

----------

## 개발 환경

-   Terraform `v1.11.4`
    
-   Python `v3.12.3`
    
-   pre-commit 기반 린팅 자동화
    
-   GitHub Actions 기반 CI/CD
    

----------

## 개발 환경 세팅
1.  가상환경 생성
```bash
python -m venv .venv

```
2.  가상환경 진입
```bash
source .venv/bin/activate
```
3.  의존성 설치 (pre-commit 포함)
```bash
make install
```

----------

## Makefile 명령어

| 명령어              | 설명                                         |
|---------------------|----------------------------------------------|
| `make lint`         | 코드 린팅 수행 (Terraform fmt, tflint 등)    |
| `make validate`     | Terraform 문법 검사                          |
| `make action_test`  | GitHub Actions 로컬 시뮬레이션 테스트        |
----------

## 사용법 예시

```bash
cd dev        # 운영 환경은 cd main
terraform init
terraform plan -var-file=".secrets"
terraform apply -var-file=".secrets"

```

`.secrets` 파일에는 각 환경별 변수 값을 정의합니다. 민감정보는 절대 Git에 포함하지 않습니다.

----------

## GitHub Actions CI/CD 워크플로

워크플로는 `/.github/workflows/terraform.yml`에 정의되어 있습니다.

### 기본 구조

-   **pre-commit**: 모든 커밋에 대해 코드 린팅 및 문법 검사 수행
    
-   **terraform plan**: PR 생성 시 자동으로 실행
    
-   **terraform apply**: `main` 브랜치에 merge되면 자동 실행 (`main/`, `dev/` 경로 자동 감지)

### Slack 알림 구조

-   `pre-commit`, `terraform plan`, `terraform apply`, `실패 시 예외 처리` 결과를 Slack으로 전송
    
-   Slack Webhook URL은 GitHub Actions Secret에 저장
    

----------

## 기타 사항

-   환경별 `terraform.tfstate`는 충돌 방지를 위해 S3에서 분리 관리됩니다.
    
-   모든 커밋은 린팅을 통과해야만 가능하므로 로컬 pre-commit 환경을 반드시 구성해야 합니다.
  


----------

## 문의

프로젝트 관련 문의: [inqbator@naver.com](mailto:inqbator@naver.com)
