# Product Requirements Document: fabric-ai.nvim v1.0

## 1. Executive Summary

### 1.1 Product Vision
A Neovim plugin that provides seamless in-editor access to Fabric AI's 220+ text processing patterns, eliminating context switching between editor and terminal.

### 1.2 Problem Statement
Neovim users leveraging Fabric AI must constantly switch between editor and terminal, manually copying text and executing commands. This disrupts workflow and reduces productivity for developers, content creators, and researchers.

### 1.3 Solution
A native Neovim plugin with:
- Visual selection processing with streaming output
- Pattern picker with preview (Telescope + vim.ui.select)
- Floating window for real-time AI output
- URL processing (YouTube transcripts, web pages)
- Intuitive action system (replace, yank, new buffer)

### 1.4 Key Differentiator
Unlike generic AI plugins (ChatGPT.nvim, gen.nvim, gp.nvim), fabric-ai.nvim leverages Fabric's **220+ battle-tested, community-maintained patterns** - no custom prompt writing required.

---

## 2. Target Users

### 2.1 Primary Users
- **Neovim Power Users**: Developers using Neovim as primary editor
- **Fabric AI Users**: Those already using or wanting to use Fabric CLI
- **Content Creators**: Technical writers, bloggers, documentation authors

### 2.2 User Characteristics
- Comfortable with modal editing
- Value keyboard-driven workflows
- Interested in AI-assisted text processing
- Familiar with plugin installation (lazy.nvim, etc.)

---

## 3. Technical Requirements

### 3.1 Dependencies

**Required:**
- Neovim 0.10.0+ (for `vim.system()` async support)
- Fabric AI CLI (`fabric-ai` or `fabric`)
- Lua 5.1+ (bundled with Neovim)

**Optional:**
- Telescope.nvim (enhanced picker UI with preview)

### 3.2 Platform Support
- Linux (primary)
- macOS
- Windows (WSL)

### 3.3 Plugin Structure
```
fabric-ai.nvim/
├── lua/
│   └── fabric-ai/
│       ├── init.lua           # Main entry point
│       ├── config.lua         # Configuration management
│       ├── commands.lua       # Command definitions
│       ├── picker.lua         # Pattern picker (Telescope + fallback)
│       ├── processor.lua      # Fabric CLI execution
│       ├── window.lua         # Floating window management
│       ├── url.lua            # URL detection and handling
│       ├── patterns.lua       # Pattern discovery and caching
│       └── health.lua         # :checkhealth integration
├── plugin/
│   └── fabric-ai.lua          # Plugin initialization
├── doc/
│   └── fabric-ai.txt          # Vimdoc documentation
├── README.md
├── LICENSE
├── AGENTS.md
├── PRD_v1.md
├── PLAN_v1.md
└── .stylua.toml
```

---

## 4. MVP Features (Milestones 1-6)

### Milestone 1: Core Infrastructure
**Goal:** Plugin skeleton with configuration system

**Features:**
- Plugin initialization with lazy-loading support
- Configuration API with sensible defaults
- Fabric CLI path detection and validation
- Health check integration (`:checkhealth fabric-ai`)

**Configuration Options:**
```lua
{
  fabric_path = "fabric-ai",           -- Path to Fabric CLI
  patterns_path = nil,                 -- Custom patterns directory (auto-detect if nil)
  window = {
    width = 0.8,                       -- 80% of editor width
    height = 0.8,                      -- 80% of editor height
    border = "rounded",
  },
  timeout = 120000,                    -- Command timeout in ms (2 minutes)
  default_action = "window",           -- Default output action
}
```

**Acceptance Criteria:**
- [ ] Plugin loads without errors
- [ ] `:checkhealth fabric-ai` reports Fabric CLI status
- [ ] Configuration can be customized via `setup()`

---

### Milestone 2: Pattern System
**Goal:** Pattern discovery with picker interface

**Features:**
- Pattern discovery via `fabric-ai -l`
- Pattern preview (read `system.md` from pattern directory)
- Telescope.nvim picker with fuzzy search and preview
- vim.ui.select fallback for non-Telescope users
- Support for both built-in and custom patterns

