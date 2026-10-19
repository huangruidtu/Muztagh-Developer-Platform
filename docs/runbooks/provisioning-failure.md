# Provisioning failure runbook

Use this runbook when a platform request was accepted but did not produce a
usable capability. Start from the claim condition, then follow its current
Composition path.

## Workspace

```text
Workspace
  -> Namespace
  -> ResourceQuota
  -> RoleBinding
  -> CiliumNetworkPolicy
```

```text
kubectl describe workspaces.platform.muztagh.io cpemon-dev
kubectl get namespace cpemon-dev
kubectl get resourcequota workspace-defaults -n cpemon-dev
kubectl get rolebinding domain-developers -n cpemon-dev
kubectl get ciliumnetworkpolicy workspace-isolation -n cpemon-dev
kubectl get events -n cpemon-dev --sort-by=.lastTimestamp
```

Check Namespace `Active` and Cilium policy `Valid=True`. Quota and RoleBinding
use existence-only readiness in the current Composition, so inspect their
content rather than assuming they are effective. A valid Cilium condition does
not prove connectivity.

Typical platform failures are missing Cilium CRDs/controllers, Composition
errors, insufficient Crossplane RBAC, invalid developer-group binding, or a
Namespace stuck terminating.

## Application

```text
Application
  -> Deployment
  -> Service
  -> admission/security compatibility
  -> Deployment Available
```

```text
kubectl describe applications.platform.muztagh.io cpemon-api -n cpemon-dev
kubectl describe deployment cpemon-api -n cpemon-dev
kubectl get service cpemon-api -n cpemon-dev -o yaml
kubectl get pods -n cpemon-dev -l platform.muztagh.io/application=cpemon-api
kubectl get events -n cpemon-dev --sort-by=.lastTimestamp
```

If Kubernetes rejects the generated workload, inspect Kyverno policy results
and whether the Composition produced the required labels and restricted
security context. If the Deployment exists but is unavailable, inspect Pod
status and events.

- Platform team: generated manifests, security defaults, admission policy,
  Service shape, quota/RBAC/network boundary, and shared cluster failures.
- Domain team: nonexistent or incompatible image/tag, process startup,
  application configuration, business logic, and application behavior.

The handoff is evidence-based. An image that cannot run non-root is normally a
domain compatibility issue; a Composition that omits the enforced security
fields is a platform issue.

## DataStore

```text
DataStore
  -> S3 Bucket
  -> BucketPublicAccessBlock
  -> BucketServerSideEncryptionConfiguration
  -> provider and cloud API
```

```text
kubectl describe datastores.platform.muztagh.io cpemon-backup -n cpemon-dev
kubectl get buckets.s3.aws.m.upbound.io -n cpemon-dev
kubectl get bucketpublicaccessblocks.s3.aws.m.upbound.io -n cpemon-dev
kubectl get bucketserversideencryptionconfigurations.s3.aws.m.upbound.io -n cpemon-dev
kubectl get clusterproviderconfigs.aws.m.upbound.io default -o yaml
kubectl get events -n cpemon-dev --sort-by=.lastTimestamp
```

Inspect `Ready` and `Synced` conditions on each managed resource. Common
platform-side causes are an unavailable provider, missing `default`
ClusterProviderConfig, invalid credentials, insufficient IAM, region/API
failure, Composition patch error, or blocked deletion/finalizer. Do not expose
credential material while collecting evidence.

A Ready provider resource still does not prove that a workload has credentials
or can perform its intended data operation; application integration and data
semantics remain a domain responsibility.

## Recovery and verification

Correct the owning input or platform component, then observe conditions and
events until they stabilize. Verify both the implementation readiness gate and
the consumer-facing capability. Record any manual intervention separately; the
repository does not currently emit a metric for it.

No live Kubernetes, Crossplane, Cilium, Kyverno, or AWS failure was exercised
for this reference runbook.
