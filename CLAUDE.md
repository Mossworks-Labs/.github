# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is the Mossworks Labs **org-level community-health repo** (`Mossworks-Labs/.github`). GitHub automatically inherits the files here into every public repo in the org that doesn't define its own override.

## What lives here

- `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md` — the four community-health markdown files inherited by every org repo without a local copy.
- `profile/README.md` — rendered as the public landing page at <https://github.com/Mossworks-Labs>.
- `.github/ISSUE_TEMPLATE/` (`bug_report.yml`, `feature_request.yml`, `config.yml`) and `.github/PULL_REQUEST_TEMPLATE.md` — default issue and PR forms.
- `.github/CODEOWNERS` — defaults review to `@Mossworks-Labs/dev` for this repo only; org repos with code define their own.
- `workflow-templates/` — starter workflows surfaced in any org repo under **Actions → New workflow → Mossworks Labs**. The `*.properties.json` sidecar files supply the picker metadata.
- `.github/workflows/pr.yml` — trampoline that calls the org's reusable PR-validation workflow against this repo's own PRs. `.github/pr_validation.yml` disables the npm-based checks since there's no code here.

## What's NOT here

Reusable GitHub Actions workflows (`pr.yml`, `docker-build.yml`, `helm-deploy.yml`, `codeql.yml`, etc.), governance JSON (rulesets, repo-settings), and admin scripts live in the sibling `Mossworks-Labs/actions` repo. Edits to CI behavior across the org belong there, not here.

## Editing notes

- Changes to the community-health files propagate to every public repo automatically — there's no per-repo sync. Treat edits as org-wide policy changes.
- A repo can override any file here by committing its own copy at the same path.
- Workflow templates are *starter* files copied into a repo when chosen from the UI; editing one here does not retro-update repos that already adopted it.
