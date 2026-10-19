# Resource lifecycle

## Update

After a reviewed change reaches `main`, automated Argo CD sync and `selfHeal`
reconcile tracked desired state. Crossplane then updates composed resources
according to the relevant Composition and provider behavior. Inspect conditions
and events until the contract is Ready; a successful Git merge is not readiness
evidence.

## Delete

Argo CD pruning is disabled. Removing a declaration from Git therefore does not
delete the live claim and does not start Crossplane cleanup. Deletion needs an
explicit, reviewed operational action or a future lifecycle workflow. Before
deleting, identify composed and external resources, their deletion policy, and
the responsible owners.

## DataStore Delete and Orphan

The DataStore Composition maps the API input to managed-resource
`managementPolicies`:

- `Delete` maps to `[*]`, including provider deletion management. Deleting the
  DataStore causes Crossplane to delete its composed managed-resource objects;
  their provider finalizers are intended to delete the external S3 resources
  before those objects disappear.
- `Orphan` maps to `Observe`, `Create`, `Update`, and `LateInitialize`, excluding
  provider deletion. Crossplane can remove the composed managed-resource
  objects while leaving the external S3 resources unmanaged and intact.

Neither path has been exercised against live AWS in this repository. Confirm
external state before and after an approved deletion.

## Revert and rollback

| Action | Effect |
| --- | --- |
| Git revert | Restores an earlier desired declaration; Argo CD reconciles that state after merge |
| Platform rollback | Reverts a platform manifest, Composition, package, or dependency through a reviewed change |
| External recovery | Restores or recreates cloud data/resources using provider or recovery procedures |

A Git revert cannot restore an external resource that was already permanently
deleted. Desired-state rollback and external-state recovery are separate
operations.

## Stuck deletion and finalizers

A resource can remain deleting while a finalizer waits for controller cleanup,
a provider is unavailable, a cloud API or credential fails, or a dependent
resource cannot be removed. With `Delete`, the DataStore can remain terminating
until its managed resources finish provider-side deletion.

Inspect the deletion timestamp, finalizers, conditions, events, controller logs,
and external resource before acting. Restore the responsible controller or
provider and correct the underlying error first. Manual finalizer removal is a
last-resort recovery action because it can abandon or leak external resources;
use it only after documenting the external consequence and obtaining the
appropriate platform/data-owner approval.
