# ADR-001: Terraform owns the infrastructure foundation

## Status

Accepted.

## Context

The network, EKS cluster, node group, and baseline platform IAM roles share a
lifecycle and must have one authoritative reconciler. Crossplane also creates
selected AWS resources from developer claims, so an explicit boundary prevents
two tools from managing the same resource.

## Decision

Terraform owns the shared AWS/EKS foundation under `foundation/terraform/`:
VPC and routing, platform identity, EKS cluster, and node group. Crossplane does
not co-own those resources. Its AWS scope is limited to resources published by
platform Compositions, currently the S3 resources behind `DataStore`.

## Alternatives considered

Use Crossplane for both the foundation and developer capabilities. This could
unify reconciliation, but would couple bootstrap infrastructure to the cluster
control plane it must host and would blur migration and incident ownership.

## Consequences and trade-offs

- Resource ownership and state are unambiguous.
- Foundation changes use Terraform; capability changes use Crossplane APIs and
  Compositions.
- The platform operates two provisioning models and must review new resource
  types against the ownership boundary.
- The repository has offline Terraform validation only; this decision does not
  demonstrate a live AWS deployment.
