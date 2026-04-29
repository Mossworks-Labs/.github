# Mossworks Labs

**Tools and infrastructure for AI-assisted content production.** A self-hosted YouTube studio, a creator-services marketplace, and a set of open-source MCP servers that bring research, writing craft, and media tooling into Claude.

---

### Open source

MCP (Model Context Protocol) servers — drop-in skill packs for Claude Code, Claude Desktop, or any MCP-aware client.

| Server | What it does |
|--------|--------------|
| [mcp-storytelling](https://github.com/Mossworks-Labs/mcp-storytelling) | Writing craft, narrative structure, and author perspectives |
| [mcp-comedy](https://github.com/Mossworks-Labs/mcp-comedy) | Comedy theory, technique, and comedian knowledge |
| [mcp-yt-dlp](https://github.com/Mossworks-Labs/mcp-yt-dlp) | YouTube video info, formats, subtitles, and download via yt-dlp |
| [mcp-musicgen](https://github.com/Mossworks-Labs/mcp-musicgen) | Text-to-music generation via Meta AudioCraft (CUDA + ROCm) — runs as a GPU service, not a stdio server |

```bash
docker pull ghcr.io/mossworks-labs/mcp-storytelling:latest
```

[Documentation site](https://docs.mossworks.io/) — usage guides, architecture notes, and screenshots.

### Platform

Source repositories are private; deployable Helm charts and container images are published for licensed deployments.

- **[CRAFT Studio](https://github.com/Mossworks-Labs/craft)** — the flagship content studio. AI script writing, competitive research, multi-stage video pipeline, audio production with 300+ TTS voices, NLLB-200 self-hosted translation, and ffmpeg-based composition. Multi-tenant via Keycloak SSO.
- **[Marketplace](https://github.com/Mossworks-Labs/marketplace)** — creator-services marketplace. Flat 15% buyer fee, $0 seller fees, Stripe Connect Express escrow, transparent storage pass-through.
- **[helm-charts](https://github.com/Mossworks-Labs/helm-charts)** — monorepo for the `craft`, `gpu`, `baseline`, and `marketplace` Helm charts. Versions managed by release-please; packages published to gh-pages via chart-releaser.
- **[platform-deploy](https://github.com/Mossworks-Labs/platform-deploy)** — Pulumi program that installs CRAFT + the platform's dependencies (cert-manager, Keycloak, Cloudflare Tunnel) onto any Kubernetes cluster.

### Shared infrastructure

| Repo | Purpose |
|------|---------|
| [.github](https://github.com/Mossworks-Labs/.github) | Reusable GitHub Actions workflows + composite actions (Docker build, Node lint/test, Helm deploy, CodeQL) |
| [docs](https://github.com/Mossworks-Labs/docs) | VitePress site that builds [docs.mossworks.io](https://docs.mossworks.io/) |

---

<sub>Built with TypeScript, React, Express, Helm, PostgreSQL, NATS, Redis, ffmpeg, Claude, Gemini, Ollama, and NLLB-200.</sub>
