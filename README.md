# Muztagh Developer Platform

Muztagh is a shared internal developer platform. This repository separates the
Terraform-owned infrastructure foundation, the platform control plane, and
domain-team declarations.

## Repository layout

- `foundation/` — Terraform-owned shared infrastructure foundation.
- `platform/` — platform control plane and developer-facing capabilities.
- `user-space/` — domain-team declarations consuming published capabilities.
- `docs/` — architecture, ownership, and contribution conventions.

Read [docs/architecture.md](docs/architecture.md) before adding implementation
assets. The repository currently defines architecture and working conventions;
it does not yet provision or operate infrastructure.
