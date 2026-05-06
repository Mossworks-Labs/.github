# Rulesets as Code

Org-level GitHub repository rulesets are codified as JSON files in `.github/rulesets/`. A workflow at `.github/workflows/apply-rulesets.yml` validates them on every PR and applies them to `Mossworks-Labs` on push to `main`.

The org's "main" ruleset (which requires the universal `pr.yml` workflow on every PR — see [pr-validation.md](pr-validation.md)) is the first thing managed this way. It was imported as-is, so the first apply is a no-op.

## Layout

```
.github/
├── rulesets/
│   └── main.json              # one file per ruleset, matched by .name
├── scripts/
│   └── apply-rulesets.sh      # bash wrapper around `gh api`
└── workflows/
    └── apply-rulesets.yml     # validate on PR, apply on push to main
```

## File format

Each JSON file is the literal payload accepted by `POST /orgs/{org}/rulesets`. GitHub's UI and `gh api` both speak this shape. The most-used keys:

```jsonc
{
  "name": "PR Validation",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    },
    "repository_name": {
      "include": ["~ALL"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    {
      "type": "pull_request",
      "parameters": { "required_approving_review_count": 1, "dismiss_stale_reviews_on_push": false }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "do_not_enforce_on_create": true,
        "required_status_checks": [
          { "context": "PR / aggregate" }
        ]
      }
    }
  ],
  "bypass_actors": []
}
```

Full schema reference: <https://docs.github.com/en/rest/orgs/rules#create-an-organization-repository-ruleset>.

## Bootstrapping

One-time setup before the workflow can apply changes:

1. **Mint the PAT.** Create a fine-grained PAT (recommended) or classic PAT scoped to the `Mossworks-Labs` org with **Administration: Read and write** at the org level. Classic PATs need the `admin:org` scope.
2. **Save as repo secret.** In `Mossworks-Labs/.github` → Settings → Secrets and variables → Actions → New repository secret named `ORG_RULESET_TOKEN`.
3. **Import any rulesets that already exist on the org** (so the workflow doesn't try to recreate them):

   ```bash
   ORG=Mossworks-Labs
   gh api "/orgs/${ORG}/rulesets" \
     | jq -c '.[] | { name, id }'
   # For each ruleset id you want to manage as code:
   gh api "/orgs/${ORG}/rulesets/<id>" \
     | jq 'del(.id, .source_type, .source, .created_at, .updated_at, .node_id, ._links, .current_user_can_bypass)' \
     > .github/rulesets/<name>.json
   ```

   Open a PR with the JSON. The diff job will show "(no changes)" against live, confirming the codified copy matches reality.

## Workflow behavior

| Event | What happens |
|---|---|
| `pull_request` | Validates JSON shape (jq parse + required keys present). If `ORG_RULESET_TOKEN` is set, also runs `apply-rulesets.sh --dry-run` to diff each file against the live ruleset and posts the diff to the job log. |
| `push` to main | Runs `apply-rulesets.sh` for real — POSTs new rulesets, PUTs existing ones. |
| `workflow_dispatch` | Manual trigger with a `dry-run` input (default true). Useful for previewing the effect of an out-of-band edit on the org. |

The script matches files to live rulesets by `.name`. Renaming a file or its `name` field creates a new ruleset rather than updating the old one — the old one needs to be deleted manually.

## Drift detection

The `pull_request` job's diff catches drift only when a PR touches a JSON file. To detect drift between codified and live state without a PR, run:

```bash
.github/scripts/apply-rulesets.sh Mossworks-Labs .github/rulesets --dry-run
```

(Requires a local `gh auth login` with org admin scope.)

A scheduled drift-detection workflow is **not** included by default — add one if drift becomes a recurring problem. The simplest shape:

```yaml
on:
  schedule: [ { cron: '0 14 * * 1' } ]   # Mondays at 9am ET
```

…using the same `apply-rulesets.sh ... --dry-run` invocation, with a step that fails on non-empty diff output.

## Adding a new ruleset

1. Drop a JSON file into `.github/rulesets/`. Pick a unique `.name` field; the filename is for humans.
2. Open a PR. The diff job shows "would POST /orgs/Mossworks-Labs/rulesets" with the proposed body.
3. Merge. The apply job creates the ruleset on the org.

## Removing a ruleset

The script intentionally does NOT delete rulesets when their JSON file disappears — silent deletion of org-wide policy is too risky. To remove:

1. Delete via the GitHub UI (Settings → Repository rulesets) or via:
   ```bash
   gh api -X DELETE "/orgs/Mossworks-Labs/rulesets/<id>"
   ```
2. Then delete the JSON file in a follow-up PR.

## Troubleshooting

**"resource not accessible by integration"** — the PAT is missing `Administration: write` at the **org** level. Repo-level permissions don't apply to org rulesets.

**"422 Unprocessable Entity" with `Rules contain validation errors`** — usually a malformed `rules[].parameters` block. Validate against the GitHub REST docs above; common issue is putting required-status-check `context` strings inside the wrong parameter.

**"Workflow must have one of the following triggers configured"** — when adding a `required_workflows` rule, the referenced workflow file must trigger on `pull_request`, `pull_request_target`, or `merge_queue` (not just `workflow_call`). Our `pr.yml` ships with `pull_request` for exactly this reason.
