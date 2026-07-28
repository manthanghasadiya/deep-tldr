---
name: deep-tldr
description: "Deep TLDR research digest - daily briefing on your chosen topics"
version: 1.0.0
author: manthanghasadiya
license: MIT
metadata:
  hermes:
    tags: [research, cron, daily-digest, tts, automation]
    homepage: https://github.com/manthanghasadiya/deep-tldr
---

# Deep TLDR - Research Digest

This skill builds a daily deep-dive research digest on any topics you choose.
It searches the web, reads full articles, writes structured markdown, optionally
pushes to GitHub and generates an audio briefing. Works as a cron job.

## How It Works

1. Reads your `config.yaml` for topics, schedule, and output preferences
2. Searches for the latest content across all your topics
3. **Reads full articles** (not just snippets)
4. Classifies content by topic and writes a structured digest
5. Optionally writes separate research paper breakdowns
6. Pushes to GitHub (if configured)
7. Generates an audio briefing via TTS (if configured)
8. Delivers a short summary to your messaging platform

## Prerequisites

- Hermes installed with `web` and `terminal` toolsets enabled
- At least one LLM provider configured (OpenRouter, Claude, Gemini, etc.)
- For GitHub output: `gh` CLI authenticated
- For audio: Edge TTS (built-in, free) or Kokoro/OpenAI TTS
- For Telegram delivery: gateway connected

## Usage

### 1. Load the skill

```
/skill deep-tldr
```

Or from CLI:
```bash
hermes -s deep-tldr
```

### 2. Run a one-shot digest

Just tell the agent:
```
/skill deep-tldr
Run a deep-tldr digest now
```

The skill reads your config and executes the full pipeline.

### 3. Set up a cron job

For automated daily runs, set up a schedule:

```
Run deep-tldr as a cron job every day at 8 AM
```

Or use the setup script:
```bash
bash ~/.hermes/skills/deep-tldr/setup.sh
```

## Configuration

This skill reads `~/.hermes/skills/deep-tldr/config.yaml`. A template is
at `config.example.yaml` in the skill directory.

### Topics

The topics list drives the search queries. Each topic generates targeted
searches for news, papers, tools, and vulnerabilities. Built-in topics:

`ai`, `security`, `web-dev`, `devops`, `cloud`, `mobile`, `gaming`,
`crypto`, `physics`, `biotech`, `startups`, `open-source`, `llm`, `mcp`

Add your own with custom_topics. They go into a custom section that
searches for general news and papers under that keyword.

### Style Reference

| Setting | Values | Description |
|---------|--------|-------------|
| `summary_style` | `tldr`, `deep`, `mixed` | How detailed the summaries are |
| `output_mode` | `telegram-only`, `github-only`, `both` | Where the digest goes |
| `audio_briefing` | `true`, `false` | Generate a spoken version |
| `research_papers` | `true`, `false` | Separate deep-dive paper breakdowns |
| `frequency` | `daily`, `twice-daily` | How often to run |

## What Each Topic Searches

| Topic | Search Coverage |
|-------|----------------|
| `ai` | New models, frameworks, benchmarks, agent releases, funding |
| `security` | Breaches, CVEs, attack techniques, new tools, zero-days |
| `llm` | LLM-specific papers, jailbreaks, prompting, alignment |
| `mcp` | MCP servers, vulnerabilities, spec changes, tool security |
| `web-dev` | Frameworks, runtimes, security, new standards |
| `devops` | CI/CD, containers, orchestration, IaC |
| `cloud` | AWS/GCP/Azure news, serverless, edge computing |
| `mobile` | iOS, Android, mobile frameworks, app security |
| `gaming` | Game engines, graphics, game security, modding |
| `crypto` | Blockchain, DeFi, exploits, regulations, tokens |
| `physics` | arXiv papers, breakthroughs, quantum computing |
| `biotech` | BioAI, genomics, drug discovery, lab automation |
| `startups` | Funding, launches, acquisitions, pivots |
| `open-source` | New repos, popular projects, licensing |

All topics also check arXiv for recent papers and GitHub for trending repos.

## Output Structure

### GitHub markdown (github or both mode)

```
daily/YYYY/MM/DD.md          # Full digest with deep-dive sections
papers/YYYY/MM/slug.md       # Individual paper breakdowns
audio/YYYY/MM/DD.mp3         # Audio briefing (if enabled)
```

### Telegram (telegram or both mode)

Short summary with headlines + link to full digest on GitHub.

## Portable Prompts

The raw prompt templates in `prompts/deep-tldr-prompt.md` work with **any
agent** that has web search and file writing (Hermes, Claude Code, OpenCode,
Codex, or custom agents). Just copy the prompt and adapt the delivery section.
