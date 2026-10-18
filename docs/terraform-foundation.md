# Terraform foundation

Terraform owns the long-lived shared AWS foundation: VPC networking, the EKS
cluster and managed node group, and the IAM roles they require. Environment
roots in `foundation/terraform/environments/` compose the modules in
`foundation/terraform/modules/`.

The network module creates public and private subnets across supplied
availability zones. It uses one NAT gateway to keep the reference foundation
small; production availability requirements may justify one NAT gateway per
zone in a later change.

The EKS module accepts subnet and IAM role identifiers rather than creating
them. This keeps network, identity, and cluster lifecycle changes reviewable
independently. Environment roots are intentionally thin: they set names, CIDR
ranges, availability zones, and node-group sizing, then connect module outputs
to module inputs.

The reference foundation attaches `AmazonEKS_CNI_Policy` to the node role.
Moving CNI permissions to a least-privilege workload identity, such as IRSA or
another later identity model, is deferred to identity and security work.

Names use the `muztagh-<environment>` prefix, with the EKS cluster named
`muztagh-<environment>-eks`. Environment roots apply `Environment`, `Owner`,
`CostCenter`, `Platform`, and `ManagedBy` tags; modules add their component tag
and resource-specific `Name` tag where AWS supports it.

## Terraform and Crossplane boundary

Terraform owns shared network resources, EKS foundation resources, baseline
platform IAM, and their lifecycle. Crossplane will later own selected
developer-requested application-level resources through published self-service
APIs. A resource has one owner: no Terraform configuration may manage a
resource managed by Crossplane, and no Crossplane composition may manage a
Terraform-owned foundation resource.

The modules contain no credentials or backend configuration. Run initialization
and validation independently from each environment directory. Applying changes,
selecting a state backend, and defining Crossplane APIs are later work.
