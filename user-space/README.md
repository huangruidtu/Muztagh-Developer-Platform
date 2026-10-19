# User space

This directory is reserved for domain-team declarations that consume published
platform contracts. A domain team owns its workloads and the inputs it supplies
to those contracts; it does not modify platform-managed implementation assets.

The [gitops/](gitops/) directory is reconciled by the Muztagh user-space Argo CD
Application. CPEmon is the first reference consumer of the published Workspace,
Application, and DataStore contracts.
