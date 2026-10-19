# Ownership model

Ownership is assigned by responsibility rather than by repository write access.
Platform teams publish and maintain shared interfaces; domain teams choose and
operate their workloads within those interfaces.

| Area | Platform team | Domain team |
| --- | --- | --- |
| Infrastructure foundation | Owns Terraform-managed shared infrastructure and its lifecycle | Does not manage shared foundation resources |
| Control plane | Owns platform implementation and published capability interfaces | Consumes published capabilities |
| Delivery and reconciliation | Defines the GitOps boundary and reconciliation ownership | Supplies domain declarations through supported interfaces |
| Platform APIs and policy | Owns Workspace lifecycle, quotas, RBAC, network isolation, workload defaults, and admission policy | Consumes APIs and cannot change the tenant boundary through normal inputs |
| Applications | Provides shared delivery constraints and security defaults | Owns images, supported configuration, runtime behavior, and data semantics |
| Operations | Operates shared platform components once introduced | Operates domain services and responds to domain alerts and incidents |

The matrix does not grant a team unilateral control over another team's assets.
An interface change follows the Git and PR workflow, with affected owners
included in review.

See [tenancy-security.md](tenancy-security.md) for the concrete Workspace,
identity, network, and guardrail boundaries.
