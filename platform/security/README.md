# Platform security

This directory contains platform-owned guardrails. Kyverno policy intent is
defined under [kyverno/](kyverno/). Cilium tenant policy is composed by the
Crossplane Workspace API rather than reconciled directly from this directory.

Cilium and Kyverno controllers and CRDs are environment prerequisites; this
repository does not install them.
