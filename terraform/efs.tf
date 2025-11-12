module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~>2.0"

  # File system
  name      = "${var.cluster_name}-efs"
  encrypted = true

  # File system policy
#   attach_policy                      = true
#   policy_statements = [
#     {
#       sid     = "Example"
#       actions = ["elasticfilesystem:ClientMount"]
#       principals = [
#         {
#           type        = "AWS"
#           identifiers = ["arn:aws:iam::111122223333:role/EfsReadOnly"]
#         }
#       ]
#     }
#   ]

  mount_targets = { for k, v in zipmap(local.availability_zones, module.vpc.private_subnets) : k => { subnet_id = v } }

  security_group_description = "EFS security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_ingress_rules = {
    vpc_1 = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_ipv4   = element(module.vpc.private_subnets_cidr_blocks, 0)
    }
    vpc_2 = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_ipv4   = element(module.vpc.private_subnets_cidr_blocks, 1)
    }
    vpc_3 = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_ipv4   = element(module.vpc.private_subnets_cidr_blocks, 2)
    }
  }

  # Access point(s)
  access_points = {
    posix_example = {
      name = "posix-example"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = {
        Additionl = "yes"
      }
    }
    root_example = {
      root_directory = {
        path = "/example"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
