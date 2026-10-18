# Request and reconciliation flow

This document describes responsibilities. The repository contains declarative
configuration but no evidence of a live deployment.

1. A developer changes a domain declaration in `user-space/` or a
   platform-owned asset in `platform/`.
2. The change is proposed through a feature branch and pull request.
3. Validation checks the change against the applicable contracts and policies.
4. After review and merge, Argo CD can reconcile the repository's desired state.
5. Crossplane can translate platform API claims into composed resources and
   report divergence or failed reconciliation for the responsible owner.

Responsibility remains explicit at each handoff: the author owns the intent;
reviewers own approval within their area; the platform team owns shared
interfaces and components; and a domain team owns the domain outcome.

CI and policy tooling remain future work. Runtime configuration, credentials,
and live failure handling are environment responsibilities outside this story.
