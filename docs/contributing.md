# Git and pull request workflow

`main` is the integration branch. Use one focused feature branch per change;
include the Jira key when available, for example
`feature/mdp-10-documentation-evidence`.

## Pull requests

Open a pull request to `main` and describe the ownership or contract impact.
The expected path is:

```text
feature branch -> pull request -> CI required-check -> review -> squash merge
```

The workflow runs Terraform, manifest, policy, and security jobs and aggregates
their results in `required-check`. Run the relevant validation locally before
pushing; the exact commands and limitations are in
[CI validation](ci-validation.md).

Platform-team review is needed for shared APIs, Compositions, guardrails,
foundation resources, and operating contracts. Include affected domain teams
when a change alters their supported inputs or behavior.

Squash merge is the repository convention. The workflow is implemented, but
branch protection is a GitHub repository setting and is not asserted by this
repository.
