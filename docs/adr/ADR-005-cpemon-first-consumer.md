# ADR-005: CPEmon is the first consumer, not a special-case platform

## Status

Accepted.

## Context

A platform contract needs a concrete consumer to reveal missing boundaries.
Using one consumer can also tempt the platform to absorb that application's
implementation details.

## Decision

CPEmon is the first reference consumer of the generic `Workspace`,
`Application`, and `DataStore` APIs. Missing capabilities remain explicitly
missing. Kafka, ClickHouse, CPEmon-specific labels, networking switches, and
provider configuration are not added to the shared contracts merely to model
one consumer.

The contract test is whether a second unrelated domain could use the APIs
without inheriting CPEmon concepts.

## Alternatives considered

Model the platform API around all CPEmon implementation details. This would
make onboarding appear complete but couple the shared contract to one domain
and transfer application architecture into platform ownership.

## Consequences and trade-offs

- The first consumer exercises real tenancy, application, and datastore paths.
- Shared APIs remain small and reusable.
- Unsupported CPEmon dependencies remain visible instead of being simulated or
  claimed as implemented.
- CPEmon here is a reference declaration set, not evidence of a historical or
  production-system migration.
