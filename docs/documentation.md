# Documentation conventions

The root README is an entry point: purpose, repository layout, and links to
deeper material only. Architecture, ownership, workflows, contracts, and
operational detail belong in `docs/`.

Documentation must state the current design or implementation status precisely.
Use declarative language for intended behavior and present tense only for
capabilities that exist in the repository or are otherwise evidenced. Avoid
marketing claims, generic AI-generated prose, repetitive summaries, and
unsupported production claims.

Prefer short documents with a defined audience, explicit decisions, and links
to the source files or issues that define implementation work. Update the
relevant document in the same pull request when a repository boundary,
contract, workflow, or ownership decision changes.

Use [the ADR index](adr/README.md) for decisions with durable architectural
consequences. Use [the truth boundary](truth-boundary.md) to distinguish source
artifacts, static execution evidence, and behavior that requires a live system.
