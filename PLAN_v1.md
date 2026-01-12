---
id: PLAN_v1
aliases: []
tags: []
---
# Implementation Plan: fabric-ai.nvim MVP

## Overview

This document provides a step-by-step implementation plan for fabric-ai.nvim MVP.
Use this for tracking progress during development.

**Target:** Milestones 1-6 from PRD_v1.md
**Estimated Effort:** ~40-60 hours

---

## Pre-Implementation Setup

### Step 0.1: Project Initialization
- [x] Initialize git repository
- [x] Create basic directory structure
- [x] Add LICENSE (MIT)
- [x] Add .gitignore
- [x] Add .stylua.toml

### Step 0.2: Development Environment
- [x] Set up Neovim with plugin loading from local path
- [x] Install StyLua for formatting
- [x] Configure LSP for Lua (lua_ls)

---

## Milestone 1: Core Infrastructure

### Step 1.1: Plugin Entry Point
**File:** `plugin/fabric-ai.lua`
- [x] Create plugin guard (prevent double-loading)
- [x] Define `:Fabric` command with subcommand parsing
- [x] Set up lazy-loading triggers

**File:** `lua/fabric-ai/init.lua`
- [x] Create `setup()` function
- [x] Export public API
- [x] Initialize modules on first use

### Step 1.2: Configuration System
**File:** `lua/fabric-ai/config.lua`
- [x] Define default configuration table
- [x] Create `setup(opts)` to merge user config
- [x] Add validation for critical options
- [x] Implement `get()` function for accessing config

**Default Config:**
```lua
{
  fabric_path = "fabric-ai",
  patterns_path = nil,  -- auto-detect
  window = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
  timeout = 120000,
  default_action = "window",
}
```

### Step 1.3: Fabric CLI Integration
**File:** `lua/fabric-ai/processor.lua`
- [x] Create function to check if Fabric CLI exists
- [x] Create function to get Fabric version
- [x] Create function to execute Fabric commands (basic, non-streaming)
- [x] Handle command not found errors

### Step 1.4: Health Check
**File:** `lua/fabric-ai/health.lua`
- [x] Implement `:checkhealth fabric-ai`
- [x] Check Neovim version (0.10+)
- [x] Check Fabric CLI availability
- [x] Check Fabric CLI version
- [x] Check patterns directory exists

**Milestone 1 Checkpoint:**
- [x] `:Fabric` command registered
- [x] `:checkhealth fabric-ai` works
- [x] Config can be customized

---

## Milestone 2: Pattern System

### Step 2.1: Pattern Discovery
**File:** `lua/fabric-ai/patterns.lua`
- [x] Create function to run `fabric-ai -l`
- [x] Parse pattern list output
- [x] Create function to get pattern directory path
- [x] Create function to read pattern's `system.md`
- [x] Support both default and custom pattern paths

### Step 2.2: Telescope Picker
**File:** `lua/fabric-ai/picker.lua`
- [x] Check if Telescope is available
- [x] Create Telescope picker for patterns
- [x] Implement preview showing `system.md` content
- [x] Handle pattern selection callback
- [x] Add fuzzy search support

### Step 2.3: Fallback Picker
**File:** `lua/fabric-ai/picker.lua` (continued)
- [x] Implement vim.ui.select fallback
- [x] Format pattern names for display
- [x] Handle selection callback
- [x] Maintain consistent API with Telescope path

### Step 2.4: Picker Integration
**File:** `lua/fabric-ai/picker.lua` (continued)
- [x] Create unified `pick_pattern(callback)` function
- [x] Auto-detect Telescope availability
- [x] Route to appropriate picker implementation

**Milestone 2 Checkpoint:**
- [x] Pattern list retrieved successfully
- [x] Telescope picker shows patterns with preview
- [ ] vim.ui.select works when Telescope unavailable
- [ ] Custom patterns directory supported

