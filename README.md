# VibeSmiths Shared CI/CD

Reusable GitHub Actions workflows and composite actions for VibeSmiths projects.

## Reusable Workflows

### `docker-build.yml`
Build and push Docker images to GHCR.

```yaml
jobs:
  docker:
    uses: VibeSmiths/.github/.github/workflows/docker-build.yml@main
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
    uses: VibeSmiths/.github/.github/workflows/node-lint-test.yml@main
    with:
      node-version: "22"
```

### `helm-deploy.yml`
Deploy to k3s via Helm (runs on self-hosted runner, gated by `production` environment).

```yaml
jobs:
  deploy:
    uses: VibeSmiths/.github/.github/workflows/helm-deploy.yml@main
    with:
      release-name: craft
      chart-path: ./helm/craft
      images: "studio frontend"
```
