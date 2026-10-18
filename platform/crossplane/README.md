# Crossplane platform APIs

This directory defines the MDP-5 developer contract. It requires Crossplane v2
to be installed separately and does not represent a live cluster deployment.

## Contracts

| API | Scope | Developer inputs | Composed resources |
| --- | --- | --- | --- |
| `Workspace` | Cluster | `owner`, `environment`, `costCenter` | Namespace with platform ownership labels |
| `Application` | Namespaced | `image`, `tag`, `replicas`, `port` | Deployment and ClusterIP Service |
| `DataStore` | Namespaced | `region`, `deletionPolicy` | S3 bucket, public-access block, and SSE-S3 encryption configuration |

The XRD schemas under `definitions/` are the public interface. The Pipeline
Compositions under `compositions/` own resource names, labels, selectors,
container wiring, provider references, encryption, public-access controls, and
platform tags. `function-patch-and-transform` implements each pipeline.

`deletionPolicy: Delete` permits Crossplane to delete the three S3 resources.
`Orphan` removes the Delete management policy while retaining observe, create,
update, and late-initialize behavior. This choice is exposed because it changes
the external resource lifecycle; provider configuration and credentials are not.

## Prerequisites and GitOps layers

Crossplane core must exist before the `platform/crossplane/packages` root is
reconciled. That root installs the pinned patch-and-transform Function and AWS
S3 Provider packages. The capabilities root at `platform/crossplane` then
reconciles XRDs, Compositions, and RBAC. Argo CD sync waves order the child
Application objects but do not prove that packages are healthy before the
capabilities Application reconciles; strict readiness gating remains a separate
control-plane concern.

The S3 Composition expects an `aws.m.upbound.io/v1beta1` cluster provider
configuration named `default`. Credentials and that `ClusterProviderConfig` are
environment-specific prerequisites and are intentionally absent from Git.

## Access model

`muztagh-domain-developer` grants CRUD access to namespaced `Application` and
`DataStore` resources and read access to their status subresources. It grants no
access to cluster-scoped `Workspace` resources. No binding is included because
identity-to-team membership is environment-specific.

`muztagh:aggregate-to-crossplane` grants the Crossplane service account the
Namespace, Deployment, and Service permissions required by the Compositions.
It relies on the RBAC manager included with a standard Crossplane installation;
an installation that disables that component must bind equivalent permissions.

Examples under `examples/` illustrate the API only and are not included in an
Argo CD managed root.

## Ownership and trace

Terraform owns the shared AWS network, EKS foundation, and baseline platform
identity. Crossplane owns only resources created from these developer APIs. An
S3 bucket created for a `DataStore` must never also appear in Terraform state.

An `Application` follows this path:

```text
Application manifest
  -> applications.platform.muztagh.io XRD validation/defaults
  -> application.platform.muztagh.io Composition
  -> function-patch-and-transform
  -> Deployment + Service in the Application namespace
  -> readiness reported on the Application
```

## Static validation

Run `platform/crossplane/scripts/validate.ps1`. It renders the package,
capability, example, Argo CD, and user-space Kustomize roots and runs
`git diff --check`. A Crossplane CLI render should also be used when the CLI and
provider/function runtime images are available. Static rendering does not
validate credentials, provider connectivity, AWS behavior, or live readiness.
