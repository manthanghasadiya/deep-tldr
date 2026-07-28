#!/usr/bin/env bash
set -e

# =============================================================================
# Deep TLDR - Setup Script
# =============================================================================
# Interactive installer that configures your research digest.
# Run: bash setup.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$HOME/.hermes/skills/deep-tldr"
CONFIG_PATH="$SKILL_DIR/config.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        Deep TLDR - Setup Wizard            ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "This will configure your daily research digest."
echo "Press Enter to accept defaults shown in [brackets]."
echo ""

# ─── Prerequisites Check ────────────────────────────────────────────────────

echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v hermes &> /dev/null; then
    echo -e "${RED}Hermes not found. Install it first:${NC}"
    echo "  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} Hermes found"

# ─── Topics ──────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}── Topics ────────────────────────────────────${NC}"
echo "Enter topics separated by commas."
echo "Default: ai, security, llm, web-dev, devops, cloud, crypto, physics, startups, open-source"
echo ""

read -r -p "Topics [ai, security, llm, web-dev, devops, cloud, crypto, physics, startups, open-source]: " topics_input
topics_input="${topics_input:-ai, security, llm, web-dev, devops, cloud, crypto, physics, startups, open-source}"

echo ""
read -r -p "Custom topics (comma-separated, or leave blank): " custom_input

# ─── Schedule ────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}── Schedule ───────────────────────────────────${NC}"

# Detect timezone
detected_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")

read -r -p "Frequency (daily / twice-daily) [daily]: " freq_input
freq_input="${freq_input:-daily}"

read -r -p "Time of day (24h, e.g. 08:00) [08:00]: " time_input
time_input="${time_input:-08:00}"

if [ "$freq_input" = "twice-daily" ]; then
    read -r -p "Second time [20:00]: " time2_input
    time2_input="${time2_input:-20:00}"
fi

read -r -p "Timezone [$detected_tz]: " tz_input
tz_input="${tz_input:-$detected_tz}"

# ─── Output Mode ─────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}── Output ─────────────────────────────────────${NC}"
echo "Where should the digest go?"
echo "  1) telegram-only  - just a message to your chat"
echo "  2) github-only    - full markdown to a GitHub repo"
echo "  3) both           - short Telegram summary + GitHub full digest"
echo ""
read -r -p "Output mode [3]: " mode_input
case "${mode_input:-3}" in
    1) output_mode="telegram-only" ;;
    2) output_mode="github-only" ;;
    *) output_mode="both" ;;
esac

repo_name=""
if [ "$output_mode" = "github-only" ] || [ "$output_mode" = "both" ]; then
    read -r -p "GitHub repo name [my-intel-daily]: " repo_input
    repo_name="${repo_input:-my-intel-daily}"

    # Check gh auth
    if command -v gh &> /dev/null; then
        if gh auth status &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} GitHub CLI authenticated"
        else
            echo -e "  ${YELLOW}⚠${NC} GitHub CLI not authenticated. Run: gh auth login"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} gh CLI not found. Install it or create the repo manually."
    fi
fi

# ─── Style ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}── Style ──────────────────────────────────────${NC}"
echo "Summary style:"
echo "  tldr   - 2-3 sentence summaries (quick scan)"
echo "  deep   - full article reads with methodology"
echo "  mixed  - short on Telegram, deep on GitHub"
echo ""
read -r -p "Style [mixed]: " style_input
style_input="${style_input:-mixed}"

read -r -p "Include research paper breakdowns? (y/n) [y]: " papers_input
case "${papers_input:-y}" in
    n|N) papers="false" ;;
    *) papers="true" ;;
esac

read -r -p "Max articles per run (3-12) [7]: " max_input
max_input="${max_input:-7}"

# ─── Audio Briefing ──────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}── Audio Briefing ────────────────────────────${NC}"
read -r -p "Generate audio briefing? (y/n) [n]: " audio_input
case "${audio_input:-n}" in
    y|Y)
        audio="true"
        read -r -p "TTS provider (edge / kokoro / openai) [edge]: " tts_provider
        tts_provider="${tts_provider:-edge}"
        read -r -p "TTS voice [en-US-JennyNeural]: " tts_voice
        tts_voice="${tts_voice:-en-US-JennyNeural}"
        read -r -p "Speed multiplier (0.8-1.5) [1.0]: " tts_speed
        tts_speed="${tts_speed:-1.0}"
        if [ "$tts_provider" = "kokoro" ]; then
            read -r -p "Kokoro API endpoint [http://localhost:8880]: " kokoro_endpoint
            kokoro_endpoint="${kokoro_endpoint:-http://localhost:8880}"
        fi
        ;;
    *) audio="false" ;;
esac

# ─── Write Config ────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}Writing configuration...${NC}"

mkdir -p "$SKILL_DIR"

