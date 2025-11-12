module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                                     = var.cluster_name
  kubernetes_version                       = var.kubernetes_version
  enable_cluster_creator_admin_permissions = true

  # VPC and subnet configuration from the VPC module
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Cluster endpoint configuration
  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Complete addon configuration
  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Comprehensive node group configuration
  eks_managed_node_groups = {
    main = {
      name            = "${var.cluster_name}-ng"
      use_name_prefix = true

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_capacity

      instance_types = var.node_instance_types
      # capacity_type  = "ON_DEMAND"

      ami_type             = "AL2023_x86_64_STANDARD"
      # disk_size            = var.node_disk_size

      subnet_ids = module.vpc.private_subnets

      # Labels for node identification
      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      taints = {}

      tags = {
        NodeGroup = "main"
      }
    }
  }

  tags = {
    Environment = var.environment
    Cluster     = var.cluster_name
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # Cluster security group rules
  security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

}
