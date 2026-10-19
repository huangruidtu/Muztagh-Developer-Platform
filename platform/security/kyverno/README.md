# Kyverno guardrails

The `policies/` root contains three enforced controls scoped to Namespaces with
both `platform.muztagh.io/managed-by=platform` and
`platform.muztagh.io/platform=muztagh`:

- `muztagh-required-metadata` requires platform ownership and Application labels
  on Pods and Services.
- `muztagh-restricted-workloads` enforces the Kubernetes restricted Pod Security
  profile.
- `muztagh-service-exposure` permits only ClusterIP Services.

The manifests use `kyverno.io/v1` ClusterPolicy and rule-level
`validate.failureAction`; the deprecated policy-level
`spec.validationFailureAction` field is not used. Kyverno 1.19 deprecates the
ClusterPolicy kind in favor of CEL-based policy types, so a later migration must
be handled as an explicit API and GitOps change. CI tests the current policy
contract with Kyverno CLI 1.19.1.

The Application Composition supplies labels, non-root execution, RuntimeDefault
seccomp, disabled privilege escalation, and dropped Linux capabilities. Images
must run without root or added capabilities. Runtime compatibility has not been
tested on a cluster.

Kyverno and its CRDs must exist before Argo CD reconciles this root. Sync waves
order the child Application objects but do not prove that Kyverno is ready.

`tests/resources/valid/` contains a compliant Pod and ClusterIP Service.
`tests/resources/invalid/` contains a privileged Pod, a LoadBalancer Service,
and a safely configured Pod missing required metadata. The invalid fixtures are
not part of the Argo CD Kustomize root.

Run `scripts/validate.ps1` for Kustomize rendering and `git diff --check`. The
script also runs `kyverno test` when the Kyverno CLI is available. Rendering
does not exercise admission behavior or prove policy enforcement on a cluster.
