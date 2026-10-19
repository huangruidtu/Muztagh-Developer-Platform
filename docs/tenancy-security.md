# Tenancy and guardrails

## Workspace boundary

`Workspace.spec.developerGroup` is the external identity or Kubernetes group
authorized to use namespaced platform APIs. It is separate from `owner`, which
is operational metadata rather than an identity principal.

Each Workspace composes:

| Resource | Platform-owned purpose |
| --- | --- |
| Namespace | Tenant boundary and ownership, environment, cost-centre, platform labels |
| ResourceQuota | Reference safety limits: 20 Pods, 10 Services, 5 PVCs, 4 requested CPU, 8 CPU limits, 8 GiB requested memory, 16 GiB memory limits, and 100 GiB requested storage |
| RoleBinding | Binds only `developerGroup` to `ClusterRole/muztagh-domain-developer` in the Workspace Namespace |
| CiliumNetworkPolicy | Selects all tenant endpoints and establishes ingress and egress allowlists |

The quota values are reference-platform defaults, not production capacity
planning. Changing them remains a platform decision; developers cannot supply
raw quota, RBAC, Namespace, or network-policy configuration.

The authorization path is:

```text
developerGroup
  -> Workspace RoleBinding
  -> muztagh-domain-developer ClusterRole
  -> namespaced Application and DataStore APIs
```

The ClusterRole does not grant direct Deployment, Service, Namespace, RBAC,
Cilium, Kyverno, or cluster-wide administration permissions.

Crossplane may create tenant RoleBindings and may bind only
`ClusterRole/muztagh-domain-developer`. This explicit `bind` permission
satisfies Kubernetes RBAC privilege-escalation protection without allowing
arbitrary ClusterRole binding.

## Network model

The namespaced Cilium policy selects every workload endpoint. Policy selection
enables default deny in both directions, then allows:

- ingress from endpoints in the same Workspace Namespace;
- ingress from the local host entity for node-originated health behavior;
- egress to endpoints in the same Workspace Namespace; and
- DNS queries to `kube-system` endpoints labelled `k8s-app=kube-dns` on port 53.

Cross-namespace traffic and unrestricted internet egress are not allowed by the
baseline. External or cross-workspace connectivity requires a later,
platform-approved capability. Clusters whose DNS implementation uses different
labels must adapt the platform policy before onboarding tenants. Cilium's
`host` entity also includes local host-networked processes; it is allowed only
for node-originated health behavior and should be reviewed if cluster probe
plumbing differs.

Workspace composition readiness waits for the Namespace to be Active and for
the Cilium policy `Valid=True` condition. That condition is not a connectivity
or isolation test.

## Workload and admission controls

The Application Composition fixes Pod and container security settings:

- non-root execution;
- RuntimeDefault seccomp;
- privilege escalation disabled;
- all Linux capabilities dropped; and
- reference CPU and memory requests and limits compatible with the quota.

These fields are absent from the developer contract and cannot be overridden
through `Application`. Images must work with the security context; no runtime
compatibility claim is made.

Kyverno applies only to Namespaces carrying the Muztagh platform labels. It
requires platform/Application metadata on Pods and Services, applies the
restricted Pod Security profile, and rejects Service types other than
ClusterIP. Valid fixtures show the generated shape; invalid fixtures cover a
privileged Pod, LoadBalancer Service, and missing metadata.

## Ownership and prerequisites

The platform team owns Workspace lifecycle, Namespace metadata, quotas, RBAC,
network isolation, Application security defaults, and Kyverno policy. Domain
teams own images, supported Application/DataStore inputs, business behavior,
and data usage and classification. Normal developer inputs cannot modify the
tenant security boundary.

Cilium, Kyverno, and their CRDs must be installed by the target environment.
The repository owns policy intent only. Static rendering does not prove Cilium
traffic behavior, Kyverno admission, Crossplane reconciliation, or Kubernetes
authorization on a live cluster.

The Kyverno `ClusterPolicy` compatibility decision and future migration path
are recorded in [dependency-lifecycle.md](dependency-lifecycle.md).
