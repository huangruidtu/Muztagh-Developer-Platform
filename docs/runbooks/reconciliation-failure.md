# Reconciliation failure runbook

Use this runbook when Git desired state is not converging. Locate the first
failed handoff rather than treating every failure as an Argo CD problem.

```text
Git desired state
  -> Kustomize render
  -> AppProject authorization
  -> Kubernetes API admission
  -> platform claim exists
  -> Crossplane reconciliation
  -> composed resources
  -> runtime readiness
```

## 1. Establish the failing layer

```text
kubectl get applications.argoproj.io -n argocd
kubectl describe applications.argoproj.io muztagh-user-space -n argocd
kubectl get events -n argocd --sort-by=.lastTimestamp
```

- OutOfSync with a manifest-generation error: inspect Git/YAML and Kustomize.
- Permission or destination error: inspect the referenced AppProject.
- Synced but claim not Ready: move to Crossplane inspection.
- Claim Ready but capability unusable: move to implementation/runtime checks.

## 2. Argo CD path

1. Reproduce rendering locally:

   ```text
   kubectl kustomize platform/argocd/bootstrap
   kubectl kustomize platform/argocd/applications
   kubectl kustomize user-space/gitops
   ```

2. Compare the Application source path, revision, project, server, and
   destination namespace with Git.
3. Inspect AppProject destinations and resource allowlists:

   ```text
   kubectl get appprojects.argoproj.io -n argocd
   kubectl describe appprojects.argoproj.io muztagh-user-space -n argocd
   ```

4. Confirm required CRDs exist before the claims are submitted:

   ```text
   kubectl api-resources --api-group=platform.muztagh.io
   kubectl get compositeresourcedefinitions.apiextensions.crossplane.io
   ```

5. Read the sync operation message and Kubernetes events for admission
   rejection. Likely causes include an unavailable CRD, an AppProject
   destination/kind restriction, or Kyverno rejection.
6. For first-time tenant onboarding, remember that sync wave `0` only orders the
   Workspace object before wave `10` claims. It does not prove Crossplane has
   created the Namespace. Bounded retries can be exhausted before the Namespace
   becomes available.

Correct or revert the Git change for render or authorization errors. Do not
bypass the AppProject boundary to make a claim sync.

For bootstrap incidents, record child sync and health separately. Until the
planned `Application` health customization exists, a later wave's presence is
not proof that an earlier child became healthy. Inspect package revisions, XRD
establishment, and API discovery before moving downstream. The failure triggers
and recovery evidence are defined in the
[bootstrap reliability plan](../operations/bootstrap-reliability.md).

## 3. Crossplane path

If the claim exists, inspect its conditions and events:

```text
kubectl get workspaces.platform.muztagh.io
kubectl describe workspaces.platform.muztagh.io cpemon-dev
kubectl get applications.platform.muztagh.io -A
kubectl describe applications.platform.muztagh.io cpemon-api -n cpemon-dev
kubectl get datastores.platform.muztagh.io -A
kubectl describe datastores.platform.muztagh.io cpemon-backup -n cpemon-dev
kubectl get events -n cpemon-dev --sort-by=.lastTimestamp
```

Then verify control-plane dependencies:

```text
kubectl get compositions.apiextensions.crossplane.io
kubectl get functions.pkg.crossplane.io
kubectl get providers.pkg.crossplane.io
```

Interpret the first non-ready condition:

- Composition or function error: platform team corrects the shared pipeline.
- Function or provider unavailable: platform team restores the package/runtime.
- Provider configuration or cloud API error: platform team checks configuration,
  credentials, IAM, network access, and provider events.
- Composed resource not Ready: inspect that resource's conditions and events.
- Deletion timestamp with finalizer: use the lifecycle runbook; do not remove the
  finalizer blindly.

## 4. Escalation evidence

Record the Git revision, Argo Application and operation message, claim YAML
including conditions, relevant events, first failing composed resource, and the
time the failure began. Hand off only after identifying whether the fault is in
GitOps, platform reconciliation, provider/cloud integration, or domain runtime.

No live failure was reproduced for this reference runbook.
