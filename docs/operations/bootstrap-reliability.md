# Bootstrap reliability plan

This document records the current bootstrap behavior and the reviewed work
needed to make dependency readiness explicit. It is a design and test plan; no
health customization, wait job, controller, or runtime gate is implemented.

Tracked work:

- [#12](https://github.com/huangruidtu/Muztagh-Developer-Platform/issues/12)
  designs child `Application` health assessment.
- [#13](https://github.com/huangruidtu/Muztagh-Developer-Platform/issues/13)
  designs Crossplane package and capability gates. Its signals feed #12.
- [#14](https://github.com/huangruidtu/Muztagh-Developer-Platform/issues/14)
  defines failure-injection and recovery tests after #12 and #13 are agreed.

## Verified current behavior

The root Application creates four child Applications:

```text
wave 0  muztagh-platform-controllers
wave 10 muztagh-platform-capabilities
wave 15 muztagh-guardrails
wave 20 muztagh-user-space
```

Argo CD orders resources by sync wave and processes the first wave containing
an OutOfSync or unhealthy resource. The current repository does not configure
health assessment for `argoproj.io/Application`. Argo CD removed that built-in
assessment in 1.8, so the root cannot currently use a child Application's own
health as a strict readiness barrier. Child Applications reconcile
independently after their objects are created.

This distinction matters:

- `Synced` means the live resource specification matches the desired Git state.
- `Healthy` is an assessment of whether the resource is operating as expected.

A child can be Synced while its workloads are unhealthy, or OutOfSync while its
currently deployed workloads remain healthy. Wave order alone proves neither.

The same gap exists inside layers. The controllers child creates Crossplane
`Function` and `Provider` objects, but Argo CD has no repository-defined health
logic for those custom resources. The user-space child orders `Workspace` at
wave 0 and namespaced claims at wave 10, but no health assessment proves that
Crossplane created `cpemon-dev` before the namespaced claims are submitted.

## Proposed child Application health strategy

Issue #12 should introduce a version-reviewed Argo CD resource customization
for `argoproj.io/Application`. The customization should evaluate the child
status exposed by the Argo CD controller rather than infer health from object
existence.

| Child state | Proposed parent assessment |
| --- | --- |
| `status.sync.status=Synced` and `status.health.status=Healthy` | `Healthy` |
| Missing status, an active operation, OutOfSync, or child health `Progressing` | `Progressing` |
| Child health `Degraded`, or a completed operation with `Error` or `Failed` | `Degraded` |
| Child health `Unknown` | `Unknown`, with the child message preserved |

The implementation should default missing status to `Progressing`; absence of
evidence must not become `Healthy`. It should preserve useful child messages
and handle additional Argo states explicitly during review. With a correct
customization, the root health becomes the worst health of its immediate child
resources and a non-healthy earlier wave can prevent later waves from starting.

This gate still depends on each child reporting meaningful health. Package,
XRD, claim, and policy custom resources may need their own health customization
or an explicit verification resource. Child Application propagation alone does
not manufacture those signals.

## Crossplane dependency and readiness model

Readiness is split into package, API, capability, and external-provider layers.
The first failed layer should stop only the capabilities that actually depend
on it.

| Dependency | Required evidence | Needed by | Boundary |
| --- | --- | --- | --- |
| Crossplane core | Core pods and package/XRD APIs available; RBAC manager behavior verified | All Crossplane packages and APIs | Installed outside this repository |
| Patch-and-transform Function | `Installed=True` and `Healthy=True`; inspect active `FunctionRevision` on failure | All three Compositions | `Installed=True` alone is not ready |
| AWS S3 Provider package | `Installed=True` and `Healthy=True`; active `ProviderRevision` healthy | `DataStore` only | Does not need to block `Workspace` or `Application` |
| Provider managed-resource APIs | Required S3 CRDs have `Established=True` and appear in API discovery | `DataStore` reconciliation | Package health and discovery are separate observations |
| Muztagh XRDs | Each XRD reports `Established=True`; Workspace, Application, and DataStore appear in discovery | User-space claims | Composition existence is not XRD establishment |
| Compositions and RBAC | Three Compositions accepted; Function reference exists; Crossplane permissions are present | Claim reconciliation | Static acceptance does not prove a successful function call |
| Cilium API/controller | `cilium.io/v2` API discoverable and controller able to report policy `Valid=True` | `Workspace` network-policy readiness | Not required by `Application` or `DataStore` directly |
| Kyverno API/admission path | ClusterPolicy API accepted and the selected installation's controller/webhook readiness verified | Guardrail enforcement before tenant workloads | Policy object existence does not prove admission enforcement |
| `ClusterProviderConfig/default` | Object and referenced credential source exist without exposing secret data | `DataStore` provider calls | ProviderConfig has no general package-health implication |
| AWS integration | Credentials, IAM authorization, DNS/network path, AWS API calls, and managed resources reach expected conditions | Usable `DataStore` | Requires a live environment; package `Healthy=True` is insufficient |

Crossplane reports package installation and health separately. A Provider or
Function may be `Installed=True` while `Healthy` is `Unknown` or `False`.
Provider health indicates package/runtime readiness, not valid credentials or
external AWS connectivity. Those failures appear when the provider reconciles
a managed resource.

Provider CRDs do not need to exist merely to store the DataStore Composition's
embedded templates, but they must be served before Crossplane can create those
managed resources. XRD-generated APIs must be established and discoverable
before Argo CD submits claims. Kubernetes CRD `Established=True` plus API
discovery is the proposed registration gate.

## Failure and recovery test plan

All failure injection belongs in a disposable, non-production cluster. Static
tests can validate manifests, Lua result mapping, and command structure; they
cannot demonstrate controller timing, admission behavior, or recovery.

| Scenario | Trigger and expected evidence | Inspection | Recovery and ownership | Validation boundary |
| --- | --- | --- | --- | --- |
| Child exists but is not Healthy | Use a test child whose resource remains Progressing or Degraded. After #12, the root should reflect that state and not advance past the wave. | Describe root and child Applications; inspect `status.sync`, `status.health`, `status.operationState`, and events. | Correct or revert Git; confirm child then root health. Platform team owns the GitOps control plane. | Lua fixtures offline; propagation and wave blocking live only. |
| Provider remains Installing or Unhealthy | In a disposable cluster, use an unreachable or incompatible test package reference. Expect `Healthy=Unknown/False` and ProviderRevision events. | Get and describe Provider and ProviderRevision; inspect package-controller events and logs. | Restore a valid package/dependency, then verify both conditions. Platform team owns package compatibility. | Manifest shape offline; package pull/install/recovery live only. |
| Required CRD unavailable | Delay a provider or XRD, then submit a dependent resource. Expect API discovery or no-match/admission errors, or a claim reconciliation error for a missing managed-resource kind. | Inspect CRD `Established`, API discovery, Argo operation messages, XRD/claim conditions, and events. | Restore the owning package/XRD; wait for establishment and discovery, then resync if bounded retries are exhausted. Platform team owns API registration. | Expected GVKs can be checked offline; discovery timing live only. |
| Function unavailable | Stop the test Function runtime after installation or make it unhealthy. Claims should report composition-pipeline errors and remain not Ready. | Get Function and FunctionRevision; describe the claim; inspect Crossplane events and logs. | Restore the Function and verify a new successful reconciliation. Platform team owns the Composition runtime. | Function reference can be checked offline; invocation and recovery live only. |
| Security dependency unavailable | In a disposable cluster, make the selected Kyverno controller/webhook unavailable or withhold its CRD. Policy sync may fail, and workload admission behavior depends on the installed webhook configuration. | Inspect guardrails Application, Kyverno pods, ClusterPolicies, webhook configurations, admission events, and controller logs. | Restore the controller and verify both policy readiness and an allow/deny admission probe. Platform/security owner. | Policy CLI tests remain offline; webhook availability and enforcement require live tests. |
| Temporary dependency recovers | Interrupt registry/network access or a test controller, then restore it. Conditions should transition, but exhausted Argo retries may require a new sync. | Record condition transitions, operation history, events, and timestamps across the outage. | Remove the fault, verify dependency health, explicitly resync where required, and confirm downstream readiness. Owner follows the first failed layer. | Recovery timing and retry behavior require a live test. |

Useful live inspection commands include:

```text
kubectl get applications.argoproj.io -n argocd
kubectl describe applications.argoproj.io muztagh-platform -n argocd
kubectl get functions.pkg.crossplane.io,providers.pkg.crossplane.io
kubectl get functionrevisions.pkg.crossplane.io,providerrevisions.pkg.crossplane.io
kubectl get compositeresourcedefinitions.apiextensions.crossplane.io
kubectl api-resources --api-group platform.muztagh.io
kubectl api-resources --api-group s3.aws.m.upbound.io
kubectl get events -A --sort-by=.lastTimestamp
```

Do not print credential Secrets while collecting evidence. Recovery is not
complete until the dependency is healthy, downstream reconciliation resumes,
and the consumer-facing capability passes its contract check.

## Validation strategy for later implementation

Static review should pin the target Argo CD and Crossplane versions, test every
Lua health outcome with status fixtures, render all Kustomize roots, validate
the configuration schema where available, and retain the current negative
policy and manifest tests. The Argo CD CLI can assess a health customization
against fixtures when a pinned compatible CLI is added.

Runtime validation requires a disposable cluster with the selected controller
versions. Tests should observe initial bootstrap, inject one failure at a time,
verify the expected blocked boundary, restore the dependency, and verify
recovery. Capture actual conditions and events rather than relying only on
elapsed time. Re-run recovery after bounded Argo retries have been exhausted.

## Open review questions

- Which Argo CD version will the platform support and use to test Lua behavior?
- Should package/XRD readiness be expressed as Argo health customizations,
  explicit verification Jobs, or a smaller Application split?
- How should the single user-space Application avoid blocking unrelated
  `Workspace` and `Application` consumers on DataStore-only AWS readiness?
- Which Kyverno installation and webhook failure policy define the required
  security-readiness probe?
- What disposable cluster and AWS test account can safely exercise provider
  credentials, connectivity, and cleanup?

## Upstream references

- [Argo CD resource health](https://argo-cd.readthedocs.io/en/stable/operator-manual/health/)
- [Argo CD sync waves](https://argo-cd.readthedocs.io/en/latest/user-guide/sync-waves/)
- [Crossplane Providers](https://docs.crossplane.io/latest/packages/providers/)
- [Crossplane Compositions](https://docs.crossplane.io/latest/composition/compositions/)
- [Kubernetes CRD establishment and discovery](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/)
