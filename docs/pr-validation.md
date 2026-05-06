# Universal PR Validation

A reusable workflow that runs the org's standard PR validation across every Mossworks Labs repo. Each repo adds a small trampoline workflow that calls it; toggles and per-check options live in a single `.github/pr_validation.yml` per repo.

The org-level ruleset enforces a single status check (`PR / aggregate`), so toggling individual checks via per-repo config never breaks branch protection.

## Quick start

In each repo:

1. Add a trampoline workflow at `.github/workflows/pr.yml`:

   ```yaml
   name: PR

   on:
     pull_request:
       branches: [main]

   permissions:
     contents: read
     packages: read

   jobs:
     validation:
       uses: Mossworks-Labs/.github/.github/workflows/pr.yml@main
       permissions:
         contents: read
         packages: read
       secrets:
         NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
         build-secrets: |
           NODE_AUTH_TOKEN=${{ secrets.GITHUB_TOKEN }}
   ```

2. (Optional) Add `.github/pr_validation.yml` only when the defaults don't fit. Default behavior with no config file is: `lint` + `typecheck` + `format-check` + `build` + `test`. See [Schema](#schema) for what's configurable.

3. Remove the `pull_request:` trigger from any existing `ci.yml` so it only handles post-merge tasks (image publish, release-please, etc.).

That's it — the universal workflow takes over PR validation.

## Schema

`.github/pr_validation.yml` (or `.yaml`). All keys optional. Editor validation: point your YAML language server at `https://raw.githubusercontent.com/Mossworks-Labs/.github/main/.github/pr_validation.schema.json`.

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/Mossworks-Labs/.github/main/.github/pr_validation.schema.json

# Toggle individual checks. Standard Node/TS checks default to true;
# optional checks default to false.
checks:
  lint: true
  typecheck: true
  format-check: true
  build: true
  test: true
  docker: false
  helm-lint: false
  pulumi-preview: false
  storybook: false

# Override npm script names. Defaults match the keys above
# (e.g. `lint`, `typecheck`, `format:check`, `build`, `test`).
scripts:
  lint: lint
  typecheck: typecheck
  format-check: format:check
  build: build
  test: test

# Docker build matrix. Each image becomes one `PR / Docker (<name>)`
# job that runs `docker build --push=false`. Public build-args go here;
# sensitive values come from the trampoline's `build-secrets`.
docker:
  images:
    - name: site
      context: .
      dockerfile: Dockerfile
      target: ""
      build-args: |
        VITE_API_BASE_URL=https://api.mossworks.io

# Helm chart-testing options.
helm:
  charts-dir: charts

# Pulumi preview. Requires PULUMI_ACCESS_TOKEN secret on the trampoline.
pulumi:
  project-dir: .
  stack: dev.preview
```

## What each check does

| Check | What runs | When to enable |
|---|---|---|
| `lint` | `npm ci` + `npm run lint --if-present` | Default on. Most repos use eslint or oxlint. |
| `typecheck` | `npm ci` + `npm run typecheck --if-present` | Default on. Catches TS errors before merge. |
| `format-check` | `npm ci` + `npm run format:check --if-present` | Default on. Repos without a `format:check` script no-op. |
| `build` | `npm ci` + `npm run build --if-present` | Default on. Verifies the build artifact compiles. |
| `test` | `npm ci` + `npm run test --if-present` | Default on. Repos without tests no-op. |
| `docker` | `docker build --push=false` per image in the matrix | Off by default. Turn on for repos that ship images. |
| `helm-lint` | `ct list-changed` → `ct lint` → `helm template` per changed chart | Off by default. Used by `helm-charts`. |
| `pulumi-preview` | `pulumi preview` against the configured stack | Off by default. Used by `platform-deploy`. |
| `storybook` | `npm run build-storybook --if-present` | Off by default. Used by `design-system`. |

The final job, `PR / aggregate`, depends on all the above and reports `success` only when every enabled check passes (skipped checks are ignored). This is the **single status check** the org ruleset requires.

## Trampoline secrets

Pass through whatever your repo needs:

```yaml
secrets:
  # Required when npm ci needs to fetch private @mossworks-labs packages.
  NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # BuildKit secrets for the docker check (multi-line KEY=VALUE).
  build-secrets: |
    NODE_AUTH_TOKEN=${{ secrets.GITHUB_TOKEN }}

  # Pulumi cloud token for the pulumi-preview check.
  PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