**Pattern Sources:**
1. Default: `~/.config/fabric/patterns/`
2. Custom: Read from Fabric config or user override

**Acceptance Criteria:**
- [ ] All patterns listed from `fabric-ai -l`
- [ ] Pattern `system.md` shown in Telescope preview
- [ ] Fallback to vim.ui.select works without Telescope
- [ ] Custom patterns directory supported

---

### Milestone 3: Text Processing
**Goal:** Visual selection to Fabric with streaming output

**Features:**
- Visual mode text selection capture
- Async Fabric CLI execution via `vim.system()`
- Streaming output to floating window
- Real-time buffer updates as content arrives
- Auto-scroll to bottom during streaming

**Commands:**
- `:Fabric` or `:Fabric run` - Process visual selection

**Acceptance Criteria:**
- [ ] Visual selection captured correctly
- [ ] Streaming output visible in real-time
- [ ] UI remains responsive during processing
- [ ] Floating window displays with correct dimensions

---

### Milestone 4: Output Actions
**Goal:** User actions on processed output

**Features:**
- Floating window with action keybindings
- Action hints displayed in window border/footer

**Actions:**
| Key | Action | Description |
|-----|--------|-------------|
| `r` | Replace | Replace original selection with output |
| `y` | Yank | Copy output to system clipboard |
| `n` | New Buffer | Open output in new buffer |
| `q` | Close | Discard output and close window |

**Acceptance Criteria:**
- [ ] All four actions work correctly
- [ ] Keybindings shown in window
- [ ] Original selection replaced on `r`
- [ ] System clipboard populated on `y`
- [ ] New buffer created on `n`

---

### Milestone 5: URL Processing
**Goal:** Process URLs under cursor

**Features:**
- URL detection under cursor
- YouTube URL detection (`youtube.com`, `youtu.be`)
- Automatic flag selection:
  - YouTube: `fabric-ai -y <url>`
  - Other URLs: `fabric-ai -u <url>`
- Same output flow as text processing

**Commands:**
- `:Fabric url` - Process URL under cursor

**Acceptance Criteria:**
- [ ] URL under cursor correctly detected
- [ ] YouTube URLs use `-y` flag
- [ ] Other URLs use `-u` flag
- [ ] Pattern picker shown after URL detection
- [ ] Output flows to floating window

---

### Milestone 6: Polish & Documentation
**Goal:** Production-ready release

**Features:**
- Comprehensive error handling
- User-friendly error messages via `vim.notify()`
- Vimdoc documentation (`doc/fabric-ai.txt`)
- README with installation and usage
- Example lazy.nvim configuration

**Error Handling:**
- Fabric CLI not found
- Pattern execution timeout
- Network errors (URL processing)
- Invalid selection

**Acceptance Criteria:**
- [ ] All error cases handled gracefully
- [ ] `:help fabric-ai` works
- [ ] README complete with examples
- [ ] Plugin installable via lazy.nvim

---

## 5. Future Phases (Post-MVP)

### Phase 2: Enhanced Picker Support
- **Snacks.nvim Integration**: Support snacks.nvim picker as alternative
- **fzf-lua Integration**: Support fzf-lua picker
- **Priority**: Medium

### Phase 3: Pattern Management
- **Favorites**: Mark frequently used patterns
- **History**: Track recently used patterns
- **Quick Access**: Keybinding for last-used pattern
- **Priority**: Medium

### Phase 4: Advanced Features
- **Model Selection**: UI for choosing Fabric model
- **Editable Output**: Allow editing in output window before action
- **Multiple Sessions**: Support concurrent Fabric executions
- **Context Integration**: Use Fabric's context system
- **Priority**: Low

### Phase 5: Developer Experience
- **CI/CD Pipeline**: GitHub Actions (StyLua, luacheck, tests)
- **Automated Tests**: Unit tests with busted
- **Coverage Reports**: LuaCov integration
- **Auto-release**: luarocks + GitHub releases
- **Priority**: Medium

### Phase 6: Integrations
- **Lualine Component**: Status indicator during processing
- **Which-key Integration**: Keybinding hints
- **Mini.nvim Support**: Alternative picker/window
- **Priority**: Low

