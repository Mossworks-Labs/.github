# Repository Settings as Code

Org-wide base repository settings live as JSON in `.github/repo-settings.json` and are applied to every Mossworks-Labs repo on push to main. Same pattern as [rulesets-as-code](rulesets.md): JSON file → apply workflow → idempotent PATCH per repo.

## What's standardized

The current settings (see `.github/repo-settings.json` for the live values):

| Setting | Value | Why |
|---|---|---|
| `has_issues` | `true` | Issues are the org's primary tracking surface |
| `has_projects` | `false` | Project boards live at the org level when used |
| `has_wiki` | `false` | Docs live in `docs/` or in the repo README |
| `has_discussions` | `false` | Conversations happen on Slack/PRs |
| `is_template` | `false` | No template repos in this org yet |
| `allow_merge_commit` | `false` | Linear history; rebase only |
| `allow_squash_merge` | `false` | Linear history; rebase only |
| `allow_rebase_merge` | `true` | The only allowed merge method |
| `allow_auto_merge` | `true` | Lets PRs merge as soon as required checks pass |
| `allow_update_branch` | `true` | Surfaces "Update branch" in the PR UI |
| `delete_branch_on_merge` | `true` | Keeps the branch list clean |
| `web_commit_signoff_required` | `false` | DCO sign-off not enforced via the web UI |

## Layout

```
.github/
├── repo-settings.json        # the canonical settings + exclude list
├── scripts/
│   └── apply-repo-settings.sh
└── workflows/
    └── apply-repo-settings.yml
```

## Schema

```jsonc
{
  "settings": {
    // Any key the GitHub API's PATCH /repos/{owner}/{repo} endpoint
    // accepts. Common ones listed above; full reference at
    // https://docs.github.com/en/rest/repos/repos#update-a-repository
  },
  "exclude_repos": ["repo-a", "repo-b"],   // skip these repos entirely
  "exclude_archived": true                  // skip archived repos
}
```

## Bootstrapping

Same setup as the ruleset workflow — both reuse `ORG_RULESET_TOKEN`. The token's PAT scope needs to cover **both**:

| Operation | Required scope |
|---|---|
| Apply rulesets (rulesets-as-code) | Org-level **Administration: Read and write** |
| Apply repo settings (this workflow) | Repo-level **Administration: Read and write**, on **all repositories** |

For a fine-grained PAT: under "Repository access" pick "All repositories", and under "Permissions" select **Administration: Read and write**. Under "Organization permissions" also keep **Administration: Read and write** for the rulesets workflow.

## Workflow behavior

| Event | Behavior |
|---|---|
| `pull_request` | Validates JSON shape + dry-runs (lists repos that would be patched). |
| `push` to main | Runs the apply script for real — PATCHes every non-excluded, non-archived repo with the `settings` block. Idempotent. |
| `workflow_dispatch` | Manual trigger with a `dry-run` input (default `true`). Useful for previewing the effect of an out-of-band edit. |

The apply script is idempotent. Running on already-matching state is a no-op (the API silently accepts a PATCH where no fields change).

## Per-repo overrides

The system intentionally has no per-repo override mechanism — these are *base* settings. If a single repo legitimately needs a different setting:

1. Add the repo name to `exclude_repos` in `repo-settings.json`.
2. Manage that repo's settings out-of-band (UI / direct API call / a different workflow).

If multiple repos need the same override, add a setting to the JSON and re-discuss whether the override should be the new org-wide default.

## Drift detection

The PR-time dry-run shows which repos would be patched on a JSON change. To detect drift between codified and live state without a PR, run:

```bash
.github/scripts/apply-repo-settings.sh Mossworks-Labs .github/repo-settings.json --dry-run
```

(Requires a local `gh auth login` with org admin scope.)

A scheduled drift-detection workflow is **not** included by default — the periodic apply on every settings change is the primary feedback loop. Add a weekly cron if drift becomes a recurring problem.

## Troubleshooting

**"resource not accessible by integration"** — the PAT is missing **Administration: write** at the repo level. Org-level admin alone isn't enough for `PATCH /repos/{owner}/{repo}`.

**A specific repo is failing apply but others succeed** — likely the PAT was created with "Selected repositories" rather than "All repositories", and the failing one isn't in the selection. Edit the PAT and re-pick.

**A field in `settings` doesn't seem to take effect** — the API silently ignores unknown fields. The validate job warns on keys not in the documented set, but the source of truth is the GitHub REST docs linked in the schema section above.
