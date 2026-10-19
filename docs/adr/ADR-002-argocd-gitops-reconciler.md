# ADR-002: Argo CD is the GitOps reconciler

## Status

Accepted.

## Context

Platform components and domain claims need an auditable desired-state path from
this repository to Kubernetes. Reconciliation should detect drift without
silently deleting resources during the reference phase.

## Decision

Argo CD reconciles approved state from `main`. The root Application manages
controller packages, capabilities, guardrails, and user-space child
Applications. Automated sync and self-heal are enabled; prune is disabled; sync
retry is limited to three attempts with bounded backoff.

Sync waves order creation and update of child `Application` resources. The
children reconcile independently, and Argo CD does not provide built-in
`Application` CR health assessment by default. Waves therefore are not a hard
runtime-readiness barrier. Strict gating would require an explicit health
customization or a different dependency strategy.

## Alternatives considered

Flux provides a valid GitOps model, but Argo CD was selected for this
implementation. Manual `kubectl apply` would not provide the same continuous
drift reconciliation or application hierarchy.

## Consequences and trade-offs

- Git history and pull requests are the audit path for desired state.
- Self-heal corrects detected drift; disabled prune avoids automatic deletion
  but leaves removals as an explicit operating action.
- Dependencies must expose and check their own readiness; wave numbers alone
  cannot prove it.
- The manifests describe the model, but no live Argo CD reconciliation has run.
