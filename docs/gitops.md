# Argo CD GitOps control plane

The manifests model GitOps reconciliation after Argo CD is installed. They do
not install Argo CD and have not been applied to a cluster.

## Application hierarchy

The bootstrap AppProject restricts sources to this repository and destinations
to the `argocd`, `platform-system`, and `user-space` namespaces on the
in-cluster Kubernetes API. Its cluster-scoped allowlist contains `Namespace`
and the exact Crossplane package, definition, composition, and RBAC kinds used
by MDP-5. Additional cluster-scoped kinds require reviewed allowlist changes;
wildcard cluster permissions are not used.

The root Application reconciles three child Applications:

```text
muztagh-platform
├── muztagh-platform-controllers  (sync wave 0)
├── muztagh-platform-capabilities (sync wave 10)
└── muztagh-user-space            (sync wave 20)
```

The controllers layer reconciles the pinned Crossplane Function and Provider
packages. The capabilities layer reconciles XRDs, Compositions, and developer
RBAC. Crossplane core is a prerequisite and is not installed by this repository.
The user-space layer remains the boundary for domain declarations. ApplicationSet
is not used because three static boundaries do not require generation.

Sync waves order the child Application resources as controllers, capabilities,
then user space. Each child Application reconciles independently. Argo CD does
not provide the former built-in health assessment for Application custom
resources by default, so these waves are not a hard runtime-readiness barrier
between child Applications.

If strict child-Application readiness gating is required later, Muztagh must add
an explicit Application health customization or use another dependency
strategy. MDP-4 does not configure either mechanism.

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
bootstrap, Application hierarchy, Crossplane package and capability roots, and
the user-space root with
`kubectl kustomize`, then runs `git diff --check`. This validates local YAML and
Kustomize structure only; schema-aware Argo CD validation requires the Argo CD
CRD schemas and is not evidence of a live installation.
