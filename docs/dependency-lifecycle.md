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

MDP-9 adds concrete controls around this lifecycle:

- immutable commit pins for GitHub Actions and explicit CI tool versions;
- weekly Dependabot checks for GitHub Actions and Terraform providers;
- Kyverno policy tests against the pinned 1.19.1 CLI compatibility target;
- Terraform, manifest, workflow, and schema checks on pull requests;
- Trivy repository/IaC scanning and Gitleaks history scanning; and
- reviewed dependency upgrades through the same stable CI gate as other
  changes.

Release-note and deprecation review remains necessary because automated version
updates cannot determine whether a policy API migration preserves guardrail
behavior.

Controller upgrades must also review bootstrap health semantics. Argo CD health
customizations depend on the selected version's status fields and Lua behavior;
Crossplane upgrades can change package conditions, generated APIs, or provider
dependencies. The proposed readiness work in
[#12](https://github.com/huangruidtu/Muztagh-Developer-Platform/issues/12) and
[#13](https://github.com/huangruidtu/Muztagh-Developer-Platform/issues/13)
therefore requires explicit controller version targets and recovery tests. A
package reporting healthy is not evidence that credentials or an external API
are usable.

## Practical takeaway

Dependency management in a platform is not just upgrading versions. An upgrade
can change APIs that enforce security boundaries, so dependency changes must be
reviewed platform changes with compatibility and security validation.