```

Anything not needed can be omitted.

## Per-repo examples

### A standard Node/TS repo (no config file needed)

The default behavior — `lint` + `typecheck` + `format-check` + `build` + `test` — covers most of the org. Just add the trampoline. No config file required.

### A repo that ships a Docker image

```yaml
# .github/pr_validation.yml
checks:
  docker: true
docker:
  images:
    - name: site
      build-args: |
        VITE_API_BASE_URL=https://api.mossworks.io
```

The trampoline forwards `NODE_AUTH_TOKEN` via `build-secrets` so private packages install during the build.

### `helm-charts`

```yaml
checks:
  lint: false
  typecheck: false
  format-check: false
  build: false
  test: false
  helm-lint: true
helm:
  charts-dir: charts
```

### `platform-deploy`

```yaml
checks:
  test: false
  pulumi-preview: true
pulumi:
  project-dir: .
  stack: org/platform-deploy/dev.preview
```

The trampoline must pass `PULUMI_ACCESS_TOKEN`.

## Org ruleset (one-time setup)

Two enforcement options — pick **one** to avoid duplicate runs:

### Option 1: Require the status check (recommended)

Each repo must have a trampoline; the trampoline produces the `PR / aggregate` check. The ruleset requires that check to pass before merge.

1. **GitHub UI** → Org settings → **Repository rulesets** → New ruleset → Branch ruleset.
2. **Target**: All repositories under `Mossworks-Labs` (with optional excludes for archived / sandbox repos).
3. **Branch targeting**: `~DEFAULT_BRANCH`.
4. **Rules**:
   - Restrict deletions
   - Require pull request before merging (1 approval)
   - **Require status checks to pass** → add `PR / aggregate`

A repo without a trampoline never reports `PR / aggregate`, so its PRs cannot merge — this forces every repo to opt in.

### Option 2: Required workflow injection (backstop)

The ruleset injects `pr.yml` automatically on every PR, no trampoline needed.

1. Same UI as above, but under **Rules** add:
   - **Require workflows to pass** → workflow file path `.github/workflows/pr.yml`, ref `main`, source repo `Mossworks-Labs/.github`

The workflow runs on `pull_request` directly with default inputs and the repo's own `secrets.GITHUB_TOKEN`. Repos that need extra secrets (`build-secrets` for docker, `PULUMI_ACCESS_TOKEN` for pulumi-preview) cannot use this mode and must use Option 1's trampoline approach.

> ⚠️ **Don't use both.** If a repo has a trampoline AND the ruleset injects the workflow, the same workflow runs twice on every PR. Pick one strategy per repo (or per ruleset target).

### `gh api` example

```bash
gh api -X POST /orgs/Mossworks-Labs/rulesets \
  -f name="PR Validation" \
  -f target=branch \
  -f enforcement=active \
  -f conditions[ref_name][include][]='~DEFAULT_BRANCH' \
  -f conditions[repository_name][include][]='~ALL' \
  ...
```

The detailed payload is documented at https://docs.github.com/en/rest/repos/rules.

## Troubleshooting

**"npm ci fails with 401 Unauthorized"** — the trampoline isn't passing `NODE_AUTH_TOKEN`. Add `secrets.NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` to the trampoline.

**"Docker build fails on `--mount=type=secret,id=NODE_AUTH_TOKEN`"** — the trampoline isn't passing `build-secrets`. Add the multi-line `build-secrets` block.

**"PR / Helm Lint reports `chart-testing-action` not installed"** — the helm-lint check needs `chart-testing-action` and `azure/setup-helm@v4`; both are pinned in `pr.yml`. If the runner is self-hosted and lacks Helm in PATH, the workflow installs Helm automatically. No further setup needed.

**"PR / aggregate failed but every other check passed"** — likely the `parse-config` job failed due to a malformed `.github/pr_validation.yml`. Validate against the schema; common issue is a non-string value where the schema expects a string (e.g. `target: 0` instead of `target: ""`).
