# Muztagh Developer Platform

Muztagh is a shared internal developer platform. This repository separates the
Terraform-owned infrastructure foundation, the platform control plane, and
domain-team declarations.

## Repository layout

- `foundation/` — Terraform-owned shared infrastructure foundation.
- `platform/` — platform control plane and developer-facing capabilities.
- `user-space/` — domain-team declarations consuming published capabilities.
- `docs/` — architecture, ownership, and contribution conventions.

Read [docs/architecture.md](docs/architecture.md) and
[docs/terraform-foundation.md](docs/terraform-foundation.md) before changing
foundation infrastructure. The developer contracts are documented in
[platform/crossplane/README.md](platform/crossplane/README.md), with tenancy and
guardrails in [docs/tenancy-security.md](docs/tenancy-security.md). The
Git/YAML consumer workflow is in
[docs/developer-golden-path.md](docs/developer-golden-path.md). The layered
health model and day-2 runbooks start at
[docs/operations/platform-health.md](docs/operations/platform-health.md). No
live infrastructure is provisioned by this repository.
