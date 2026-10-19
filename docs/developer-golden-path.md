# Developer Golden Path

Git/YAML is the current self-service front door. A domain team declares intent
through published Muztagh APIs; it does not commit the resources created by
their Compositions.

## Change flow

```text
developer changes user-space declaration
  -> feature branch
  -> pull request
  -> static validation and policy/ownership review
  -> merge to main
  -> Argo CD detects desired-state change
  -> Argo CD reconciles platform API requests
  -> Crossplane reconciles composed resources
```

Changes to shared contracts require platform-team review. Consumer-only input
changes remain domain-owned unless they affect a shared policy or exception.
A future UI or CLI may generate the same declarations without changing the
underlying platform APIs.

## GitOps authorization boundary

The `muztagh` AppProject is limited to provider-side control-plane assets. The
`muztagh-user-space` AppProject is used only for developer-facing claims. It can
target tenant namespaces, but its allowlists contain only `Workspace`,
`Application`, and `DataStore` from `platform.muztagh.io`.

This combines a namespace scope wide enough for multiple tenants with a narrow
capability set. It does not permit raw Kubernetes workloads, RBAC, networking,
policy, Argo CD Applications, or AWS managed resources.

## CPEmon consumer example

The CPEmon example uses only three contracts:

- `Workspace` for the tenant boundary and developer group;
- `Application` for image, tag, replicas, and port; and
- `DataStore` for region and deletion policy.

A CPEmon developer does not need to author Terraform modules, EKS node groups,
Crossplane Compositions, AWS provider resources, Cilium policies, Kyverno
policies, Kubernetes RoleBindings, Deployments, or Services.

The desired-state traces are:

```text
user-space/gitops/cpemon/application.yaml
  -> Application XRD
  -> Application Composition
  -> Deployment + Service
  -> Kyverno admission + Workspace Cilium policy

user-space/gitops/cpemon/datastore.yaml
  -> DataStore XRD
  -> DataStore Composition
  -> S3 bucket + public-access block + encryption configuration
```

These are architectural traces, not live runtime evidence.

## Ownership

| CPEmon domain team | Muztagh platform team |
| --- | --- |
| Image and tag | Shared AWS and EKS foundation |
| Requested replicas and application port | Argo CD control-plane structure |
| Approved DataStore request | XRDs and Compositions |
| Business logic and application configuration | Namespace, quota, RBAC, and network isolation |
| Domain incidents | Workload security defaults and Kyverno guardrails |
| Data use and classification | DataStore provider implementation |

## Ordering and reconciliation

The Workspace request uses Argo CD sync wave `0`; the Application and DataStore
requests use wave `10`. This orders Git objects but does not prove Crossplane
has created the `cpemon-dev` Namespace before the namespaced requests are
attempted. The current design relies on Argo CD's bounded retry and subsequent
reconciliation after the Namespace exists. It is not strict runtime dependency
gating.

The user-space Argo Application does not use `CreateNamespace=true`. Its
configured `user-space` namespace is only the default for manifests that omit a
namespace; current domain claims name their tenant namespace explicitly.
Crossplane remains responsible for creating `cpemon-dev` from the Workspace
request.

The current APIs do not provide Kafka, ClickHouse, or other CPEmon-specific
capabilities. Those needs remain explicitly unsupported rather than being added
as special cases to `Workspace`, `Application`, or `DataStore`.

No live Argo CD, Crossplane, Kubernetes admission, Cilium enforcement, or AWS
resource creation is demonstrated by these declarations.
