# CPEmon consumer declarations

This directory is a reference Golden Path consumer, not a migration of the
historical CPEmon production platform.

| Declaration | CPEmon input | Platform-owned result |
| --- | --- | --- |
| `Workspace/cpemon-dev` | Owner, environment, cost centre, developer group | Namespace, quota, tenant RoleBinding, and Cilium policy |
| `Application/cpemon-api` | Illustrative image and tag, replicas, port | Deployment, ClusterIP Service, resource and security defaults |
| `DataStore/cpemon-backup` | Region and deletion policy | S3 implementation, encryption, public-access block, provider reference, and tags |

The identity group, cost centre, image registry, and version are illustrative;
they do not represent Nuuday production configuration. The domain team owns the
declared application and data intent, business logic, configuration, and domain
incidents. Muztagh owns the shared platform implementation and guardrails.

No Namespace, ResourceQuota, RoleBinding, CiliumNetworkPolicy, Deployment,
Service, or AWS provider resource is declared here. Kafka and ClickHouse remain
missing platform capabilities; the shared APIs are not extended with
CPEmon-specific fields or switches.
