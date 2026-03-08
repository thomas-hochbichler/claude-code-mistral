# Claude Code + Mistral.ai: EU-Compliant AI Coding

Route Claude Code through Mistral.ai's EU-hosted API for GDPR-compliant AI-assisted development.

> **Tested with**: claude-code-router v2.0.0 | Node.js 20+ | Claude Code latest
> **Models**: Devstral 2, Codestral 2, Mistral Large 3, Mistral Small 3.1
> **Platform**: macOS / Linux

## Quick Start (< 5 minutes)

### Prerequisites

- **Node.js** >= 20.0.0 (`node --version`)
- **Claude Code** installed (`claude --version`)
- **Mistral API Key** from [console.mistral.ai](https://console.mistral.ai)

```bash
git clone https://github.com/hochbichler/claude-code-mistral.git
cd claude-code-mistral

export MISTRAL_API_KEY="your-key-here"
./setup.sh

ccr code
```

The setup script checks prerequisites, installs claude-code-router, and creates your configuration automatically.

## Verification

After setup, verify that requests route through Mistral's EU API:

```bash
ccr code
# Run a simple task, then check logs:
cat ~/.claude-code-router/logs/ccr-*.log | grep "api.mistral.ai"
```

The statusline should display the active Mistral model (e.g., `devstral-2-2512`).

## Switching Between Cloud and Local

### Switch to Local (Ollama)

Route all requests through a local Ollama instance — data never leaves your machine:

```bash
ollama pull devstral-small:latest
cp -r presets/mistral-ollama ~/.claude-code-router/presets/
ccr mistral-ollama
```

### Switch Back to Cloud

```bash
ccr mistral-cloud
```

## Persistent Shell Integration

Add to `~/.zshrc` or `~/.bashrc` for automatic routing in every terminal session:

```bash
export MISTRAL_API_KEY="your-key-here"
eval "$(ccr activate)"
```

Then use `claude` directly — requests route through Mistral automatically.

## Repository Structure

```
├── config.json                    # Mistral EU API configuration template
├── setup.sh                       # Automated setup script
├── plugins/
│   └── strip-reasoning.js          # Custom CCR transformer plugin
├── presets/
│   ├── mistral-cloud/manifest.json  # Cloud preset (Mistral EU API)
│   ├── mistral-ollama/manifest.json # Local preset (Ollama)
│   └── mistral-lm-studio/manifest.json # Local preset (LM Studio)
└── article/
    ├── part-1-setup-guide.md        # Part 1: Setup Guide (ready)
    ├── part-2-testing.md            # Part 2: Testing the Limits (outline)
    └── part-3-alternatives.md       # Part 3: Alternatives (outline)
```

## Known Limitations

- **Windows**: Not tested. macOS and Linux only.
- **Model aliases**: `mistral-large-latest` may point to different model versions over time. Pin to `mistral-large-2512` if you need consistency.
- **Third-party dependency**: claude-code-router is a community project, not endorsed by Anthropic. The `ANTHROPIC_BASE_URL` environment variable used internally is an official Claude Code feature.
- **Multimodal**: Image processing support depends on the model and may have limitations through the proxy.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| 422 API Error (`cache_control`) | Missing `cleancache` transformer | Verify `config.json` includes `"cleancache"` in transformer `use` array |
| 422 API Error (`reasoning`) | Missing `stripreasoning` transformer | Run `setup.sh` or copy `plugins/strip-reasoning.js` to `~/.claude-code-router/plugins/` and add `"stripreasoning"` to `use` array |
| `MISTRAL_API_KEY not set` | Missing environment variable | `export MISTRAL_API_KEY="your-key"` |
| Node.js version error | Node < 20 | Install Node.js 20+ via nvm or the official installer |
| Connection timeout | API unreachable | Check network, verify API key at [console.mistral.ai](https://console.mistral.ai) |
| Existing config warning | Config already exists | `setup.sh` prompts before overwriting; backup at `config.json.bak` |

## Companion Article Series

The full guide is split into three parts:

1. **[Part 1: Setup Guide](article/part-1-setup-guide.md)** — EU compliance context, architecture, step-by-step configuration, model selection, and troubleshooting. *Ready to read.*
2. **[Part 2: Testing the Limits](article/part-2-testing.md)** — Real-world testing of tool-calling, MCP servers, skills, and extended thinking per model. *Outline — in progress.*
3. **[Part 3: Beyond Mistral](article/part-3-alternatives.md)** — Alternative EU-compliant setups: Vibe CLI, other providers, self-hosted models, and enterprise patterns. *Outline — in progress.*

## License

[MIT](LICENSE)

---

> **Disclaimer**: This repository provides a technical guide for configuring AI development tools. It is not legal advice. For questions about GDPR compliance, data processing obligations, or regulatory requirements specific to your organization, consult a qualified Data Protection Officer (DPO) or legal counsel.
