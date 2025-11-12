# VPC Configuration for EKS Cluster
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true

  #   # Required tags for EKS public subnets for external load balancers
  #   public_subnet_tags = {
  #     "kubernetes.io/role/elb"                    = "1"
  #     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  #   }

  #   # Required tags for EKS private subnets for internal load balancers
  #   private_subnet_tags = {
  #     "kubernetes.io/role/internal-elb"           = "1"
  #     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  #   }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Environment                                 = var.environment
    ManagedBy                                   = "Terraform"
  }
}