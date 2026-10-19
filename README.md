# Muztagh Developer Platform

## What it is

Muztagh is a central shared platform operated as an Internal Developer Platform.
It separates Terraform-owned foundation infrastructure, platform-owned control
plane capabilities, and domain-team declarations.

## Why it exists

- Model a provider-side Central Platform reference implementation.
- Publish stable developer contracts for controlled self-service.
- Keep infrastructure, platform, and domain ownership explicit.

## Architecture

```text
Domain team -> Git/YAML -> PR + CI -> Argo CD -> platform API claims
                                                    |
                                                    v
                                           Crossplane Compositions
                                             |                  |
                                             v                  v
                                     Kubernetes resources   selected AWS resources

Platform engineer -> Terraform modules -> AWS/EKS foundation

Kyverno and Cilium policy intent -> guardrails
Observability rules and runbooks  -> day-2 operating model
```

Terraform and Crossplane have separate resource ownership. They do not manage
the same resources.

## Platform contracts

- `Workspace` establishes the tenant namespace, quota, developer binding, and
  network-policy intent.
- `Application` declares a container workload exposed by a ClusterIP Service.
- `DataStore` declares an S3 bucket with public access blocked and SSE-S3.

## First consumer

CPEmon is the first reference domain consumer. Its declarations exercise the
shared contracts without adding CPEmon-specific behavior to the platform API.

## Validation

Pull requests run Terraform, manifest/schema, policy, and security jobs behind
the aggregate `required-check`. [PR #8](https://github.com/huangruidtu/Muztagh-Developer-Platform/pull/8)
demonstrated a successful GitHub Actions run. These checks validate repository
artifacts; they do not prove AWS provisioning or live controller behavior.

## Repository structure

- `foundation/` — Terraform-owned AWS and EKS foundation.
- `platform/` — GitOps, platform APIs, guardrails, and observability assets.
- `user-space/` — domain-team declarations using published contracts.
- `validation/` — repository-wide static validation.
- `docs/` — architecture, decisions, operations, and evidence.

## Limitations

The implementation is offline-validated and has not been deployed to AWS or a
live Kubernetes platform. See [the truth boundary](docs/truth-boundary.md).

## Documentation

- [Architecture](docs/architecture.md)
- [Ownership](docs/ownership.md)
- [Architecture decisions](docs/adr/README.md)
- [Developer golden path](docs/developer-golden-path.md)
- [CI validation](docs/ci-validation.md)
- [Interview evidence](docs/interview-walkthrough.md)
