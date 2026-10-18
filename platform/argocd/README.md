# Argo CD GitOps structure

`bootstrap/` defines the Muztagh AppProject and root platform Application.
`applications/` defines the child Application hierarchy. `workloads/` contains
placeholder Kustomize roots for later platform implementation.

The manifests assume Argo CD is already installed in the `argocd` namespace.
This repository does not install Argo CD or apply the bootstrap resources.

Bootstrap is intentionally explicit: after review, an operator applies the
AppProject first and the root Application second. From the repository root:

```text
kubectl apply -f platform/argocd/bootstrap/project.yaml
kubectl apply -f platform/argocd/bootstrap/root-application.yaml
```

See [docs/gitops.md](../../docs/gitops.md) for reconciliation and failure
semantics. Run `platform/argocd/scripts/validate.ps1` for static rendering.
