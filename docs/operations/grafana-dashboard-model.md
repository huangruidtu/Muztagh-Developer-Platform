# Grafana dashboard model

This is an operator dashboard specification, not an exported dashboard. Grafana
and its data sources are not installed by this repository.

| Section | Panel question | Source | Current status |
| --- | --- | --- | --- |
| Platform overview | Which Muztagh Argo CD Applications are Synced, OutOfSync, Healthy, or Degraded? | `argocd_app_info` grouped by `project`, `name`, sync and health labels | Supported when Argo CD metrics are scraped |
| Platform overview | Are sync failures repeating? | Increase of `argocd_app_sync_total` for `phase=Error|Failed` | Supported when Argo CD metrics are scraped |
| Provisioning | Which DataStore resources are not Ready or Synced? | Kubernetes managed-resource conditions | Requires state-metric instrumentation; not implemented |
| Provisioning | How long do provider resources take to become ready initially? | Crossplane provider readiness histograms | Conceptual until scrape configuration and Muztagh-scoped aggregation are defined |
| Tenant claims | Which Workspace, Application, and DataStore claims are Ready or not Ready? | Kubernetes claim conditions | Requires additional state-metric instrumentation; not implemented |
| Tenant claims | Which deletions or finalizers require attention? | Deletion timestamps, conditions, and events | Requires additional state-metric instrumentation; not implemented |
| Operations | Which requests required manual platform intervention, and for how long? | Operational event or ticket data | Future instrumentation; no metric exists here |

Each panel should link to the relevant Argo CD Application, Kubernetes claim, or
runbook. Component CPU and memory may support diagnosis, but they are secondary
to the contract-convergence panels above.

No production thresholds, error budgets, or availability targets are defined in
MDP-8.
