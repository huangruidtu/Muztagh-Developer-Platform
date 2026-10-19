# Evidence and truth boundary

This document separates repository artifacts from static execution evidence and
from behavior that requires a live platform.

## Implemented in the repository

- Terraform `network`, `platform-identity`, and `eks` modules with dev and prod
  composition roots.
- Argo CD AppProjects, root Application, and four-child application hierarchy.
- Crossplane `Workspace`, `Application`, and `DataStore` XRDs and Compositions.
- Workspace Namespace, ResourceQuota, bounded RBAC binding, and Cilium
  network-policy intent.
- Application workload security defaults and three Kyverno guardrails.
- CPEmon `cpemon-dev`, `cpemon-api`, and `cpemon-backup` declarations.
- Three Prometheus-compatible Argo CD alert rules, a dashboard model, lifecycle
  guidance, and two runbooks.
- GitHub Actions Terraform, manifest, policy, security, and aggregate jobs.
- TFLint, Kubeconform, Kyverno, Trivy, Gitleaks, actionlint, yamllint, and
  negative-fixture validation paths.
- Weekly Dependabot configuration for GitHub Actions and both Terraform roots.

## Actually executed or validated

The repository workflow executes:

- `terraform fmt -check`, `terraform init -backend=false`, and
  `terraform validate` for dev and prod.
- TFLint with the Terraform core ruleset.
- Kustomize rendering for managed roots.
- strict Kubeconform validation for built-in Kubernetes resources against the
  configured Kubernetes 1.31 schema, with custom resources skipped where a
  schema is unavailable.
- a negative built-in-schema fixture that must fail validation.
- Kyverno CLI 1.19.1 policy tests.
- `promtool check rules` for the Prometheus-compatible rules.
- actionlint and yamllint.
- Trivy HIGH/CRITICAL vulnerability and misconfiguration scanning with the
  repository ignore policy.
- Gitleaks history scanning.

[MDP-9 PR #8](https://github.com/huangruidtu/Muztagh-Developer-Platform/pull/8)
completed the real GitHub Actions `terraform`, `manifests`, `policy`,
`security`, and `required-check` jobs successfully. That execution proves the
static workflow ran for that pull request; it does not prove runtime behavior.

Custom Crossplane, Argo CD, Kyverno, Cilium, and provider resources are rendered
and checked by targeted scripts, but Kustomize is not CRD schema validation.
Kubeconform skips custom resources when their schemas are not available. There
has been no live API-server admission or provider-CRD schema validation.

## Not executed live

- No Terraform plan against AWS and no `terraform apply`.
- No real AWS VPC, subnets, IAM roles, EKS cluster, or node group provisioning.
- No live Argo CD reconciliation.
- No live Crossplane control-plane or provider reconciliation.
- No live Cilium enforcement.
- No live Kyverno admission-webhook behavior.
- No AWS S3 provisioning from a `DataStore` claim.
- No live Prometheus rule loading or alert firing.
- No running Grafana dashboard.
- No production traffic, incidents, availability measurement, or SLO evidence.

Argo CD, Crossplane, Cilium, Kyverno, Prometheus, and Grafana installation is
outside the implemented repository scope. Provider credentials, remote
Terraform state, and production environment configuration are also absent.

## Claim boundary

This repository is an architecture-complete, code-complete, offline-validated
Central Developer Platform reference implementation. It is not evidence of live
production AWS platform operation.

It supports claims about provider-side IaC authorship, Terraform module design,
platform API and GitOps design, tenancy and security decisions, CI guardrails,
and operational reasoning. It does not support claims that this Muztagh platform
was operated in production, that its EKS foundation was provisioned, or that its
Crossplane resources served live workloads.
