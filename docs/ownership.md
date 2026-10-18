# Ownership model

Ownership is assigned by responsibility rather than by repository write access.
Platform teams publish and maintain shared interfaces; domain teams choose and
operate their workloads within those interfaces.

| Area | Platform team | Domain team |
| --- | --- | --- |
| Foundation contracts | Defines versions, compatibility, and deprecation | Reviews usability; adopts released versions |
| GitOps boundary | Defines supported declaration interfaces and reconciliation ownership | Supplies domain declarations through supported interfaces |
| Platform APIs | Defines interface, lifecycle, and support boundary | Consumes APIs; owns domain-level integration behavior |
| Policy | Defines platform guardrails and exceptions process | Meets policies and provides required context for exceptions |
| Applications | Provides shared delivery constraints and interfaces | Owns code, configuration, runtime behavior, and data semantics |
| Operations | Operates shared platform components once introduced | Operates domain services and responds to domain alerts and incidents |

The matrix does not grant a team unilateral control over another team's assets.
An interface change follows the Git and PR workflow, with affected owners
included in review.
