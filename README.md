<p align="center">
  <img src="https://img.shields.io/badge/status-active-success" alt="Status">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License">
  <img src="https://img.shields.io/badge/agent-Hermes%20%7C%20Claude%20Code%20%7C%20Codex%20%7C%20OpenCode-purple" alt="Compatible">
</p>

<h1 align="center">🧠 Deep TLDR</h1>
<p align="center"><b>Autonomous daily research digest for any AI agent</b></p>
<p align="center"><i>Morning briefing on your topics. Researched, summarized, delivered.</i></p>

---

Deep TLDR is an agent workflow that searches the web for the latest developments across your chosen topics, **reads every article in full**, and produces a structured research digest. It runs as a Hermes skill, but the prompt templates work with **any agent** that has web search and file writing (Claude Code, Codex, OpenCode, or custom agents).

**What makes this different from a newsletter or RSS feed:**
- It **reads the full content** of each article, not just headlines
- Produces structured analysis: plain-English summary + technical deep dive + why-it-matters
- Deduplicates against past digests so you never see the same story twice
- Can push markdown to GitHub, deliver a summary to Telegram, or generate an **audio briefing**

## 👀 Example Output

```markdown
# Daily Intel — July 21, 2026

**TLDR:** Top story: AWS Kiro flaw lets poisoned web pages rewrite MCP config for RCE.
10 stories, 4 papers. ~32 min total read.

---

## 🤖 AI NEWS

### Google Launches Gemini 3.6 Flash, 3.5 Flash-Lite, and 3.5 Flash Cyber
Google dropped three new models. 3.6 Flash: 17% fewer output tokens,
$1.50/$7.50 per 1M tokens. 3.5 Flash Cyber is purpose-built for
vulnerability discovery. Gemini 4 pre-training has begun.

**Why it matters:** Dedicated security models signal the specialized
agent-security model race is real.

---

## 🔐 SECURITY

### AWS Kiro Flaw: Hidden Web Page Text Could Rewrite MCP Config
Intezer found that one-pixel white text on a web page can trick Kiro
into writing a malicious MCP server entry. No approval required.
Third time this attack class has been reported against Kiro.

**Why it matters:** MCP config files must be write-protected against
agent tool use. The exact problem mcpsec is designed to solve.
```

Full example output: [daily/2026/07/21.md](daily/2026/07/21.md)

## 🚀 Quick Start

### Prerequisites
- An AI agent with web search + file tools (Hermes, Claude Code, Codex, OpenCode)
- For Hermes users: `hermes` CLI installed
- For GitHub output: `gh` CLI authenticated
- For Telegram delivery: gateway connected

### 3-Step Setup

**Step 1: Clone the repo**
```bash
git clone https://github.com/manthanghasadiya/deep-tldr.git
cd deep-tldr
```

**Step 2: Run the setup wizard**
```bash
bash setup.sh
```
This walks you through topics, schedule, output, and audio preferences.

**Step 3: Load and test**
```bash
# In Hermes:
/skill deep-tldr
Run a full deep-tldr digest now

# Or one-shot:
hermes -s deep-tldr -q "Run a deep-tldr digest now"
```

Set up a cron job and you will get your first digest at the next scheduled run.

## ⚙️ Configuration

Edit `~/.hermes/skills/deep-tldr/config.yaml` after setup, or re-run `setup.sh`.

| Setting | Options | Default | Description |
|---------|---------|---------|-------------|
| `topics` | comma-separated list | `ai, security, llm, web-dev, ...` | What to research |
| `custom_topics` | list | `[]` | Add topics beyond built-in |
| `frequency` | `daily`, `twice-daily` | `daily` | How often to run |
| `time_of_day` | 24h time | `08:00` | When to run |
| `timezone` | IANA tz | auto-detected | Your timezone |
| `output_mode` | `telegram-only`, `github-only`, `both` | `both` | Where the digest goes |
| `summary_style` | `tldr`, `deep`, `mixed` | `mixed` | How detailed |
| `research_papers` | `true`, `false` | `true` | Paper breakdowns |
| `audio_briefing` | `true`, `false` | `false` | Audio version |
| `max_items_per_run` | 3-12 | `7` | Article limit |

## 📋 Supported Topics

| Topic | Coverage |
|-------|----------|
| `ai` | Models, frameworks, benchmarks, agent releases, funding |
| `security` | Breaches, CVEs, attack techniques, tools, zero-days |
| `llm` | LLM papers, jailbreaks, prompting, alignment |
| `mcp` | MCP servers, vulnerabilities, spec changes |
| `web-dev` | Frameworks, runtimes, security, standards |
| `devops` | CI/CD, containers, orchestration, IaC |
| `cloud` | AWS/GCP/Azure, serverless, edge |
| `mobile` | iOS, Android, mobile security |
| `gaming` | Engines, graphics, game security |
| `crypto` | Blockchain, DeFi, exploits, tokens |
| `physics` | arXiv papers, breakthroughs, quantum |
| `biotech` | BioAI, genomics, drug discovery |
| `startups` | Funding, launches, acquisitions |
| `open-source` | New repos, popular projects, licensing |

### Adding Custom Topics

Just add entries to `custom_topics` in your config.yaml. Any topic works. The agent searches for news, papers, and GitHub repos under that keyword.

```
custom_topics:
  - rust
  - robotics
  - space
  - climate-tech
```

## 🎙️ Audio Briefing

Enable `audio_briefing: true` and set your TTS preferences:

- **Edge TTS** (default, free) - no setup needed
- **Kokoro** - runs locally via Docker
- **OpenAI TTS** - requires API key

Voices are configurable. For Edge TTS, run `edge-tts --list-voices` to see options.
For Kokoro, check the web UI at `http://localhost:8880`.

## 🔧 Portable Prompts (Non-Hermes Users)

Deep TLDR isn't Hermes-exclusive. The raw prompt templates in `prompts/` work with **any agent** that has:
- Web search / content extraction
- File writing
- (Optional) TTS capability

**Usage with Claude Code:**
```bash
claude -p "$(cat prompts/deep-tldr-prompt.md)" -q "Run a digest on topics: ai, security, web-dev"
```

**Usage with Codex:**
```bash
codex "$(cat prompts/deep-tldr-prompt.md)" "Run today's digest"
```

**Usage with OpenCode:**
```bash
opencode -m "Read prompts/deep-tldr-prompt.md and execute the digest workflow"
```

Just replace `TOPIC_LIST`, `SEEN_URLS_FILE`, and `OUTPUT_DIR` with your values.

## 📁 Output Structure

```
digest-directory/
├── daily/
│   └── YYYY/MM/DD.md          # Daily digest with full breakdowns
├── papers/
│   └── YYYY/MM/
│       └── paper-title-slug.md # Individual research paper deep-dives
└── audio/
    └── YYYY/MM/DD.mp3          # Audio briefing (if enabled)
```

## 🤝 Contributing

PRs welcome! Areas to improve:
- More topic-specific search strategies
- Additional output formats (Notion, email, Slack)
- New TTS backends
- Custom search sources per topic

## 📄 License

|MIT license|

---

<p align="center">
  Built by <a href="https://github.com/manthanghasadiya">Manthan Ghasadiya</a>
  &middot;
  Powered by <a href="https://hermes-agent.nousresearch.com">Hermes Agent</a>
</p>
