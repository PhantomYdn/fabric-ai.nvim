# Marketing Materials: fabric-ai.nvim

Marketing copy, promotion resources, and announcement templates for fabric-ai.nvim.

---

## Table of Contents

1. [Tone of Voice](#1-tone-of-voice)
2. [Descriptions](#2-descriptions)
3. [Taglines](#3-taglines)
4. [Features List](#4-features-list)
5. [Use Cases](#5-use-cases)
6. [Tags & Hashtags](#6-tags--hashtags)
7. [SEO Keywords](#7-seo-keywords)
8. [Competitor Comparison](#8-competitor-comparison)
9. [Demo Asset Checklist](#9-demo-asset-checklist)
10. [Promotion Checklist](#10-promotion-checklist)
11. [Announcement Templates](#11-announcement-templates)
12. [FAQ](#12-faq)
13. [Promotion TODO](#13-promotion-todo)

---

## 1. Tone of Voice

**Name:** Matter-of-fact Practical

**Description:** Straightforward and technical. States what the tool does and why it exists. No hype, no superlatives. Lets the reader decide if it's useful.

**Characteristics:**
- Describes functionality, not feelings
- Problem → solution structure
- Acknowledges limitations honestly
- Respects reader's intelligence

**Avoid:**
- "supercharge", "powerful", "amazing", "revolutionary", "game-changer"
- "unlock", "unleash", "turbocharge", "next-level"
- Exclamation marks in descriptions

**Use instead:**
- "removes", "handles", "integrates", "connects", "works with"
- "saves the step", "no need to", "also supports"

**Examples:**

| Instead of | Use |
|------------|-----|
| "Supercharge your workflow" | "Keeps everything in the editor" |
| "220+ AI superpowers" | "220+ patterns available" |
| "Zero context switching" | "No terminal round-trips" |
| "Watch AI think in real-time" | "Streaming output" |
| "Game-changing integration" | "Connects Fabric AI to Neovim" |

**Platform adjustments:**
- Reddit/social posts can be slightly warmer and conversational
- Technical docs and GitHub descriptions stay strictly matter-of-fact

---

## 2. Descriptions

### Tagline (5-8 words)

```
Fabric AI patterns in Neovim.
```

### One-liner (~15 words)

```
Neovim plugin for Fabric AI — select text, pick a pattern, see output. Handles YouTube URLs too.
```

### Very-short (1-2 sentences)

```
Connects Fabric AI's 220+ patterns to Neovim. Select text, pick a pattern, get results in a floating window. No terminal round-trips.
```

### Short (3-4 sentences)

```
fabric-ai.nvim integrates Fabric AI's pattern system into Neovim. Select text, run :Fabric, pick a pattern from a fuzzy finder, and output streams into a floating window. Works with YouTube and web URLs too. Replace selection, yank, or open in new buffer when done.
```

### Normal (~100 words)

```
fabric-ai.nvim connects Fabric AI's 220+ text processing patterns to Neovim. Instead of switching to terminal, copying text, running fabric commands, and pasting back — select text, run :Fabric, pick a pattern, and see streaming output in a floating window.

When processing finishes, press r to replace your selection, y to yank, or n for a new buffer.

The plugin also handles URLs: place cursor on a YouTube link, run :Fabric url, and it extracts the transcript automatically. Works with Telescope for fuzzy search and preview, or falls back to vim.ui.select.
```

### Expanded (~250 words)

```
fabric-ai.nvim integrates Fabric AI's pattern system into Neovim.

The problem: Using Fabric AI from Neovim means switching to terminal, copying text, running commands, copying output, switching back, and pasting. It adds up.

What this does: Select text in Neovim, run :Fabric, pick a pattern from a fuzzy finder, and output streams into a floating window. When done, one keypress applies the result — replace selection, yank to clipboard, or open in new buffer.

Features:
- Access to all 220+ Fabric patterns (including custom ones)
- YouTube URL processing — extracts transcripts automatically with -y flag
- Web URL processing — fetches page content with -u flag
- Streaming output — see results as they generate
- Telescope integration with pattern preview, or vim.ui.select fallback
- Async execution — editor stays responsive

Requirements:
- Neovim 0.10.0+
- Fabric AI CLI installed and configured
- Optional: Telescope.nvim for better pattern picker

If you already use Fabric AI and Neovim, this removes the terminal step. If you don't use Fabric yet, check it out first — this plugin is just a frontend for it.
```

### Elevator Pitch (30-second spoken)

```
If you use Fabric AI and Neovim, you know the workflow — copy text, switch to terminal, run fabric, copy output, paste back. This plugin removes that. Select text, pick a pattern, output streams right into the editor. Also handles YouTube URLs. It's a Neovim frontend for Fabric's pattern system.
```

---

## 3. Taglines

### Primary

```
Fabric AI patterns in Neovim.
```

### Alternatives

| Tagline | Best For |
|---------|----------|
| "Fabric AI in your editor" | General, simple |
| "220+ patterns, no terminal switching" | Feature + benefit |
| "A Neovim frontend for Fabric AI" | Technical accuracy |
| "Select text, pick pattern, done" | Workflow focus |

### Feature-Specific

| Feature | Tagline |
|---------|---------|
| YouTube processing | "YouTube URLs to insights, in the editor" |
| Streaming | "Streaming output in a floating window" |
| Pattern picker | "Fuzzy search 220+ patterns with preview" |
| Replace action | "Select, process, replace" |

---

## 4. Features List

Functional descriptions, no hype:

**Core:**
- 220+ Fabric patterns available (summarize, explain_code, extract_wisdom, improve_writing, etc.)
- Custom patterns supported (anything in ~/.config/fabric/patterns/)
- Streaming output — results appear as they generate
- Floating window display with action hints
- Telescope integration with pattern preview
- Falls back to vim.ui.select without Telescope

**Input modes:**
- Visual selection — select text, run :Fabric
- Range selection — :%Fabric for whole file, :10,20Fabric for lines
- Direct prompt — :Fabric with no selection opens prompt input
- URL processing — :Fabric url for YouTube transcripts and web pages

**Output actions:**
- r — replace original selection
- y — yank to clipboard
- n — open in new buffer
- q — close and discard

**Technical:**
- Async execution via vim.system() — UI never blocks
- Cancel support — q/Esc/Ctrl-C during processing
- Health check — :checkhealth fabric-ai
- Neovim 0.10.0+ required

---

## 5. Use Cases

### Explain unfamiliar code

```
Before: Copy function to ChatGPT, ask "explain this", copy explanation back.
After: Select function, :Fabric, pick explain_code, press n. Explanation in new buffer.
```

### Extract insights from YouTube video

```
Before: Find transcript tool, copy URL, run command, open result, process separately.
After: Paste YouTube URL, :Fabric url, pick extract_wisdom. Insights in your editor.
```

### Improve draft text

```
Before: Paste into Grammarly or ChatGPT, wait, copy back, manually replace.
After: Select text, :Fabric, pick improve_writing, press r. Text replaced.
```

### Summarize long article

```
Before: Read the whole thing or manually summarize.
After: Paste URL, :Fabric url, pick summarize. Key points extracted.
```

### Clean messy web copy

```
Before: Manually clean up formatting, fix line breaks, etc.
After: Select text, :Fabric, pick clean_text, press r.
```

### Generate documentation from code

```
Before: Write documentation manually or prompt ChatGPT with context.
After: Select code block, :Fabric, pick write_documentation, press n.
```

---

## 6. Tags & Hashtags

### Core (Always Use)

```
#neovim #nvim #fabricai #ai #opensource #lua
```

### Platform-Specific

**Twitter/X:**
```
#neovim #nvim #fabricai #ai #devtools #productivity #opensource
```

**Mastodon:**
```
#neovim #vim #fabricai #ai #foss #linux #productivity
```

**LinkedIn:**
```
#neovim #developer #productivity #ai #opensource #textprocessing
```

### Topic-Specific

| Context | Hashtags |
|---------|----------|
| AI/LLM focus | `#ai #llm #generativeai #gpt #claude #textprocessing` |
| Developer focus | `#coding #devtools #programming #terminal #cli` |
| Productivity focus | `#productivity #workflow #automation #efficiency` |
| Content/Writing | `#writing #contentcreation #markdown #obsidian` |
| YouTube feature | `#youtube #transcripts #video #research` |

### GitHub Repository Topics

Add these in repository settings:

```
neovim, neovim-plugin, fabric-ai, ai, lua, text-processing, productivity, youtube, telescope-nvim, llm
```

---

## 7. SEO Keywords

### Primary

- `fabric-ai neovim`
- `neovim ai plugin`
- `fabric patterns neovim`
- `neovim text processing`

### Secondary

- `neovim summarize text`
- `neovim youtube transcript`
- `ai writing plugin neovim`
- `fabric ai vim`
- `neovim llm integration`

### Long-tail

- `how to use fabric ai in neovim`
- `neovim plugin for youtube transcripts`
- `summarize text in neovim with ai`
- `extract wisdom youtube neovim`

---

## 8. Competitor Comparison

### Comparison Table

| Feature | fabric-ai.nvim | ChatGPT.nvim | gen.nvim | gp.nvim |
|---------|----------------|--------------|----------|---------|
| Pre-built patterns | 220+ | 0 | ~10 | 0 |
| Pattern preview | Yes | No | No | No |
| YouTube processing | Built-in | No | No | Manual |
| Streaming output | Yes | Yes | Yes | Yes |
| Prompt writing needed | No | Yes | Yes | Yes |
| Pattern source | Fabric community | DIY | DIY | DIY |
| Works without Telescope | Yes | Varies | Yes | Yes |

### Positioning

```
fabric-ai.nvim uses Fabric AI's 220+ community-maintained patterns. You pick a pattern, it handles the prompt. Other AI plugins require writing prompts for each task.

This isn't better or worse — it's a different approach. If you want curated patterns, use this. If you want full prompt control, use ChatGPT.nvim or gp.nvim.
```

---

## 9. Demo Asset Checklist

### Required

- [ ] **Hero GIF** — Full workflow: select text → :Fabric → pick pattern → streaming output → replace
  - Duration: 15-25 seconds
  - Show Telescope picker with pattern preview
  
- [ ] **YouTube processing GIF** — Paste URL → :Fabric url → extract_wisdom → new buffer
  - Duration: 15-20 seconds

### Recommended

- [ ] **Telescope picker screenshot** — Pattern list with preview pane visible
- [ ] **Output window screenshot** — Streaming output with action hints in footer
- [ ] **Before/After comparison** — Raw text vs processed result

### Nice to Have

- [ ] **Pattern preview close-up** — system.md preview in Telescope
- [ ] **Terminal comparison** — Side-by-side: terminal way vs plugin way

### Recording Tips

- **Colorscheme:** Clean theme (tokyonight, catppuccin, etc.)
- **Font size:** Large, readable (16pt+)
- **Duration:** Keep GIFs under 30 seconds
- **Tools:** vhs, asciinema, or OBS + gifski
- **Content:** Use real examples, not lorem ipsum

---

## 10. Promotion Checklist

### Package Registries

- [ ] **luarocks.org** — Verify package listed
- [ ] **neovimcraft.com** — Submit plugin
- [ ] **dotfyle.com** — Add to directory

### Neovim Community

- [ ] **r/neovim** — Main announcement
- [ ] **awesome-neovim** — Submit PR
- [ ] **This Week in Neovim** — Submit for inclusion
- [ ] **Neovim Discourse** — Share in appropriate category
- [ ] **Neovim Matrix/Discord** — Share in plugins channel

### Fabric AI Community

- [ ] **Fabric GitHub Discussions** — Announce integration
- [ ] **Fabric Discord** — Share if exists

### General Tech

- [ ] **r/vim** — Cross-post if appropriate
- [ ] **r/commandline** — For CLI enthusiasts
- [ ] **Hacker News** — "Show HN" submission
- [ ] **Lobsters** — Submit with neovim, ai tags

### Social Media

- [ ] **Twitter/X** — Announcement thread with GIF
- [ ] **Mastodon** — Post on fosstodon.org or relevant instance
- [ ] **Bluesky** — Share announcement
- [ ] **LinkedIn** — Professional announcement

### Content Platforms

- [ ] **Dev.to** — Tutorial or announcement
- [ ] **Hashnode** — Cross-post
- [ ] **Medium** — If existing presence
- [ ] **Personal blog** — Detailed write-up

### Video

- [ ] **YouTube** — Demo/tutorial video
- [ ] **Twitch** — Live demo if streaming

---

## 11. Announcement Templates

### Reddit r/neovim

**Title:**
```
[Plugin] fabric-ai.nvim — Fabric AI integration for Neovim
```

**Body:**
```
I made a plugin that connects Fabric AI to Neovim.

**What it does:**
- Select text, run :Fabric, pick a pattern, see streaming output
- Handles YouTube URLs — extracts transcripts with :Fabric url
- Replace selection, yank, or open in new buffer when done

[DEMO GIF HERE]

**Why:**
Using Fabric from Neovim meant terminal round-trips — copy text, run command, copy output, paste back. This keeps everything in the editor.

**Features:**
- 220+ Fabric patterns (summarize, explain_code, extract_wisdom, etc.)
- Telescope picker with pattern preview
- Falls back to vim.ui.select without Telescope
- Async — doesn't block the editor

**Requirements:**
- Neovim 0.10.0+
- Fabric AI CLI (https://github.com/danielmiessler/fabric)
- Optional: Telescope.nvim

**Install (lazy.nvim):**

    {
      "PhantomYdn/fabric-ai.nvim",
      cmd = { "Fabric" },
      opts = {},
    }

GitHub: https://github.com/PhantomYdn/fabric-ai.nvim

Feedback welcome.
```

---

### Twitter/X Thread

**Tweet 1:**
```
Made a Neovim plugin for Fabric AI.

Select text, pick a pattern, see output. Handles YouTube URLs too.

[DEMO GIF]

github.com/PhantomYdn/fabric-ai.nvim
```

**Tweet 2:**
```
What it saves:
- Copy text to terminal
- Run fabric command
- Copy output
- Paste back

Now: select text, :Fabric, done.
```

**Tweet 3:**
```
Features:
- 220+ Fabric patterns
- YouTube transcript extraction
- Streaming output
- Telescope picker with preview
- Replace/yank/new buffer actions

Requires Neovim 0.10+ and Fabric CLI.
```

**Tweet 4:**
```
If you use Fabric AI and Neovim, might save you some time.

GitHub: github.com/PhantomYdn/fabric-ai.nvim

#neovim #fabricai #opensource
```

---

### Hacker News "Show HN"

**Title:**
```
Show HN: fabric-ai.nvim – Fabric AI integration for Neovim
```

**Body:**
```
I built a Neovim plugin that integrates Fabric AI's pattern system.

Fabric AI (https://github.com/danielmiessler/fabric) has 220+ patterns for text processing — summarize, explain_code, extract_wisdom, etc. Instead of writing prompts, you pick a pattern.

The plugin:
- Select text in Neovim, pick a pattern, see streaming output
- Process YouTube URLs to extract transcripts
- Replace selection, yank, or open in new buffer

GitHub: https://github.com/PhantomYdn/fabric-ai.nvim

Requires Neovim 0.10+ and Fabric CLI. Works with Telescope for fuzzy search, or falls back to vim.ui.select.

If you use both tools, this removes the terminal step.
```

---

### Fabric GitHub Discussions

**Title:**
```
fabric-ai.nvim — Neovim integration
```

**Body:**
```
Made a Neovim plugin that integrates Fabric patterns:

GitHub: https://github.com/PhantomYdn/fabric-ai.nvim

What it does:
- Select text in Neovim, pick a pattern from fuzzy finder, see streaming output
- :Fabric url on YouTube links uses -y flag automatically
- :Fabric url on other URLs uses -u flag
- Replace selection, yank, or new buffer when done

[GIF HERE]

For Neovim users, this removes the terminal round-trip.

Feedback welcome — would like to hear what features would be useful.
```

---

### Mastodon

```
Made a Neovim plugin for Fabric AI.

Select text → pick pattern → see output. Also handles YouTube URLs.

If you use Fabric and Neovim, might be useful.

https://github.com/PhantomYdn/fabric-ai.nvim

#neovim #fabricai #foss #linux
```

---

## 12. FAQ

| Question | Answer |
|----------|--------|
| **"Why not use ChatGPT.nvim or gp.nvim?"** | Different approach. Those require writing prompts. This uses Fabric's 220+ pre-built patterns. Pick what fits your workflow. |
| **"Do I need Telescope?"** | No. Works with Telescope for fuzzy search + preview, falls back to vim.ui.select without it. |
| **"What about API costs?"** | Plugin uses your Fabric CLI config. Whatever model/API you set up in Fabric, that's what runs. |
| **"Will it block my editor?"** | No. Async via vim.system(). Can cancel with q/Esc during processing. |
| **"What Neovim version?"** | 0.10.0+ required for vim.system() support. |
| **"Custom patterns work?"** | Yes. Plugin runs fabric-ai -l which lists all patterns including custom ones. |
| **"What if Fabric CLI isn't installed?"** | Plugin shows warning on startup. :checkhealth fabric-ai gives diagnostics. |

---

## 13. Promotion TODO

### Pre-Launch

- [ ] Create hero GIF (select text → pattern → output → replace)
- [ ] Create YouTube processing GIF
- [ ] Take Telescope picker screenshot
- [ ] Add GitHub repository topics
- [ ] Verify README installation instructions
- [ ] Test clean install

### Launch Day

- [ ] Post to r/neovim
- [ ] Post Twitter/X thread
- [ ] Post to Fabric GitHub Discussions
- [ ] Submit to This Week in Neovim

### Week 1

- [ ] Submit PR to awesome-neovim
- [ ] Post "Show HN"
- [ ] Submit to dotfyle.com
- [ ] Submit to neovimcraft.com
- [ ] Respond to issues/comments within 24h

### Ongoing

- [ ] Write Dev.to article
- [ ] Consider YouTube demo
- [ ] Monitor feedback
- [ ] Update materials based on user feedback

---

## Notes

- Do not share API keys or .env contents in any materials
- Update this document as features change
- Track which channels drive engagement

---

*Last updated: January 2026*
