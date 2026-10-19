# Dependency lifecycle: Kyverno policy API

## Context

Muztagh depends on external platform components including Crossplane, Cilium,
Kyverno, Argo CD, and Terraform providers. These dependencies release and change
independently of the repository.

MDP-6 introduced guardrails using `kyverno.io/v1` `ClusterPolicy`. Kyverno
1.19.x still accepts this API, but marks it deprecated in favor of CEL-based
policy types in `policies.kyverno.io`.

## Signal detected

Kyverno 1.19.x deprecates `kyverno.io/v1` `ClusterPolicy`. The migration path is
toward CEL-based types such as `policies.kyverno.io` `ValidatingPolicy`.
Retaining the legacy API increases compatibility risk as later Kyverno releases
evolve.

This signal is an API deprecation, not a security vulnerability or CVE.

## Impact analysis

An unreviewed Kyverno upgrade could introduce policy API incompatibility:

```text
dependency upgrade
  -> policy API incompatibility
  -> guardrails fail to reconcile
  -> tenant security controls may not be applied
```

The upgrade is therefore a security-relevant operational change even though
the trigger is compatibility rather than a vulnerability.

## Decision

For MDP-6:

- retain the existing `ClusterPolicy` implementation;
- use Kyverno 1.19.x as the reference compatibility target;
- make no compatibility claim for later Kyverno versions;
- defer migration to CEL-based `ValidatingPolicy` resources to a dedicated
  compatibility change; and
- avoid changing policy technology while validating the tenancy guardrail
  model.

MDP-6 establishes the guardrail model; it is not a Kyverno migration story.

## Upgrade and vulnerability-management pattern

```text
dependency discovered or advisory received
  -> identify current version and API
  -> classify security and compatibility risk
  -> assess affected platform capabilities
  -> choose upgrade, migration, or temporary pin
  -> test manifests and policy behavior
  -> review and merge
  -> deploy progressively
  -> verify runtime health
  -> remove the temporary compatibility constraint
```

A real CVE follows the same process but may require different urgency, rollout,
or risk-acceptance decisions.

## Controls

Future dependency controls may include explicit version pinning, automated
dependency notifications, vulnerability scanning, release-note and deprecation
review, CI validation against supported versions, policy tests, and controlled
upgrades through pull requests. MDP-6 does not implement these controls; CI and
automated dependency hygiene belong primarily to MDP-9.

## Practical takeaway

Dependency management in a platform is not just upgrading versions. An upgrade
can change APIs that enforce security boundaries, so dependency changes must be
reviewed platform changes with compatibility and security validation.
