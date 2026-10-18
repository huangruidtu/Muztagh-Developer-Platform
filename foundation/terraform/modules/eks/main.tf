locals {
  common_tags = merge(var.tags, {
    Component = "eks"
    ManagedBy = "Terraform"
  })
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  tags = local.common_tags
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-system"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_scaling.desired_size
    max_size     = var.node_scaling.max_size
    min_size     = var.node_scaling.min_size
  }

  tags = local.common_tags
}
