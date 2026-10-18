# Platform architecture

## Purpose

Muztagh is the shared internal developer platform for domain teams. It provides
the repository and ownership boundaries through which shared platform
capabilities can be introduced without placing platform implementation details
in application repositories.

The platform is defined independently of any source repository outside this
project.

## Scope

Muztagh owns the shared platform boundary: common contracts, platform-managed
configuration, documented interfaces, and the operating conventions for changes
to those assets.

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
| `foundation/` | Shared, versioned contracts and boundary definitions | Platform team |
| `platform/` | Platform-managed implementation assets | Platform team |
| `user-space/` | Domain-team declarations that consume platform contracts | Domain teams |
| `docs/` | Architecture and working conventions | Platform team, with domain-team review where applicable |

The boundaries are deliberate:

- Foundation changes establish or change a reusable interface. They must be
  reviewed for compatibility and adoption impact.
- Platform assets implement shared capabilities behind those interfaces. They
  are not a place for domain-specific application configuration.
- User-space content describes a domain team's intended use of published
  interfaces. It must not bypass or redefine platform implementation.

## Architectural direction

The intended control path is declarative: a developer records intent in Git;
automated validation evaluates it; a delivery component applies approved
desired state; and reconciliation reports divergence. The named tools that may
eventually perform these responsibilities are not configured by this story.

See [delivery-flow.md](delivery-flow.md) for the responsibility-level flow and
[ownership.md](ownership.md) for decision ownership.
