# Platform architecture

Muztagh is organized into three ownership layers. The split keeps the shared
cloud foundation separate from platform reconciliation and from domain intent.

## Layers

| Layer | Repository boundary | Implemented assets | Owner |
| --- | --- | --- | --- |
| Foundation | `foundation/terraform/` | VPC, subnets and routing, platform IAM roles, EKS cluster and node group | Platform team through Terraform |
| Platform control plane | `platform/` | Argo CD hierarchy, Crossplane APIs and Compositions, Cilium policy intent, Kyverno guardrails, Prometheus-compatible rules | Platform team |
| User space | `user-space/` | CPEmon `Workspace`, `Application`, and `DataStore` declarations | Domain team within platform contracts |

The developer-facing API consists of `Workspace`, `Application`, and
`DataStore`. XRDs define the request contract; Compositions define the
platform-owned implementation.

```text
Foundation                         Platform control plane
Terraform                          Argo CD
  -> network                         -> Crossplane packages and APIs
  -> platform identity               -> Kyverno guardrails
  -> EKS                              -> user-space declarations
                                           |
                                           v
User space                               Crossplane
CPEmon claims                              -> Namespace, quota, RBAC
                                           -> Cilium policy intent
                                           -> Deployment and Service
                                           -> S3 resources
```

The repository defines controller and policy prerequisites; it does not install
Argo CD, Crossplane, Cilium, Kyverno, Prometheus, or Grafana.

## Foundation flow

```text
Platform engineer
  -> Terraform environment root
  -> network, platform-identity, and EKS module graph
  -> intended AWS foundation
```

The dev and prod roots compose the same modules rather than duplicate resource
definitions. The EKS module waits for the complete identity module, including
policy attachments. Terraform exclusively owns these foundation resources;
Crossplane does not co-own them.

The code has passed offline formatting, initialization with `-backend=false`,
validation, and TFLint. No Terraform plan against AWS or `terraform apply` has
run, and no VPC or EKS cluster has been created as evidence for this repository.
See [Terraform foundation](terraform-foundation.md).

## Developer request flow

```text
Domain developer
  -> user-space declaration
  -> feature branch and pull request
  -> Terraform / manifest / policy / security checks
  -> required-check and review
  -> merge to main
  -> Argo CD reconciles approved Git state
  -> Crossplane reconciles the platform claim
  -> composed resources become ready
  -> domain team evaluates consumer usability
```

Argo CD owns reconciliation between Git and submitted claims. Crossplane owns
semantic reconciliation between claims and composed resources. Kyverno applies
admission policy to platform-managed workloads when its controller is present;
the Workspace Composition emits the Cilium network-policy intent that Cilium
would enforce. No single component owns every layer.

Automated Argo sync and self-heal are enabled, pruning is disabled, and retries
are bounded. Sync waves order child `Application` objects but are not a hard
runtime-readiness barrier between independently reconciling applications. See
[GitOps reconciliation](gitops.md).

Bootstrap readiness remains planned work. The root has no child `Application`
health customization, Crossplane package installation is distinct from package
health, and API discovery or external-provider readiness is not gated by the
current wave annotations. The verified dependency model and recovery backlog
are in [bootstrap reliability](operations/bootstrap-reliability.md); none of
those proposed gates is represented as current runtime behavior.

## Tenancy and authorization

The cluster-scoped `Workspace` establishes the approved tenant boundary.
Namespaced `Application` and `DataStore` claims are then allowed only inside the
explicitly approved `cpemon-dev` destination. Crossplane may bind only the
`muztagh-domain-developer` ClusterRole when composing tenant access. Detailed
RBAC, policy, readiness, and network behavior is in
[tenancy and security](tenancy-security.md).

## Operations and validation

The repository contains three Prometheus-compatible Argo CD rules, a dashboard
model, lifecycle guidance, and runbooks. It does not contain a Prometheus or
Grafana installation or runtime evidence. GitHub Actions statically checks
Terraform, manifests, policy behavior, workflow/YAML syntax, vulnerabilities,
and secrets. See [platform health](operations/platform-health.md),
[CI validation](ci-validation.md), and [the truth boundary](truth-boundary.md).
