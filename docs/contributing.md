# Git and pull request workflow

`main` is the integration branch and is treated as protected. Feature work must
not be committed directly to `main`.

## Branches

Create one focused branch per change. Use a descriptive prefix and the Jira key
when available, for example `feature/mdp-2-platform-foundation`.

## Pull requests

Open a pull request from the feature branch to `main`. Keep it scoped to one
story or a tightly coupled correction. Describe the affected ownership boundary,
contract impact, and validation performed.

The author addresses review feedback. Changes affecting shared contracts require
platform-team review and review from impacted domain teams when their use is
changed. Merge approved work with squash merge so `main` has one commit per
reviewed change.

Branch protection and automated checks are repository settings or later
implementation work; this document defines the working convention, not evidence
that those controls are configured.
