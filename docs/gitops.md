# Argo CD GitOps control plane

The manifests model GitOps reconciliation after Argo CD is installed. They do
not install Argo CD and have not been applied to a cluster.

## Application hierarchy

The bootstrap AppProject restricts sources to this repository and destinations
to the in-cluster Kubernetes API. The root Application reconciles three child
Applications:

```text
muztagh-platform
├── muztagh-platform-controllers  (sync wave 0)
├── muztagh-platform-capabilities (sync wave 10)
└── muztagh-user-space            (sync wave 20)
```

The child sources are empty Kustomize roots. Later stories can add controllers,
shared capabilities or policies, and domain declarations without changing the
bootstrap model. ApplicationSet is not used because three static boundaries do
not require generation.

Sync waves order child Application resources as controllers, capabilities, then
user space. They make creation order explicit but do not replace runtime
readiness checks inside future components. If an upstream component is not
ready, its Application remains unhealthy and downstream reconciliation may fail
and retry rather than treating the dependency as available.

## Reconciliation

The `main` branch is the desired-state source of truth. Automated sync is
enabled so committed changes and detected drift are reconciled without a manual
sync operation. `selfHeal: true` restores tracked fields changed in the cluster.

Pruning is disabled. Removing a manifest from Git does not delete the live
resource automatically; the Application remains OutOfSync until deletion is
reviewed and performed explicitly. This is the safe default for the bootstrap
stage. Enabling prune later requires a separate change with ownership and
deletion safeguards.

When Argo CD detects a difference, it marks the Application OutOfSync and
attempts an automated sync. Transient failures use three bounded retries. A
failure after those retries remains visible as a failed or degraded operation
and requires correction in Git or operator investigation. There is no automatic
rollback to an older commit.

## Failure and rollback behaviour

| Condition | Expected behaviour |
| --- | --- |
| Invalid Kustomize or YAML input | Manifest generation fails; no sync begins for that Application. |
| Kubernetes rejects a resource | The sync fails; resources already accepted are not automatically rolled back. |
| Dependency unavailable | The dependent Application may remain Progressing, Degraded, or OutOfSync and retries are bounded. |
| Resource remains unhealthy | Argo CD reports unhealthy status; it does not promote later work as healthy or invent a rollback. |
| Bad Git change | Revert or correct the commit through a reviewed PR; Argo CD then reconciles the new `main` state. |
| Resource removed from Git | Prune is disabled, so the live resource remains until deletion is explicitly approved. |

Git revert is the rollback mechanism because automated sync continues to follow
`main`. An imperative UI rollback without a matching Git change would be
replaced by the declared Git state.

## Static validation

Run `platform/argocd/scripts/validate.ps1` from PowerShell. It renders the
bootstrap, Application hierarchy, and every managed Kustomize root with
`kubectl kustomize`, then runs `git diff --check`. This validates local YAML and
Kustomize structure only; schema-aware Argo CD validation requires the Argo CD
CRD schemas and is not evidence of a live installation.
