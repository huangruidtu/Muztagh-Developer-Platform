output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Private endpoint for the EKS API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL for workload identity configuration."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