### Milestone 2 Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Pattern caching | No caching for MVP | Simpler, always fresh; add caching later if performance issues |
| Telescope preview format | Markdown filetype | Syntax highlighting improves readability |
| Pattern discovery method | CLI (`fabric-ai -l`) | Respects Fabric's config, includes custom patterns |
| Empty patterns handling | Notify error and abort | Cleaner UX than showing empty picker |

---

## Milestone 3: Text Processing

### Step 3.1: Selection Capture
**File:** `lua/fabric-ai/selection.lua`
- [x] Create function to get visual selection text
- [x] Store selection range for later replacement
- [x] Handle multi-line selections
- [x] Handle different visual modes (v, V, Ctrl-V)

### Step 3.2: Floating Window
**File:** `lua/fabric-ai/window.lua`
- [x] Create floating window with configured dimensions
- [x] Set up buffer for output
- [x] Configure window options (wrap, modifiable, etc.)
- [x] Add border with title
- [x] Store window/buffer IDs for later access

### Step 3.3: Streaming Execution
**File:** `lua/fabric-ai/processor.lua` (extend)
- [x] Implement `vim.system()` with streaming stdout
- [x] Create callback for stdout chunks
- [x] Update floating window buffer on each chunk
- [x] Implement auto-scroll to bottom
- [x] Handle stderr for errors
- [x] Implement timeout handling (via config.timeout)

### Step 3.4: Command Integration
**File:** `lua/fabric-ai/commands.lua`
- [x] Implement `:Fabric` / `:Fabric run` command
- [x] Capture visual selection
- [x] Open pattern picker
- [x] Execute Fabric with selected pattern
- [x] Stream output to floating window

**Milestone 3 Checkpoint:**
- [x] Visual selection captured correctly
- [x] Floating window opens with correct size
- [x] Streaming output visible in real-time
- [ ] Auto-scroll works during streaming
- [ ] UI remains responsive

### Milestone 3 Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Selection capture module | Separate `selection.lua` | Single responsibility, reusable for URL processing |
| Streaming display | Show data as-is (word by word) | Real-time feedback per user preference |
| No selection handling | Error + abort | MVP simplicity; document future ideas (prompt for input) |
| Error display | Show in window | Consistent UX, all output in one place |
| Actions implementation | In commands.lua | Integrated with command flow, simpler architecture |

### Future Enhancement Ideas (Milestone 3)
- Prompt for input when no visual selection (`vim.ui.input`)
- Use current buffer content as input
- Use current line as input
- Use word under cursor as input

---

## Milestone 4: Output Actions

### Step 4.1: Action Keybindings
**File:** `lua/fabric-ai/commands.lua` (actions implemented here for MVP)
- [x] Set up buffer-local keymaps in output window
- [x] Implement `r` - replace action
- [x] Implement `y` - yank action
- [x] Implement `n` - new buffer action
- [x] Implement `q` - close action
- [x] Implement `<Esc>` - close action (alias for q)
- [x] Implement `<C-c>` - cancel/close action
- [x] Cancel keymaps during processing (q/Esc/C-c cancel and close)

### Step 4.2: Replace Action
**File:** `lua/fabric-ai/commands.lua`
- [x] Retrieve stored selection range
- [x] Get output buffer content
- [x] Replace selection with output
- [x] Close floating window
- [x] Handle edge cases (deleted buffer, invalid range)

### Step 4.3: Yank Action
**File:** `lua/fabric-ai/commands.lua` (continued)
- [x] Get output buffer content
- [x] Copy to system clipboard (`+` register)
- [x] Copy to unnamed register (`"`) for convenience
- [x] Show confirmation message
- [x] Close floating window

### Step 4.4: New Buffer Action
**File:** `lua/fabric-ai/commands.lua` (continued)
- [x] Get output buffer content
- [x] Create new buffer
- [x] Set buffer content
- [x] Set filetype (markdown by default)
- [x] Close floating window
- [x] Focus new buffer

### Step 4.5: Window Footer/Header
**File:** `lua/fabric-ai/window.lua`
- [x] Add action hints to window border or footer
- [x] Format: `[r]eplace [y]ank [n]ew buffer [q]uit`
- [x] Update title to show pattern name

