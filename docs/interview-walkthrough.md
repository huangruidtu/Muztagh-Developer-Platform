# Interview walkthrough

This guide explains the implementation and its evidence. It is not a scripted
claim of production experience.

## A. 60-second project overview

I built Muztagh as a reference implementation of a Central Developer Platform.
Terraform defines a shared AWS network, identity, and EKS foundation. Argo CD
models GitOps reconciliation from approved Git state. Crossplane publishes
three developer contracts—`Workspace`, `Application`, and `DataStore`—and maps
them to Kubernetes and selected AWS resources. Workspace RBAC, Cilium policy
intent, Kyverno tests, alerts, runbooks, and CI show how the platform boundary
is operated. CPEmon is the first reference consumer, but the shared APIs contain
no CPEmon-specific fields. The repository is validated offline; it has not
provisioned AWS or run these controllers in a live cluster.

## B. Five-minute architecture walkthrough

1. **Central Platform:** the top-level `foundation/`, `platform/`, and
   `user-space/` boundaries separate provider infrastructure, shared
   capabilities, and domain intent.
2. **Terraform foundation:** dev and prod roots compose network,
   platform-identity, and EKS modules. Terraform exclusively owns this layer.
3. **GitOps control plane:** the Argo root Application declares controllers,
   capabilities, guardrails, and user-space children. Sync is automated with
   self-heal, disabled prune, and bounded retries.
4. **Platform API:** Crossplane XRDs define allowed inputs. Compositions map
   them to Namespace/quota/RBAC/network intent, Deployment/Service, and S3
   resources.
5. **Security and tenancy:** the Workspace creates the tenant boundary;
   developer RBAC excludes Workspace management, the user-space AppProject is
   restricted to `cpemon-dev`, and Kyverno checks platform-managed workloads.
6. **CPEmon golden path:** `cpemon-dev`, `cpemon-api`, and `cpemon-backup`
   exercise all three contracts. Unsupported dependencies remain explicit.
7. **Observability and day-2:** three Argo rules cover prolonged OutOfSync,
   Degraded, and repeated real sync failures. Runbooks separate Git,
   controller, provider, and workload failures.
8. **CI quality gate:** Terraform, manifest, policy, and security jobs feed
   `required-check`. The workflow proves static quality gates, not live cloud
   behavior.

The two control flows remain separate: Terraform expresses provider-side
foundation infrastructure; Argo and Crossplane reconcile developer requests.

## C. Major design decisions

### Why Terraform?

It gives the AWS/EKS foundation one owner and an explicit dependency graph.
Crossplane does not co-own those resources. The trade-off is maintaining a
separate provisioning model for developer-facing capabilities.

### Why Argo CD?

It provides an explicit Application hierarchy, drift detection, and self-heal
from Git. Prune is disabled to make deletion deliberate. Sync waves are useful
ordering hints, not readiness guarantees between child Applications.

### Why Crossplane?

XRDs separate a small developer contract from platform-owned implementation.
Crossplane is used only for published capabilities; it is not a universal
replacement for Terraform.

### Why Git/YAML first and no Backstage?

The API and authorization model need to be stable before adding a portal. Git
already supplies review, history, and CI. A later UI or CLI can generate the
same claims without becoming the source of the contract.

### Why CPEmon first?

A concrete consumer exposes gaps in the generic APIs. Kafka or ClickHouse needs
do not justify adding CPEmon-specific fields. A missing capability stays missing
until it can be designed as a shared platform product.

The detailed decisions are in the [ADR index](adr/README.md).

## D. Ownership questions

| Question | Answer |
| --- | --- |
| What does Terraform own? | Shared VPC/routing, platform IAM roles, EKS cluster, and node group. |
| What does Crossplane own? | Resources emitted by the three Compositions: tenant Kubernetes resources, application Deployment/Service, and DataStore S3 resources. |
| What does Argo CD own? | Reconciliation of approved Git state into platform and user-space Kubernetes resources. It does not own AWS foundation state or composed-resource semantics. |
| What does the domain team own? | Application image/version, supported workload intent, business behavior, data semantics, and domain health. |
| Who owns an Application failure? | Evidence decides. Image or application behavior points to the domain team; invalid generated resources or controller faults point to the platform team. Diagnosis may require both. |

## E. Failure scenario walkthrough

### Application does not become available

```text
Developer changes cpemon-api
  -> PR checks pass
  -> Argo CD syncs the Application claim
  -> Crossplane creates Deployment and Service
  -> Deployment Available condition stays false
  -> inspect claim conditions, Deployment status, ReplicaSet, Pod, and events
```

