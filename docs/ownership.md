# Ownership model

Ownership follows the reconciler and resource boundary, not repository write
access.

| Area | Owner | Concrete responsibility |
| --- | --- | --- |
| Shared AWS/EKS foundation | Platform team through Terraform | Network, EKS, baseline platform identity, and their lifecycle |
| Git desired state | Platform team through Argo CD | Reconcile approved platform and user-space manifests from `main` |
| Platform capabilities | Platform team through Crossplane | XRD contracts, Compositions, provider integration, composed-resource readiness |
| Tenancy and guardrails | Platform team | Workspace boundary, quota, RBAC, network-policy intent, workload defaults, and Kyverno policy |
| Domain workload intent | Domain team | Supported application image, version, replicas, port, datastore request, and Workspace metadata |
| Domain behavior | Domain team | Business logic, application configuration outside the platform contract, data semantics, and domain health |
| Shared operating model | Platform team | Platform alerts, dependency lifecycle, and platform runbooks |
| Domain operations | Domain team, with platform escalation where needed | Service health, application failures, and evidence needed for handoff |

Terraform and Crossplane ownership is exclusive: Terraform owns the shared
foundation; Crossplane owns only the selected developer-facing capability
resources expressed by Compositions. Argo CD submits approved desired state but
does not replace either resource reconciler.

Failure ownership depends on evidence. An invalid image or unhealthy application
is normally a domain issue; a malformed Composition, provider failure, or shared
controller fault is normally a platform issue. Diagnosis can cross that boundary
without transferring permanent ownership.

Shared contract changes use a pull request with platform review and domain-team
review when consumer behavior changes. See [delivery flow](delivery-flow.md) and
[tenancy and security](tenancy-security.md).
