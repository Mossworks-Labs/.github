# Mossworks Labs

**Open-source tools for content creators.** AI-powered video production, MCP servers for research, and the infrastructure to tie it all together.

---

### Flagship

**[CRAFT Studio](https://github.com/Mossworks-Labs/craft)** — The complete YouTube content studio. AI script writing, competitive research, 8-stage video pipeline with 14 AI agents, audio production with 300+ TTS voices, and Remotion-powered video rendering. Self-hosted on Kubernetes with Keycloak SSO.

[Documentation](https://docs.mossworks.io/) · [Live Demo Screenshots](https://docs.mossworks.io/#feature-highlights)

### MCP Servers

| Server | Description |
|--------|-------------|
| [mcp-storytelling](https://github.com/Mossworks-Labs/mcp-storytelling) | Writing craft, narrative structure, and author perspectives |
| [mcp-comedy](https://github.com/Mossworks-Labs/mcp-comedy) | History and psychology of humor — comedians, techniques, theories |
| [mcp-yt-dlp](https://github.com/Mossworks-Labs/mcp-yt-dlp) | Video info, formats, subtitles, and download via yt-dlp |
| [mcp-research-engine](https://github.com/Mossworks-Labs/mcp-research-engine) | Multi-source research aggregation |

### GPU Services

| Service | Description |
|---------|-------------|
| [mcp-musicgen](https://github.com/Mossworks-Labs/mcp-musicgen) | Text-to-music generation (Meta AudioCraft) — CUDA + ROCm |

### Docker Packages

All images published to GitHub Container Registry (`ghcr.io/mossworks-labs`):

| Package | Source | Runtime |
|---------|--------|---------|
| [`studio`](https://ghcr.io/mossworks-labs/studio) | [craft](https://github.com/Mossworks-Labs/craft) | Node.js 22 Alpine |
| [`frontend`](https://ghcr.io/mossworks-labs/frontend) | [craft](https://github.com/Mossworks-Labs/craft) | nginx |
| [`mcp-storytelling`](https://ghcr.io/mossworks-labs/mcp-storytelling) | [mcp-storytelling](https://github.com/Mossworks-Labs/mcp-storytelling) | Node.js 22 Alpine |
| [`mcp-comedy`](https://ghcr.io/mossworks-labs/mcp-comedy) | [mcp-comedy](https://github.com/Mossworks-Labs/mcp-comedy) | Node.js 22 Alpine |
| [`mcp-yt-dlp`](https://ghcr.io/mossworks-labs/mcp-yt-dlp) | [mcp-yt-dlp](https://github.com/Mossworks-Labs/mcp-yt-dlp) | Node.js 22 Alpine |
| [`mcp-musicgen`](https://ghcr.io/mossworks-labs/mcp-musicgen) | [mcp-musicgen](https://github.com/Mossworks-Labs/mcp-musicgen) | PyTorch CUDA |
| [`mcp-musicgen-rocm`](https://ghcr.io/mossworks-labs/mcp-musicgen-rocm) | [mcp-musicgen](https://github.com/Mossworks-Labs/mcp-musicgen) | PyTorch ROCm |

```bash
docker pull ghcr.io/mossworks-labs/studio:latest
```

### Infrastructure

| Repo | Description |
|------|-------------|
| [.github](https://github.com/Mossworks-Labs/.github) | Shared GitHub Actions — Docker build, Node.js lint/test, Helm deploy, CodeQL |
| [baseline](https://github.com/Mossworks-Labs/baseline) | Helm chart for cluster baseline (cert-manager, external-dns) |
| [docs](https://github.com/Mossworks-Labs/docs) | VitePress user guide — deploys to docs.mossworks.io |

---

<sub>Built with TypeScript, React, Express, Helm, PostgreSQL, NATS, Redis, Remotion, Claude, Gemini, and Ollama.</sub>
