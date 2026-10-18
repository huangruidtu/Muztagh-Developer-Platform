locals {
  environment  = "prod"
  platform     = "muztagh"
  name         = "${local.platform}-${local.environment}"
  cluster_name = "${local.name}-eks"
  common_tags = {
    CostCenter  = "platform"
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "platform-team"
    Platform    = local.platform
  }
}

module "network" {
  source = "../../modules/network"

  name                 = local.name
  cluster_name         = local.cluster_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "platform_identity" {
  source = "../../modules/platform-identity"

  name = local.name
  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  name                = local.cluster_name
  kubernetes_version  = var.kubernetes_version
  private_subnet_ids  = module.network.private_subnet_ids
  cluster_role_arn    = module.platform_identity.eks_cluster_role_arn
  node_role_arn       = module.platform_identity.eks_node_role_arn
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  tags                = local.common_tags
}
