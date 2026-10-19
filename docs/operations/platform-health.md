# Platform health

Muztagh is healthy when a valid developer request can move from Git to a usable
capability. Controller process uptime alone does not establish platform health.
Component health answers whether a controller or provider process is running.
Platform health answers whether the published contract accepts a request,
reconciliation progresses, the composed capability becomes Ready, and a
failure can be located.

## Health layers

| Layer | Healthy evidence | First inspection |
| --- | --- | --- |
| 1. GitOps convergence | Platform and user-space Argo CD Applications are Synced and not Degraded | `kubectl get applications.argoproj.io -n argocd` |
| 2. API availability | Workspace, Application, and DataStore resources are discoverable; XRDs are established | `kubectl get xrds` and `kubectl api-resources --api-group=platform.muztagh.io` |
| 3. Reconciliation | Claim conditions progress without repeated errors or prolonged non-ready state | Get and describe the platform claims |
| 4. Implementation | Composition-specific readiness checks pass | Inspect the composed Kubernetes or provider resources |
| 5. Consumer usability | The requested application or datastore can be used according to its contract | Domain-appropriate runtime or client checks |

The repository supplies no end-to-end probes, so layer 5 requires environment
and domain evidence outside these manifests.

## Current readiness semantics

| Contract | Composition readiness evidence | What it does not prove |
| --- | --- | --- |
| Workspace | Namespace `status.phase=Active`; CiliumNetworkPolicy `Valid=True`; ResourceQuota and RoleBinding exist | DNS/network connectivity, authorization effectiveness, or workload reachability |
| Application | Deployment `Available=True`; Service exists | Application endpoint correctness, business health, or network reachability |
| DataStore | Bucket, public-access block, and encryption resources each report `Ready=True` | Client credentials, application access, data recovery, or cloud-side durability testing |

Crossplane conditions on a claim should be read together with the composed
resource conditions and events. Object existence is not sufficient evidence of
usability.

## Operational signals

These are signals, not production SLOs:

| Signal | Current source | Use |
| --- | --- | --- |
| Argo CD sync and health state | `argocd_app_info` | Detect drift, failed convergence, and degraded Applications |
| Failed sync attempts | `argocd_app_sync_total{phase=...}` | Detect repeated GitOps sync failures |
| Claim Ready/Synced conditions | Kubernetes API | Identify Workspace, Application, or DataStore requests needing investigation |
| Provider resource readiness | Kubernetes managed-resource conditions | Identify DataStore resources that are not Ready or Synced |
| Deletion/finalizer age | Kubernetes metadata, conditions, and events | Find resources stuck deleting |

No PromQL rule is included for claim counts, manual-intervention counts, or
claim time-to-readiness. Crossplane documents
`crossplane_managed_resource_exists`, `crossplane_managed_resource_ready`,
`crossplane_managed_resource_first_time_to_readiness_seconds`, and
`controller_runtime_reconcile_errors_total`, but the repository does not define
scrape targets or selectors that attribute those series to Muztagh resources.
This repository also has no claim-state exporter or stable manual-intervention
event source. Useful future measures include claims needing operator action,
platform-assisted provisioning failures, and time from failed request to
restored reconciliation.

## Claim inspection

```text
kubectl get workspaces.platform.muztagh.io
kubectl describe workspaces.platform.muztagh.io cpemon-dev

kubectl get applications.platform.muztagh.io -A
kubectl describe applications.platform.muztagh.io cpemon-api -n cpemon-dev

kubectl get datastores.platform.muztagh.io -A
kubectl describe datastores.platform.muztagh.io cpemon-backup -n cpemon-dev

kubectl get events -n cpemon-dev --sort-by=.lastTimestamp
```

Start with the claim condition reason and message, then inspect the exact
composed resource named in the Composition path. See the reconciliation and
provisioning runbooks for layer-specific checks.

## Ownership

The platform team primarily owns Argo CD platform reconciliation, Crossplane,
XRDs and Compositions, providers, shared infrastructure, and tenant guardrails.
The domain team primarily owns image validity, process startup, business logic,
application configuration, and domain alerts. A failure can cross that boundary:
for example, the platform team verifies the generated Deployment and policy,
then hands an image startup failure to the domain team with evidence.
