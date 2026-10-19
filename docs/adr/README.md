# Architecture decision records

ADRs record decisions that define ownership or developer contracts.

| ADR | Decision |
| --- | --- |
| [ADR-001](ADR-001-terraform-owns-foundation.md) | Terraform owns the infrastructure foundation |
| [ADR-002](ADR-002-argocd-gitops-reconciler.md) | Argo CD is the GitOps reconciler |
| [ADR-003](ADR-003-crossplane-platform-capabilities.md) | Crossplane exposes developer-facing platform capabilities |
| [ADR-004](ADR-004-git-yaml-front-door.md) | Git/YAML and pull requests are the initial self-service front door |
| [ADR-005](ADR-005-cpemon-first-consumer.md) | CPEmon is the first consumer, not a special-case platform |

Accepted ADRs remain in the index. A later decision that changes one should add
a superseding ADR rather than silently rewriting its history.
