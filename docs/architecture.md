# Platform architecture

## Purpose

Muztagh is the shared internal developer platform for domain teams. It provides
the repository and ownership boundaries through which shared platform
capabilities can be introduced without placing platform implementation details
in application repositories.

The platform is defined independently of any source repository outside this
project.

## Scope

Muztagh separates a Terraform-owned shared infrastructure foundation from a
platform control plane that exposes developer-facing platform capabilities.
The platform team owns the implementation and documented interfaces for both
layers.

Domain teams own their applications, domain configuration, data decisions, and
the correctness of declarations they submit through published interfaces.

## Non-goals for the reference implementation

The repository contains Terraform structure for the shared AWS foundation,
Argo CD manifests for GitOps reconciliation, and Crossplane platform API
manifests. None has been applied to a live environment. Crossplane installation,
Cilium and Kyverno installation, CI, observability, CPEmon onboarding, workload
templates, service-level objectives, and production operating procedures remain
out of scope.

## Repository boundaries

| Directory | Intended contents | Primary owner |
| --- | --- | --- |
| `foundation/` | Terraform-owned shared infrastructure foundation | Platform team |
| `platform/` | Control-plane implementation and developer-facing capabilities | Platform team |
| `user-space/` | Domain-team declarations consuming published capabilities | Domain teams |
| `docs/` | Architecture and working conventions | Platform team, with domain-team review where applicable |

The boundaries are deliberate:

- Foundation contains Terraform-owned infrastructure on which platform
  capabilities depend. It is not a place for domain application resources.
- Platform contains the control plane and developer-facing capabilities. It now
  includes Argo CD reconciliation, Crossplane APIs, tenant network-policy
  intent, and Kyverno guardrails; observability remains later work.
- User space contains declarations through published capabilities. It must not
  bypass or redefine the infrastructure foundation or control plane.

## Architectural direction

The control path is declarative: a developer records intent in Git, validation
evaluates it, Argo CD reconciles approved platform configuration, and Crossplane
translates published API claims into owned resources. Live installation and
runtime operation are outside the evidence in this repository.

See [delivery-flow.md](delivery-flow.md) for the responsibility-level flow and
[ownership.md](ownership.md) for decision ownership.
