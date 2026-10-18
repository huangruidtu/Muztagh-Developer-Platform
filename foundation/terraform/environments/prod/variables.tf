variable "aws_region" {
  description = "AWS region for the production foundation."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for production subnets."
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR for production."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for production."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for production."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for the production EKS control plane."
  type        = string
}

variable "node_instance_types" {
  description = "EKS node instance types for production."
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired EKS node count for production."
  type        = number
}

variable "node_min_size" {
  description = "Minimum EKS node count for production."
  type        = number
}

variable "node_max_size" {
  description = "Maximum EKS node count for production."
  type        = number
}
