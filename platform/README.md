# Platform

This directory is the implementation space for the platform control plane and
developer-facing platform capabilities. The Argo CD GitOps structure is defined
under [argocd/](argocd/); it does not install or run Argo CD.

The Crossplane API definitions, Compositions, and package prerequisites are
under [crossplane/](crossplane/). Crossplane core is an external prerequisite;
these manifests do not install or run it.

Platform-owned admission guardrails are under [security/](security/). Cilium
and Kyverno are runtime prerequisites and are not installed here. Reference
Prometheus rules and the observability validation path are under
[observability/](observability/); no monitoring stack is installed. Domain
workloads and product-specific settings do not belong in this directory.
