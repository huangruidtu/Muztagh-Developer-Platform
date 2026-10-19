# ADR-003: Crossplane exposes developer-facing platform capabilities

## Status

Accepted.

## Context

Domain teams need stable requests that hide provider and Kubernetes resource
details while preserving platform ownership of implementation and guardrails.

## Decision

Crossplane XRDs publish three APIs: `Workspace`, `Application`, and `DataStore`.
An XRD defines what a developer may request. Its Composition defines how the
platform implements that request and which composed resources determine
readiness.

`Workspace` composes tenant Kubernetes resources, `Application` composes a
Deployment and Service, and `DataStore` composes S3 resources. Crossplane does
not replace Terraform for the shared foundation.

## Alternatives considered

- Raw Kubernetes manifests expose implementation detail and weaken the shared
  contract.
- Terraform tickets preserve centralized control but do not provide a
  Kubernetes-native self-service API.
- A custom service could expose an API but adds service code and operations not
  needed for the current contracts.

## Consequences and trade-offs

- Developers use a small API while the platform can revise Composition details.
- XRD evolution and provider schemas become platform compatibility concerns.
- Crossplane controllers, CRDs, provider credentials, and live reconciliation
  are prerequisites outside this repository's runtime evidence.
