# Request and reconciliation flow

This document describes responsibilities, not a deployed implementation.

1. A developer changes a domain declaration in `user-space/` or a
   platform-owned asset in `platform/`.
2. The change is proposed through a feature branch and pull request.
3. Validation checks the change against the applicable contracts and policies.
4. After review and merge, a delivery component may use the repository's
   desired state to request or update managed resources.
5. A reconciliation component compares desired state with observed state and
   records or exposes divergence for the responsible owner to address.

Responsibility remains explicit at each handoff: the author owns the intent;
reviewers own approval within their area; the platform team owns shared
interfaces and components; and a domain team owns the domain outcome.

The future implementation may use CI, Argo CD, Crossplane, and policy tooling
for these stages. Their configuration, ordering, credentials, and failure
handling are outside this story.
