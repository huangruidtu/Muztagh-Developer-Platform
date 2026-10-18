# Platform

This directory is the implementation space for the platform control plane and
developer-facing platform capabilities. The Argo CD GitOps structure is defined
under [argocd/](argocd/); it does not install or run Argo CD.

Crossplane, networking, policy, and observability assets remain later work.
Domain workloads and product-specific settings do not belong in this directory.
