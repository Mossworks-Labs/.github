# Mossworks Labs Shared CI/CD

Reusable GitHub Actions workflows and composite actions for Mossworks Labs projects.

## Reusable Workflows

### `pr.yml` — Universal PR Validation
The org's standard PR-validation workflow. Each repo invokes it via a thin
trampoline at `.github/workflows/pr.yml`; per-repo toggles + options live in
`.github/pr_validation.yml`. Defaults cover lint + typecheck + format-check +
build + test for any Node/TS repo with no config file. Optional checks
(docker, helm-lint, pulumi-preview, storybook) opt in via the config.

```yaml
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

Full schema + examples: [docs/pr-validation.md](docs/pr-validation.md).

### `docker-build.yml`
Build and push Docker images to GHCR.

```yaml
jobs:
  docker:
    uses: Mossworks-Labs/.github/.github/workflows/docker-build.yml@main
    with:
      image-name: my-service
      context: .
      dockerfile: Dockerfile
```

### `node-lint-test.yml`
TypeScript lint + test for Node.js projects.

```yaml
jobs:
  lint-test:
    uses: Mossworks-Labs/.github/.github/workflows/node-lint-test.yml@main
    with:
      node-version: "22"
```

### `helm-deploy.yml`
Deploy to k3s via Helm (runs on self-hosted runner, gated by `production` environment).

```yaml
jobs:
  deploy:
    uses: Mossworks-Labs/.github/.github/workflows/helm-deploy.yml@main
    with:
      release-name: craft
      chart-path: ./helm/craft
      images: "studio frontend"
```

### `codeql.yml`
CodeQL static analysis (free for public repos).

```yaml
jobs:
  codeql:
    uses: Mossworks-Labs/.github/.github/workflows/codeql.yml@main
    with:
      languages: javascript
```

### `dependency-review.yml`
Dependency review on PRs — flags high-severity vulnerabilities in new dependencies.

```yaml
jobs:
  dependency-review:
    if: github.event_name == 'pull_request'
    uses: Mossworks-Labs/.github/.github/workflows/dependency-review.yml@main
```

## Org Workflow Templates

The `workflow-templates/security.yml` template is available to all Mossworks Labs repos via **Actions > New workflow > Mossworks Labs Security**.

## Rulesets as Code

Org-level repository rulesets live as JSON in `.github/rulesets/`. A workflow at
`.github/workflows/apply-rulesets.yml` validates them on every PR and applies
them to `Mossworks-Labs` on push to main.

See [docs/rulesets.md](docs/rulesets.md) for the schema, bootstrap, and the
required `ORG_RULESET_TOKEN` secret.

## Repo Settings as Code

Org-wide base repo settings (merge methods, default features, branch hygiene)
live in `.github/repo-settings.json`. A workflow at
`.github/workflows/apply-repo-settings.yml` PATCHes every active repo on push
to main. Reuses the same `ORG_RULESET_TOKEN` secret (which needs both
org-level and repo-level Administration: write).

See [docs/repo-settings.md](docs/repo-settings.md) for the schema + the
canonical settings table.
