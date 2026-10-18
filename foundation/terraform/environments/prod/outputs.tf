output "vpc_id" {
  description = "Production VPC ID."
  value       = module.network.vpc_id
}

output "eks_cluster_name" {
  description = "Production EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Production EKS API endpoint."
  value       = module.eks.cluster_endpoint
}