# Format topics as YAML list
topics_yaml=$(echo "$topics_input" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^/  - /')

custom_yaml=""
if [ -n "$custom_input" ]; then
    custom_yaml=$(echo "$custom_input" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^/  - /')
fi

cat > "$CONFIG_PATH" << CONFIGEOF
# Deep TLDR Configuration
# Generated by setup.sh on $(date)

topics:
$topics_yaml
custom_topics:
$custom_yaml

frequency: "$freq_input"
time_of_day: "$time_input"
timezone: "$tz_input"
CONFIGEOF

if [ "$freq_input" = "twice-daily" ]; then
    echo "time_of_day_second: \"$time2_input\"" >> "$CONFIG_PATH"
fi

cat >> "$CONFIG_PATH" << CONFIGEOF2

output_mode: "$output_mode"
github:
  repo_name: "$repo_name"
  file_structure: "daily/YYYY/MM/DD.md"

summary_style: "$style_input"
research_papers: $papers
max_items_per_run: $max_input

audio_briefing: $audio
tts_provider: "$tts_provider"
tts_voice: "$tts_voice"
tts_speed: $tts_speed
CONFIGEOF2

if [ "$tts_provider" = "kokoro" ] && [ -n "$kokoro_endpoint" ]; then
    echo "kokoro_endpoint: \"$kokoro_endpoint\"" >> "$CONFIG_PATH"
fi

echo -e "  ${GREEN}✓${NC} Config written to $CONFIG_PATH"

# ─── Install Skill ──────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}Installing Hermes skill...${NC}"

# Copy skill and config to Hermes skills directory
cp "$SCRIPT_DIR/skills/deep-tldr/skill.md" "$SKILL_DIR/skill.md"

echo -e "  ${GREEN}✓${NC} Skill installed to $SKILL_DIR"

# ─── Set Up Cron ────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}── Cron Job ───────────────────────────────────${NC}"
read -r -p "Set up the cron job now? (y/n) [y]: " cron_yn
case "${cron_yn:-y}" in
    y|Y)
        # Convert time to cron format
        cron_hour=$(echo "$time_input" | cut -d: -f1 | sed 's/^0//')
        cron_min=$(echo "$time_input" | cut -d: -f2 | sed 's/^0//')

        echo ""
        echo -e "  ${GREEN}✓${NC} Creating cron job..."
        echo ""
        echo "  Run this command in Hermes:"
        echo ""
        echo -e "  ${CYAN}hermes cron create \"$cron_min $cron_hour * * *\" \\${NC}"
        echo -e "  ${CYAN}  --name \"deep-tldr\" \\${NC}"
        echo -e "  ${CYAN}  --skills \"deep-tldr\" \\${NC}"
        echo -e "  ${CYAN}  --prompt \"Run a full deep-tldr digest now\"${NC}"
        echo ""
        echo "  Or paste this into a Hermes session:"
        echo ""
        echo -e "  ${CYAN}/cron create \"$cron_min $cron_hour * * *\" \\${NC}"
        echo -e "  ${CYAN}  --name \"deep-tldr\" \\${NC}"
        echo -e "  ${CYAN}  --skills \"deep-tldr\" \\${NC}"
        echo -e "  ${CYAN}  --prompt \"Run the deep-tldr skill now. Read config from ~/.hermes/skills/deep-tldr/config.yaml and execute the full pipeline.\"${NC}"
        echo ""

        if [ "$audio" = "true" ] && [ "$freq_input" = "daily" ]; then
            # Suggest a second cron for audio at +15 min
            audio_hour=$cron_hour
            audio_min=$((10#$cron_min + 15))
            if [ "$audio_min" -ge 60 ]; then
                audio_min=$((audio_min - 60))
                audio_hour=$((audio_hour + 1))
            fi
            echo "  For audio briefing, add a second cron at ${audio_hour}:${audio_min}:"
            echo ""
            echo -e "  ${CYAN}/cron create \"$audio_min $audio_hour * * *\" \\${NC}"
            echo -e "  ${CYAN}  --name \"deep-tldr-audio\" \\${NC}"
            echo -e "  ${CYAN}  --prompt \"Read today's digest from ~/.hermes/cron/intel-repo/daily/... generate audio briefing and send it.\"${NC}"
            echo ""
        fi
        ;;
esac

# ─── Test Run ? ─────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}── Test Run ──────────────────────────────────${NC}"
read -r -p "Run a test digest now? (y/n) [y]: " test_yn
case "${test_yn:-y}" in
    y|Y)
        echo ""
        echo "Starting test run..."
        echo "In Hermes, load the skill and run:"
        echo ""
        echo -e "  ${CYAN}/skill deep-tldr${NC}"
        echo -e "  ${CYAN}Run a full deep-tldr digest now${NC}"
        echo ""
        echo "Or from CLI:"
        echo ""
        echo -e "  ${CYAN}hermes -s deep-tldr -q \"Run a full deep-tldr digest now\"${NC}"
        echo ""
        ;;
esac

# ─── Summary ─────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Setup Complete!                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "  Config:  $CONFIG_PATH"
echo "  Topics:  $topics_input"
echo "  Schedule: $freq_input at $time_input $tz_input"
echo "  Output:  $output_mode"
echo "  Audio:   $audio"
echo ""
echo "Edit $CONFIG_PATH anytime to change settings."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit config if needed: nano $CONFIG_PATH"
echo "  2. Load the skill in Hermes: /skill deep-tldr"
echo "  3. Set up cron (command shown above)"
echo "  4. Run a test: hermes -s deep-tldr -q \"Run digest now\""
echo ""