---

## 6. User Stories

### MVP User Stories

| ID | As a... | I want to... | So that... |
|----|---------|--------------|------------|
| US-01 | Developer | Select code and apply patterns | I can explain/document code without leaving Neovim |
| US-02 | Writer | Summarize selected text | I can quickly condense content |
| US-03 | Researcher | Process YouTube URLs | I can extract insights from videos |
| US-04 | User | Search patterns by name | I can quickly find the right pattern |
| US-05 | User | Preview pattern prompts | I can understand what each pattern does |
| US-06 | User | See streaming output | I know processing is happening |
| US-07 | User | Choose what to do with output | I control how results are used |
| US-08 | User | Get clear error messages | I can troubleshoot issues |

### Future User Stories

| ID | As a... | I want to... | So that... |
|----|---------|--------------|------------|
| US-09 | Power User | Mark favorite patterns | I can access them quickly |
| US-10 | User | See recently used patterns | I can repeat common tasks |
| US-11 | Developer | Edit output before replacing | I can make adjustments |
| US-12 | User | Use snacks.nvim picker | I can use my preferred picker |

---

## 7. Non-Functional Requirements

### 7.1 Performance
- **NFR-01**: Pattern picker opens within 300ms
- **NFR-02**: Plugin startup impact < 5ms (lazy-loaded)
- **NFR-03**: UI never blocks during Fabric processing
- **NFR-04**: Streaming updates at least every 100ms

### 7.2 Usability
- **NFR-05**: All actions accessible via single keypress
- **NFR-06**: Error messages actionable and clear
- **NFR-07**: Works without Telescope (graceful fallback)
- **NFR-08**: Follows Neovim plugin conventions

### 7.3 Reliability
- **NFR-09**: Graceful handling of Fabric CLI absence
- **NFR-10**: Timeout handling for long-running patterns
- **NFR-11**: No data loss on error (original text preserved)

### 7.4 Maintainability
- **NFR-12**: Code follows StyLua formatting
- **NFR-13**: LuaCATS annotations for all public APIs
- **NFR-14**: Modular architecture (single responsibility)

---

## 8. Success Metrics

### 8.1 Adoption (6-month targets)
- GitHub stars: 100+
- Active users: Track via issues/discussions
- Community contributions: 5+ PRs

### 8.2 Quality
- Critical bugs: < 3 open at any time
- Issue response time: < 72 hours
- Documentation coverage: 100% public API

### 8.3 Performance
- Startup impact: < 5ms measured
- User-reported lag issues: < 5

---

## 9. Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Fabric CLI API changes | High | Low | Version detection, compatibility layer |
| Streaming implementation complexity | Medium | Medium | Start with simple polling, enhance later |
| Telescope dependency issues | Medium | Low | Robust fallback to vim.ui.select |
| Large output handling | Medium | Low | Virtual text, truncation options |
| Cross-platform path issues | Medium | Medium | Use vim.fn for path handling |

---

## 10. Open Questions (Resolved)

| Question | Resolution |
|----------|------------|
| Pattern caching strategy | No caching for MVP, add later |
| Default keybindings | Commands only; keybindings in lazy.nvim example |
| Picker priority | Telescope preferred, vim.ui.select fallback |
| Model selection in MVP | No, use Fabric's default model |
| Test strategy | Manual for MVP, automated in future phase |

---

## 11. Glossary

| Term | Definition |
|------|------------|
| **Fabric AI** | CLI tool for AI-powered text processing with 220+ patterns |
| **Pattern** | Predefined AI prompt template for specific transformations |
| **Picker** | UI component for selecting from a list (Telescope/vim.ui.select) |
| **Streaming** | Real-time display of output as it's generated |
| **Action** | User operation on processed output (replace, yank, etc.) |

---

## 12. References

- [Fabric AI GitHub](https://github.com/danielmiessler/fabric)
- [Neovim API Documentation](https://neovim.io/doc/user/api.html)
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-best-practices-plugin-template](https://github.com/ColinKennedy/nvim-best-practices-plugin-template)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-12 | AI Assistant | Initial PRD based on requirements gathering |
