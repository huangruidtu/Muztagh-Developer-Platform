output "vpc_id" {
  description = "Development VPC ID."
  value       = module.network.vpc_id
}

output "eks_cluster_name" {
  description = "Development EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Development EKS API endpoint."
  value       = module.eks.cluster_endpoint
}
