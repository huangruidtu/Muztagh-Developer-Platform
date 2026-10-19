# Platform observability assets

This directory contains reference Prometheus-compatible rules for operating the
published Muztagh capabilities. It does not install Prometheus, Prometheus
Operator, Alertmanager, or Grafana, and it is not part of an Argo CD managed
root.

The rules use metrics documented by the current upstream projects:

- Argo CD `argocd_app_info` with `project`, `sync_status`, and `health_status`
  labels, and `argocd_app_sync_total` with the `phase` label.

Sources:

- [Argo CD application-controller metrics](https://argo-cd.readthedocs.io/en/latest/operator-manual/metrics/)
- [Argo CD metric label examples in the upstream tests](https://github.com/argoproj/argo-cd/blob/master/controller/metrics/metrics_test.go)
- [Crossplane metrics](https://docs.crossplane.io/latest/guides/metrics/)

The `for` durations are reference operational defaults, not production SLOs or
validated incident thresholds. The expressions select Applications in the
`argocd` namespace and the repository's `muztagh` and `muztagh-user-space`
projects.

Crossplane documents provider-wide `crossplane_managed_resource_*` metrics,
but their current labels do not identify a Muztagh claim or tenant. No alert is
defined from those aggregates because it could attribute unrelated provider
resources to Muztagh. Claim readiness, provisioning latency, and provider
failures remain future instrumentation until scrape targets and stable resource
selectors are defined.

Run `scripts/validate.ps1`. It uses `promtool check rules` when `promtool` is
available and always runs `git diff --check`. No rule is loaded or evaluated by
this repository.
