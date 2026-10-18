output "vpc_id" {
  description = "ID of the shared VPC."
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets for EKS workloads."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs of public subnets for public load balancers."
  value       = aws_subnet.public[*].id
}
