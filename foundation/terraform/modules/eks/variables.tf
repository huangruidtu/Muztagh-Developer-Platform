variable "name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS control plane and nodes."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "private_subnet_ids must contain at least two subnets."
  }
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the managed node group."
  type        = string
}

variable "node_instance_types" {
  description = "Instance types allowed in the managed node group."
  type        = list(string)

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "node_instance_types must contain at least one instance type."
  }
}

variable "node_scaling" {
  description = "Minimum, desired, and maximum node counts."
  type = object({
    min_size     = number
    desired_size = number
    max_size     = number
  })

  validation {
    condition = (
      var.node_scaling.min_size >= 0 &&
      var.node_scaling.min_size <= var.node_scaling.desired_size &&
      var.node_scaling.desired_size <= var.node_scaling.max_size
    )
    error_message = "node scaling must satisfy 0 <= min_size <= desired_size <= max_size."
  }
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}
