# CI validation

The pull-request workflow is a review gate, not a deployment pipeline.

```text
                         +-> terraform -+
                         +-> manifests --+
pull request to main ----+-> policy -----+-> required-check -> merge eligibility
                         +-> security ---+
```

The four primary jobs run independently on every pull request. The stable final
check is `required-check`; repository branch-protection settings should require
that check. This repository does not configure or claim branch protection.

## Checks and limits

| Check | What it catches | What it does not prove |
| --- | --- | --- |
| `terraform fmt`, `init -backend=false`, and `validate` | Formatting, provider/module initialization, and Terraform configuration errors in dev and prod | AWS credentials, planning, or deployment behavior |
| TFLint | Terraform language issues across environment roots and local modules | Cloud API correctness or runtime behavior |
| Existing PowerShell validators and `kubectl kustomize` | Broken Kustomize references and render failures | CRD semantics or live admission/reconciliation |
| Kubeconform | Built-in Kubernetes schema errors in rendered output | Custom resources whose schemas are unavailable |
| actionlint and yamllint | GitHub Actions semantic errors and proportionate YAML issues | Successful execution of external tools |
| Kyverno CLI tests | Expected valid fixtures pass and unsafe fixtures are rejected | A live Kyverno webhook or cluster admission behavior |
| Trivy filesystem scan | HIGH and CRITICAL fixable dependency or configuration findings | Runtime security or container image vulnerabilities |
| Gitleaks | Likely secrets in the pull-request commit range, with PR comments and artifact upload disabled | GitHub push protection or runtime secret management |

Kubeconform runs in strict mode against Kubernetes 1.31 schemas. It uses
`-ignore-missing-schemas` because the repository contains Argo CD, Crossplane,
Kyverno, Cilium, `platform.muztagh.io`, and Upbound provider resources without a
complete verified offline schema set. Those resources are still rendered, but
rendering is not semantic CRD validation.

## Pinned tools

GitHub Actions are pinned to full commit SHAs with release comments. Directly
downloaded tools use versioned release URLs and embedded SHA-256 checksums.
Current CI pins include Terraform 1.16.6, TFLint 0.64.0, kubectl 1.37.1,
Kubeconform 0.8.0, actionlint 1.7.12, promtool 3.15.0, yamllint 1.38.0,
Kyverno CLI 1.19.1, Trivy 0.76.0, and Gitleaks 8.30.1. TFLint uses its
core rules only; no cloud-provider ruleset is configured in this story.

The Kyverno version is the repository's current 1.19.x compatibility target;
CI does not migrate the policies to the CEL API. The negative schema test under
`validation/fixtures/` passes only when Kubeconform rejects its intentionally
invalid Service. Existing Kyverno tests separately assert that unsafe workload
fixtures produce policy failures. Their values file supplies the labels of the
mock tenant Namespace so `namespaceSelector` rules are evaluated offline.

Trivy scans repository files for vulnerabilities and misconfigurations and
fails on fixable HIGH or CRITICAL findings. It does not scan container images
because this repository builds none. Narrow, path-scoped exceptions in
`.trivyignore.yaml` record the current EKS encryption, public-subnet, Crossplane
Service RBAC, and intentionally privileged policy-fixture decisions. Gitleaks
scans the action's pull-request commit range from a full-history checkout.
GitHub secret scanning and push protection should also be enabled in repository
settings when available; they are not configured or claimed here.

Dependabot checks GitHub Actions and Terraform provider state in the dev and
prod environment directories weekly. Its pull requests run through this same
workflow. Tool upgrades remain reviewed changes when Dependabot cannot manage
an embedded binary version.
