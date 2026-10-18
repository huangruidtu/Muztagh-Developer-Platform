variable "aws_region" {
  description = "AWS region for the development foundation."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for development subnets."
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR for development."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for development."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for development."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EKS node instance types for development."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for the development EKS control plane."
  type        = string
}

variable "node_desired_size" {
  description = "Desired EKS node count for development."
  type        = number
}

variable "node_min_size" {
  description = "Minimum EKS node count for development."
  type        = number
}

variable "node_max_size" {
  description = "Maximum EKS node count for development."
  type        = number
}