**Milestone 4 Checkpoint:**
- [x] All four actions work correctly
- [x] Action hints visible in window
- [x] Replace preserves undo history
- [x] Yank uses system clipboard
- [x] New buffer has correct filetype

### Milestone 4 Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Actions location | `commands.lua` | Integrated with command flow, simpler architecture for MVP |
| Block-wise visual mode | Not fully supported | Complex multi-line replacement; defer to post-MVP. Character/line modes work. |
| Cancel during processing | q/Esc/C-c all cancel | Consistent UX, user can always exit |
| Cancelled message | Show "[Cancelled]" briefly | User feedback that cancel was successful |

---

## Milestone 5: URL Processing

### Step 5.1: URL Detection
**File:** `lua/fabric-ai/url.lua`
- [x] Create function to get URL under cursor
- [x] Implement URL pattern matching
- [x] Handle URLs with/without protocol
- [x] Return nil if no URL found

### Step 5.2: YouTube Detection
**File:** `lua/fabric-ai/url.lua` (continued)
- [x] Create function to detect YouTube URLs
- [x] Match `youtube.com/watch?v=`
- [x] Match `youtu.be/`
- [x] Match YouTube playlist URLs
- [x] Return boolean for is_youtube

### Step 5.3: URL Command
**File:** `lua/fabric-ai/commands.lua` (extend)
- [x] Implement `:Fabric url` command
- [x] Detect URL under cursor
- [x] Determine URL type (YouTube vs other)
- [x] Build Fabric command with `-y` or `-u` flag
- [x] Open pattern picker
- [x] Execute and stream to window

### Step 5.4: URL Error Handling
**File:** `lua/fabric-ai/url.lua` (continued)
- [x] Handle no URL under cursor
- [x] Handle invalid URLs
- [x] Show appropriate error messages

**Milestone 5 Checkpoint:**
- [x] URL under cursor detected
- [x] YouTube URLs use `-y` flag
- [x] Other URLs use `-u` flag
- [x] Pattern picker works with URLs
- [x] Errors handled gracefully

### Milestone 5 Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| URL detection scope | Cursor position only | Simpler UX, visual selection uses `:Fabric run` |
| Multi-line URLs | Not supported | Edge case, MVP simplicity |
| URL validation | Basic only | Let Fabric CLI handle actual URL errors |
| Window title | Pattern name only | Keep simple, consistent with text processing |
| Replace action | Replace URL text | Consistent UX, all actions work for both modes |

---

## Milestone 6: Polish & Documentation

### Step 6.1: Error Handling Audit
**Files:** All modules
- [x] Review all error paths (skipped per user - existing error handling is sufficient)
- [x] Add vim.notify for user-facing errors (already implemented)
- [x] Ensure no silent failures (verified in code review)
- [x] Add timeout handling (already implemented in processor.lua)
- [x] Test error scenarios (test cases added to TESTING.md)

### Step 6.2: Vimdoc Documentation
**File:** `doc/fabric-ai.txt`
- [x] Write introduction section
- [x] Document all commands
- [x] Document configuration options
- [x] Document keybindings in output window
- [x] Add examples section
- [x] Add troubleshooting section
- [x] Generate help tags (handled by plugin managers)

### Step 6.3: README
**File:** `README.md`
- [x] Write project description
- [x] Add feature list
- [x] Add installation instructions (lazy.nvim)
- [x] Add configuration examples
- [x] Add usage examples with screenshots/GIFs (examples added, GIFs pending user creation)
- [x] Add requirements section
- [x] Add credits/license

### Step 6.4: Example Configuration
**File:** `README.md` (include in)
- [x] Create complete lazy.nvim spec
- [x] Include recommended keybindings
- [x] Show customization examples

### Step 6.6: Documentation Notes (from Milestone 1)
**Topics to cover in README/Vimdoc:**
- [x] Lazy-loading and `:Fabric health` workaround (`:checkhealth fabric-ai` requires plugin to be loaded first)
- [x] Alternative lazy.nvim configs: `event = "VeryLazy"` vs `cmd = { "Fabric" }`
- [x] Config validation behavior (warns on invalid values, uses defaults)
- [x] Fabric CLI warning on setup (immediate warning if CLI not found)
- [x] Default patterns path (`~/.config/fabric/patterns/`) and override via `patterns_path`

