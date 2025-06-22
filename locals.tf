locals {
  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidrs  = cidrsubnets("10.10.1.0/16", 8, 8)
  private_subnet_cidrs = [
    "10.10.10.0/24",
    "10.10.11.0/24"
  ]
}
