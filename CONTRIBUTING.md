# Contributing

Thanks for taking the time to contribute. This file is the org-wide default — individual repos may add their own `CONTRIBUTING.md` with project-specific guidance that overrides this.

## How to file an issue

- Bug report → use the **Bug report** template. Include reproduction steps and the version / commit you're on.
- Feature request → use the **Feature request** template. State the user-visible problem before the proposed solution.
- Security issue → **do not** open a public issue. See [`SECURITY.md`](SECURITY.md).

## Pull request flow

1. Fork or branch off `main`.
2. Match the existing code style. Most repos use `oxlint` / `oxfmt`; some use `eslint` / `prettier`. Run the repo's lint script before pushing.
3. Add or update tests for behavioural changes. Pure refactors with adequate coverage are fine without new tests.
4. Use [conventional commits](https://www.conventionalcommits.org/) for the commit message and PR title — `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `ci:`. Several repos use `release-please`, which keys off these prefixes for automated version bumps.
5. Keep the PR scoped — one logical change per PR. Drive-by fixes are fine if they're trivial; otherwise open a separate PR.
6. Fill out the **Test plan** section in the PR template with what you actually ran.

## Reviews

- A `CODEOWNERS` file routes the review to `@Mossworks-Labs/dev` by default.
- Most repos require a green CI run + one approval before merge.
- The author squashes / merges after approval. Don't force-push protected branches.

## Local development

Each repo's `README.md` covers prerequisites and the bootstrap commands. The platform projects (CRAFT, marketplace) generally need Docker, kubectl, and a local k3s cluster — see their respective `README.md` and `CLAUDE.md` files.

## Releasing

The Helm charts and several Node packages release via `release-please`. Don't manually bump `version:` fields or update `CHANGELOG.md` — the bot owns those. If a release PR is open and you need to ship something urgent, merge the release PR first, then layer your change.