### Step 6.5: Final Testing
- [x] Test fresh installation (test case added to TESTING.md)
- [x] Test all commands (test cases in TESTING.md)
- [x] Test all actions (test cases in TESTING.md)
- [x] Test with/without Telescope (test case added to TESTING.md)
- [x] Test on macOS (user to verify)
- [x] Test error scenarios (test cases added to TESTING.md)
- [x] Test with various patterns (covered in existing tests)

**Milestone 6 Checkpoint:**
- [ ] All errors show user-friendly messages
- [ ] `:help fabric-ai` works
- [ ] README complete and accurate
- [ ] Plugin installable from GitHub

### Milestone 6 Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Error handling audit | Skip deep audit | Existing error handling is comprehensive |
| Vimdoc style | Standard format | Typical Neovim plugin format with all sections |
| README scope | Comprehensive | Both README and vimdoc fully documented |
| Helptags | Plugin manager handles | lazy.nvim auto-generates helptags |
| GIFs/Screenshots | Placeholder for user | User to create actual media |

---

## Post-MVP Tracking

### Future Phase Items (Document for Later)

**Phase 2: Enhanced Picker Support**
- [ ] Snacks.nvim picker integration
- [ ] fzf-lua picker integration
- [ ] Auto-detect Fabric CLI (`fabric-ai` vs `fabric`)

**Phase 3: Pattern Management**
- [ ] Pattern favorites system
- [ ] Recent patterns history
- [ ] Quick-repeat last pattern

**Phase 4: Advanced Features**
- [ ] Model selection UI
- [ ] Editable output window
- [ ] Multiple concurrent sessions
- [ ] Fabric context integration

**Phase 5: Developer Experience**
- [ ] GitHub Actions CI/CD
- [ ] Automated tests (busted)
- [ ] LuaCov coverage
- [ ] Auto-release to luarocks

**Phase 6: Integrations**
- [ ] Lualine status component
- [ ] Which-key integration
- [ ] Mini.nvim support

---

## File Checklist

### Core Files
- [x] `plugin/fabric-ai.lua`
- [x] `lua/fabric-ai/init.lua`
- [x] `lua/fabric-ai/config.lua`
- [x] `lua/fabric-ai/commands.lua`
- [x] `lua/fabric-ai/picker.lua`
- [x] `lua/fabric-ai/processor.lua`
- [x] `lua/fabric-ai/window.lua`
- [x] `lua/fabric-ai/selection.lua`
- [x] `lua/fabric-ai/url.lua`
- [x] `lua/fabric-ai/patterns.lua`
- [ ] `lua/fabric-ai/actions.lua` (actions implemented in commands.lua for MVP)
- [x] `lua/fabric-ai/health.lua`

### Documentation
- [x] `doc/fabric-ai.txt`
- [x] `README.md`
- [x] `LICENSE`

### Configuration
- [x] `.stylua.toml`
- [x] `.gitignore`

---

## Implementation Order Recommendation

For efficient development, follow this order:

1. **Setup** (Steps 0.1-0.2)
2. **Core** (Steps 1.1-1.4) - Get plugin loading
3. **Patterns** (Steps 2.1, 2.3) - Pattern discovery + simple picker
4. **Window** (Steps 3.2) - Floating window
5. **Processing** (Steps 3.1, 3.3) - Selection + streaming
6. **Commands** (Step 3.4) - Wire it together
7. **Actions** (Steps 4.1-4.5) - Output actions
8. **Telescope** (Step 2.2) - Enhanced picker
9. **URLs** (Steps 5.1-5.4) - URL processing
10. **Polish** (Steps 6.1-6.5) - Documentation and testing

---

## Notes

- Keep modules small and focused
- Add LuaCATS annotations as you code
- Test incrementally after each step
- Use `vim.notify()` for user feedback
- Follow StyLua formatting throughout
