# locals { … } 블록은 “재사용할 값들을 이름 붙여 저장”하는 기능
locals {
  project_name      = "finguard" # 모든 리소스 이름 prefix로 사용 (ex: finguard-dev-xxx).
  env               = "dev" #환경 식별자. (dev, main, staging 등 구분)
  region            = "ap-northeast-2"
  db_username       = "admin" #RDS 접속 기본 계정명.
  db_instance_class = "db.t4g.micro"

  # 기본 VPC CIDR
  main_vpc_cidr_block = "10.0.0.0/16" #/16 → 65,536개 주소(10.0.0.0 ~ 10.0.255.255).

  # /24씩 쪼개기 위한 인덱스 기준
  subnet_base_indexes = {
    public      = 1
    rds         = 11
    lambda      = 21
    elasticache = 31
    endpoint    = 41
    alb         = 51
    ecs         = 61
  }

  # subnet function (az index → 0=a, 1=c)
  public_subnets = {
    "${local.project_name}-${local.env}-public-a" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.public + 0)
      az         = "${local.region}a"
    }
    "${local.project_name}-${local.env}-public-c" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.public + 1)
      az         = "${local.region}c"
    }
  }

  rds_subnets = {
    "${local.project_name}-${local.env}-rds-a" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.rds + 0)
      az         = "${local.region}a"
    }
    "${local.project_name}-${local.env}-rds-c" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.rds + 1)
      az         = "${local.region}c"
    }
  }

  lambda_subnets = {
    "${local.project_name}-${local.env}-lambda-a" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.lambda + 0)
      az         = "${local.region}a"
    }
    "${local.project_name}-${local.env}-lambda-c" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.lambda + 1)
      az         = "${local.region}c"
    }
  }

#  elasticache_subnets = {
#    "${local.project_name}-${local.env}-elasticache-a" = {
#      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.elasticache + 0)
#      az         = "${local.region}a"
#    }
#    "${local.project_name}-${local.env}-elasticache-c" = {
#      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.elasticache + 1)
#      az         = "${local.region}c"
#    }
#  }

  endpoint_subnets = {
    "${local.project_name}-${local.env}-vpc-endpoint-a" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.endpoint + 0)
      az         = "${local.region}a"
    }
    "${local.project_name}-${local.env}-vpc-endpoint-c" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.endpoint + 1)
      az         = "${local.region}c"
    }
  }

#  caching = {
#    node_type       = "cache.t3.micro"
#    num_cache_nodes = 1
#  }

  alb_subnets = {
    "${local.project_name}-${local.env}-alb-a" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.alb + 0)
      az         = "${local.region}a"
    }
    "${local.project_name}-${local.env}-alb-c" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.alb + 1)
      az         = "${local.region}c"
    }
  }

  ecs_subnets = {
    "${local.project_name}-${local.env}-ecs-a" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.ecs + 0)
      az         = "${local.region}a"
    }
    "${local.project_name}-${local.env}-ecs-c" = {
      cidr_block = cidrsubnet(local.main_vpc_cidr_block, 8, local.subnet_base_indexes.ecs + 1)
      az         = "${local.region}c"
    }
  }


}