An image-pull, crash-loop, or bad application configuration is returned to the
domain owner. An invalid patch, missing permission, or malformed generated
Deployment is a platform issue. Recovery is a Git correction or revert followed
by reconciliation; CI success alone never asserted workload readiness.

### DataStore does not become ready

Inspect the `DataStore` conditions, composed Bucket, public-access block and
encryption resources, provider status, and events. Invalid region or provider
credentials/configuration is distinguished from an XRD or Composition defect.
The platform owner handles provider or Composition failures; the requester
corrects unsupported intent. `deletionPolicy: Orphan` also means cleanup must
respect the declared lifecycle rather than assume automatic deletion.

See the [provisioning](runbooks/provisioning-failure.md) and
[reconciliation](runbooks/reconciliation-failure.md) runbooks.

## F. Trade-offs

- **Prune disabled:** safer deletion behavior, but stale resources require an
  explicit operating action.
- **Tenant allowlist:** `cpemon-dev` is an auditable authorization boundary, but
  each new tenant needs a reviewed AppProject change until registration is
  automated.
- **No Backstage:** avoids coupling UI work to an unsettled contract, but leaves
  Git and YAML as the developer experience.
- **No live cloud deployment:** keeps the project self-contained and avoids
  unsupported operating claims, but leaves runtime integration unproven.
- **Small API:** improves reuse and ownership clarity, but does not cover every
  domain dependency.
- **Custom schema coverage:** rendering and targeted checks catch structure and
  contract invariants, while custom CRD API-server validation remains absent.
- **Kyverno compatibility:** tests target CLI 1.19.1 with deprecated
  `kyverno.io/v1 ClusterPolicy`; migration to CEL policy APIs is a separate
  reviewed change.

## G. Truthful interview boundary

### What I can say

> I built a reference implementation of a Central Developer Platform. I focused
> on the architecture, provider-side IaC structure, platform APIs, GitOps,
> guardrails, CI, and day-2 operations. The cloud portion was intentionally kept
> offline, so I would not describe it as production AWS operating experience.

The repository supports discussion of module design, resource ownership,
developer contracts, failure boundaries, policy tests, CI execution, and
operational trade-offs.

### What I should not claim

- That Muztagh provisioned or operated production AWS resources.
- That the EKS, Argo CD, Crossplane, Cilium, Kyverno, Prometheus, or Grafana
  design was exercised as a live integrated platform.
- That CPEmon here is a production migration or historical-system replica.
- That successful static CI demonstrates production availability, security, or
  SLO attainment.

The complete boundary is in [evidence and truth boundary](truth-boundary.md).

## H. Evidence map

| Claim | Evidence | Validation | Limitation |
| --- | --- | --- | --- |
| I structured provider-side Terraform modules | `foundation/terraform/modules/` and environment roots | Terraform fmt, offline init/validate, TFLint, CI | No AWS plan or apply |
| I defined GitOps reconciliation | `platform/argocd/`, `docs/gitops.md` | Kustomize and targeted static checks, CI | No live Argo CD controller |
| I built developer-facing APIs | Crossplane XRD and Composition files | Rendering, contract scripts, Kubeconform for built-ins | No live Crossplane runtime; incomplete custom-CRD schema coverage |
| I designed tenant authorization | Workspace Composition/RBAC and two AppProjects | Static invariants and manifest checks | Only `cpemon-dev`; no live RBAC or admission test |
| I implemented policy tests | Kyverno policies and tests | Kyverno CLI 1.19.1 locally and in CI | No live admission webhook; legacy API compatibility target |
| I modeled network isolation | Workspace `CiliumNetworkPolicy` resource | Crossplane validation and rendering | Cilium is not installed; no enforcement evidence |
| I onboarded a first consumer without special-casing the API | `user-space/gitops/cpemon/` and shared XRDs | Kustomize, allowlist checks, CI | Reference declarations only; missing domain capabilities remain missing |
| I defined day-2 alerting and recovery | `platform/observability/`, operations docs, runbooks | `promtool check rules` and documentation review | No Prometheus/Grafana runtime or alert history |
| I created PR quality gates | `.github/workflows/pr-validation.yaml` | Successful GitHub Actions execution on PR #8 | Branch protection is not configured by repository code |
| I added dependency hygiene | `.github/dependabot.yml`, pinned tools/actions, dependency lifecycle case study | actionlint, CI, documented Kyverno review | Notifications do not replace tested upgrades or runtime rollout |
