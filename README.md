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
foundation infrastructure. Terraform configuration is present; no live
infrastructure is provisioned by this repository change.
