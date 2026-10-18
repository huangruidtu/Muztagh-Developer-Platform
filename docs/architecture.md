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

This story does not introduce infrastructure provisioning, deployment tooling,
networking, policy engines, continuous integration, observability, or CPEmon
onboarding. It also does not define workload templates, environment topology,
access controls, service-level objectives, or production operating procedures.

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
- Platform contains the control plane and developer-facing capabilities. Future
  implementation may include Argo CD, Crossplane, networking, policy, and
  observability; none is configured by this story.
- User space contains declarations through published capabilities. It must not
  bypass or redefine the infrastructure foundation or control plane.

## Architectural direction

The intended control path is declarative: a developer records intent in Git;
automated validation evaluates it; a delivery component applies approved
desired state; and reconciliation reports divergence. The named tools that may
eventually perform these responsibilities are not configured by this story.

See [delivery-flow.md](delivery-flow.md) for the responsibility-level flow and
[ownership.md](ownership.md) for decision ownership.
