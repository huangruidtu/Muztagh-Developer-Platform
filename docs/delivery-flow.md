# Request and reconciliation flow

```text
Developer change
  -> feature branch
  -> pull request
  -> Terraform / manifest / policy / security jobs
  -> required-check
  -> review
  -> merge to main
  -> Argo CD desired-state reconciliation
  -> Crossplane composed resources
  -> readiness and consumer verification
```

The GitHub Actions workflow implements four primary jobs:

- `terraform`: format, offline init/validate, and TFLint.
- `manifests`: actionlint, yamllint, repository validation scripts,
  Kubeconform, negative fixtures, and whitespace checks.
- `policy`: Kyverno CLI tests.
- `security`: Trivy vulnerability/misconfiguration and Gitleaks scans.

`required-check` succeeds only when all four primary jobs succeed. The workflow
exists and has run successfully; this repository does not claim that GitHub
branch protection is configured to require it.

After merge, the manifests describe an intended runtime flow. Argo CD reconciles
approved Git state, and Crossplane translates accepted platform claims into
composed resources. No live cluster reconciliation is evidenced here. Runtime
credentials, controller installation, and production deployment remain
environment responsibilities.

The author owns the submitted intent, reviewers own approval within their
areas, the platform team owns shared contracts and reconcilers, and the domain
team owns the service outcome. See [ownership](ownership.md) and
[CI validation](ci-validation.md).
