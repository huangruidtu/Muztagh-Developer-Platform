# Concept-to-implementation map

This map links the eight public engineering topics to concrete Muztagh evidence.
It does not reproduce private learning or employer material.

| Module | Concept | Concrete Muztagh evidence | Key design lesson | Limitation |
| --- | --- | --- | --- | --- |
| S7.1 Product and architecture | Platform boundaries and ownership | [`architecture.md`](architecture.md), [`ownership.md`](ownership.md), top-level repository layout | A platform starts with explicit products, consumers, and ownership, not a tool list | Reference architecture; no organizational adoption evidence |
| S7.2 Bootstrap and GitOps control plane | Desired-state reconciliation | `platform/argocd/`, [`gitops.md`](gitops.md) | Sync waves order Application objects but do not replace readiness checks | Argo CD is not installed or exercised live |
| S7.3 Platform API and Crossplane internals | Contract versus implementation | `platform/crossplane/definitions/`, `platform/crossplane/compositions/` | XRDs constrain requests; Compositions retain provider and resource details | Custom-resource schemas are not fully validated offline; no live reconciliation |
| S7.4 Developer contract and golden paths | Reusable self-service capabilities | `Workspace`, `Application`, `DataStore`, `user-space/gitops/cpemon/`, [`developer-golden-path.md`](developer-golden-path.md) | A golden path should expose supported intent and leave missing capabilities explicit | Only one reference consumer and three capabilities |
| S7.5 Security, identity, networking, and guardrails | Tenant boundary and layered controls | Workspace RBAC and Cilium intent, `platform/security/kyverno/`, [`tenancy-security.md`](tenancy-security.md) | Authorization, network intent, workload defaults, and admission policy address different boundaries | No live Cilium or Kyverno enforcement; Kyverno policy API has a pinned compatibility target |
| S7.6 Developer experience | Controlled Git/YAML self-service | PR workflow, user-space AppProject, explicit `cpemon-dev` allowlist | Approve the tenant boundary once, then permit self-service inside it | No portal, CLI, or dynamic tenant registration |
| S7.7 Observability and day-2 | Health model, alerts, and recovery | `platform/observability/`, `docs/operations/`, `docs/runbooks/` | Alerts need an owner and a diagnostic path; desired state alone is not operability | No monitoring stack, live metrics, alert firing, or production SLO data |
| S7.8 Synthesis and consumer redesign | Test shared abstractions against a consumer | CPEmon declarations, [`ADR-005`](adr/ADR-005-cpemon-first-consumer.md), [`interview-walkthrough.md`](interview-walkthrough.md), [`truth-boundary.md`](truth-boundary.md) | A first consumer should test a generic platform, not turn it into a domain-specific API | CPEmon dependencies outside the shared contracts remain unsupported |
