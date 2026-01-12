---
tags:
  - idea
  - idea/evaluating
status: evaluating
origin: personal_need
effort: medium
impact: medium
pain_type: tool_chain
target_users: neovim_power_users
competitors: ChatGPT.nvim, gen.nvim, gp.nvim
willingness_to_pay: low
aliases: []
id: Idea - Neovim Fabric AI Plugin
---

# Neovim Fabric AI Plugin

<!-- See [[Ideas/Idea Management|Idea Management]] for methodology, [[Properties]] for field definitions -->

## One-liner

A Neovim plugin that provides seamless in-editor access to Fabric AI's 220+ text processing patterns without leaving the editing environment.

## Pain Statement

Neovim users who want to leverage Fabric AI must constantly switch between their editor and terminal, manually copying text and executing commands. This context switching disrupts workflow and reduces productivity. The pain is particularly acute for:

- **Content creators** who frequently need to summarize, extract wisdom, or improve writing
- **Developers** who want to explain code, generate documentation, or review code
- **Researchers** who process articles, papers, and YouTube videos

Pain type: `tool_chain` - Users currently chain Neovim + terminal + fabric-ai + copy/paste to accomplish what should be a single in-editor action.

## Notes

### Why Fabric AI specifically?

Fabric AI offers 220+ pre-built patterns for specific text transformations:
- `summarize`, `extract_wisdom`, `extract_ideas`
- `explain_code`, `review_code`, `improve_writing`
- `youtube_summary` (with `-y` flag for video URLs)
- `analyze_claims`, `create_mermaid_visualization`

Unlike generic AI plugins, Fabric provides **curated, purpose-built prompts** that produce consistent, high-quality outputs for specific tasks.

### Existing PRD

Full PRD available at [[PRD - Fabric AI NeoVim]]

### Key differentiator from competitors

**Pattern-based approach** - Instead of writing custom prompts each time, users select from 220+ battle-tested patterns. This is faster and produces more consistent results.

## Competitor Analysis

| Competitor | Stars | Pricing | What's Missing |
|------------|-------|---------|----------------|
| [ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim) | 4k | Free (OpenAI API costs) | Generic prompts, no pattern library, requires writing instructions each time |
| [gen.nvim](https://github.com/David-Kunz/gen.nvim) | 1.5k | Free (Ollama/local) | Limited to Ollama, basic prompts, no curated pattern system |
| [gp.nvim](https://github.com/Robitx/gp.nvim) | 1.3k | Free (multi-provider) | Custom hooks required for each action, no pre-built pattern library |

### Gap in the market

**No existing plugin integrates with Fabric AI's pattern system.** All competitors require users to:
1. Write custom prompts for each task
2. Configure their own "actions" or "hooks"
3. Maintain prompt quality themselves

Fabric AI's 220+ patterns are community-maintained, battle-tested, and purpose-built.

## Requirements Sketch

### Target Users

- **Primary:** Neovim power users who already use or want to use Fabric AI
- **Secondary:** AI tool enthusiasts looking for efficient text processing
- **Tertiary:** Content creators, technical writers, developers who value keyboard-driven workflows

### Key Features

- Visual mode text selection → pattern picker → in-place replacement
- Telescope.nvim integration for pattern search/filter
- URL processing (YouTube transcripts, web pages)
- Multiple output modes (replace, append, split window, popup)
- Async processing (non-blocking UI)
- Pattern favorites and history

### Success Criteria

- Zero-friction text processing from within Neovim
- Pattern picker loads within 200ms
- Plugin startup impact < 5ms
- 100+ GitHub stars within 6 months

### Constraints

- Requires Fabric AI CLI installed
- Requires Neovim 0.8.0+
- Depends on external LLM API costs

### Dependencies

- Fabric AI CLI tool
- Optional: Telescope.nvim, Plenary.nvim

### Out of Scope

- Building our own pattern library (use Fabric's)
- Direct LLM API integration (use Fabric as abstraction)
- Non-Neovim editors

## Validation

<!-- Use [[Idea Validation Checklist]] for comprehensive validation -->

### Problem Confirmed
- [x] Problem described specifically
- [x] 3+ people confirmed the problem (personal experience + Fabric AI community)
- [x] Problem occurs regularly (daily for heavy Fabric users)

### Technical Feasibility
- [x] Can build with available tools (Lua, Neovim API, shell commands)
- [x] MVP possible in ~10 days (4 weeks per PRD timeline)

## Next Action

- [ ] Search GitHub for any existing Fabric AI Neovim integrations (final check)
- [ ] Set up basic plugin structure with lazy.nvim
- [ ] Implement core text selection → fabric-ai → replace flow

## Related

- [[PRD - Fabric AI NeoVim]] - Full product requirements document
- [[AI Coding Agent Workflows]] - Related AI tooling notes
