# ADR-004: Git/YAML and pull requests are the initial self-service front door

## Status

Accepted.

## Context

The platform needs a reviewable developer entry point. A portal is useful only
after the underlying API, authorization, and ownership model are stable.

## Decision

Developers submit `Workspace`, `Application`, and `DataStore` YAML through a
feature branch and pull request. GitHub Actions validates the change before
review and merge. No Backstage deployment is part of this reference
implementation.

The platform API is the durable contract. A later portal or CLI may generate
the same declarations without changing the Composition interface.

## Alternatives considered

- A Backstage portal could improve discovery but adds deployment, plugin, and
  identity scope before the contracts are proven.
- A custom CLI could improve ergonomics but would be another client to maintain.
- Direct Kubernetes access bypasses the Git review and validation path.

## Consequences and trade-offs

- Requests are transparent, versioned, and reviewable with existing Git tools.
- YAML and pull-request latency are part of the initial developer experience.
- Namespace access is approved at onboarding; current authorization permits
  user-space claims only in `cpemon-dev`.
