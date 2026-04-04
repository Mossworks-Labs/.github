# VibeSmiths

**Open-source tools for content creators.** AI-powered video production, MCP servers for research, and the infrastructure to tie it all together.

---

### Flagship

**[CRAFT Studio](https://github.com/VibeSmiths/VideoIdeas)** — The complete YouTube content studio. AI script writing, competitive research, 8-stage video pipeline with 14 AI agents, audio production with 300+ TTS voices, and Remotion-powered video rendering. Self-hosted on Kubernetes with Keycloak SSO.

[Documentation](https://vibesmiths.github.io/CRAFT/) · [Live Demo Screenshots](https://vibesmiths.github.io/CRAFT/#feature-highlights)

### MCP Servers

| Server | Description |
|--------|-------------|
| [mcp-storytelling](https://github.com/VibeSmiths/mcp-storytelling) | Writing craft, narrative structure, and author perspectives |
| [mcp-comedy](https://github.com/VibeSmiths/mcp-comedy) | History and psychology of humor — comedians, techniques, theories |
| [mcp-yt-dlp](https://github.com/VibeSmiths/mcp-yt-dlp) | Video info, formats, subtitles, and download via yt-dlp |
| [mcp-research-engine](https://github.com/VibeSmiths/mcp-research-engine) | Multi-source research aggregation |

### GPU Services

| Service | Description |
|---------|-------------|
| [mcp-musicgen](https://github.com/VibeSmiths/mcp-musicgen) | Text-to-music generation (Meta AudioCraft) — CUDA + ROCm |
| [mcp-rvc](https://github.com/VibeSmiths/mcp-rvc) | Voice cloning via Retrieval-based Voice Conversion — CUDA + ROCm |

### Infrastructure

| Repo | Description |
|------|-------------|
| [.github](https://github.com/VibeSmiths/.github) | Shared GitHub Actions — Docker build, Node.js lint/test, Helm deploy, CodeQL |
| [HeatSync](https://github.com/VibeSmiths/HeatSync) | Infrastructure and configuration management |

---

<sub>Built with TypeScript, React, Express, Helm, PostgreSQL, NATS, Redis, Remotion, Claude, Gemini, and Ollama.</sub>
