# Implementation Plan: fabric-ai.nvim MVP

## Overview

This document provides a step-by-step implementation plan for fabric-ai.nvim MVP.
Use this for tracking progress during development.

**Target:** Milestones 1-6 from PRD_v1.md
**Estimated Effort:** ~40-60 hours

---

## Pre-Implementation Setup

### Step 0.1: Project Initialization
- [ ] Initialize git repository
- [ ] Create basic directory structure
- [ ] Add LICENSE (MIT)
- [ ] Add .gitignore
- [ ] Add .stylua.toml

### Step 0.2: Development Environment
- [ ] Set up Neovim with plugin loading from local path
- [ ] Install StyLua for formatting
- [ ] Configure LSP for Lua (lua_ls)

---

## Milestone 1: Core Infrastructure

### Step 1.1: Plugin Entry Point
**File:** `plugin/fabric-ai.lua`
- [ ] Create plugin guard (prevent double-loading)
- [ ] Define `:Fabric` command with subcommand parsing
- [ ] Set up lazy-loading triggers

**File:** `lua/fabric-ai/init.lua`
- [ ] Create `setup()` function
- [ ] Export public API
- [ ] Initialize modules on first use

### Step 1.2: Configuration System
**File:** `lua/fabric-ai/config.lua`
- [ ] Define default configuration table
- [ ] Create `setup(opts)` to merge user config
- [ ] Add validation for critical options
- [ ] Implement `get()` function for accessing config

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
- [ ] Create function to check if Fabric CLI exists
- [ ] Create function to get Fabric version
- [ ] Create function to execute Fabric commands (basic, non-streaming)
- [ ] Handle command not found errors

### Step 1.4: Health Check
**File:** `lua/fabric-ai/health.lua`
- [ ] Implement `:checkhealth fabric-ai`
- [ ] Check Neovim version (0.10+)
- [ ] Check Fabric CLI availability
- [ ] Check Fabric CLI version
- [ ] Check patterns directory exists

**Milestone 1 Checkpoint:**
- [ ] `:Fabric` command registered
- [ ] `:checkhealth fabric-ai` works
- [ ] Config can be customized

---

## Milestone 2: Pattern System

### Step 2.1: Pattern Discovery
**File:** `lua/fabric-ai/patterns.lua`
- [ ] Create function to run `fabric-ai -l`
- [ ] Parse pattern list output
- [ ] Create function to get pattern directory path
- [ ] Create function to read pattern's `system.md`
- [ ] Support both default and custom pattern paths

### Step 2.2: Telescope Picker
**File:** `lua/fabric-ai/picker.lua`
- [ ] Check if Telescope is available
- [ ] Create Telescope picker for patterns
- [ ] Implement preview showing `system.md` content
- [ ] Handle pattern selection callback
- [ ] Add fuzzy search support

### Step 2.3: Fallback Picker
**File:** `lua/fabric-ai/picker.lua` (continued)
- [ ] Implement vim.ui.select fallback
- [ ] Format pattern names for display
- [ ] Handle selection callback
- [ ] Maintain consistent API with Telescope path

### Step 2.4: Picker Integration
**File:** `lua/fabric-ai/picker.lua` (continued)
- [ ] Create unified `pick_pattern(callback)` function
- [ ] Auto-detect Telescope availability
- [ ] Route to appropriate picker implementation

**Milestone 2 Checkpoint:**
- [ ] Pattern list retrieved successfully
- [ ] Telescope picker shows patterns with preview
- [ ] vim.ui.select works when Telescope unavailable
- [ ] Custom patterns directory supported

---

## Milestone 3: Text Processing

### Step 3.1: Selection Capture
**File:** `lua/fabric-ai/init.lua` or `lua/fabric-ai/selection.lua`
- [ ] Create function to get visual selection text
- [ ] Store selection range for later replacement
- [ ] Handle multi-line selections
- [ ] Handle different visual modes (v, V, Ctrl-V)

### Step 3.2: Floating Window
**File:** `lua/fabric-ai/window.lua`
- [ ] Create floating window with configured dimensions
- [ ] Set up buffer for output
- [ ] Configure window options (wrap, modifiable, etc.)
- [ ] Add border with title
- [ ] Store window/buffer IDs for later access

### Step 3.3: Streaming Execution
**File:** `lua/fabric-ai/processor.lua` (extend)
- [ ] Implement `vim.system()` with streaming stdout
- [ ] Create callback for stdout chunks
- [ ] Update floating window buffer on each chunk
- [ ] Implement auto-scroll to bottom
- [ ] Handle stderr for errors
- [ ] Implement timeout handling

### Step 3.4: Command Integration
**File:** `lua/fabric-ai/commands.lua`
- [ ] Implement `:Fabric` / `:Fabric run` command
- [ ] Capture visual selection
- [ ] Open pattern picker
- [ ] Execute Fabric with selected pattern
- [ ] Stream output to floating window

**Milestone 3 Checkpoint:**
- [ ] Visual selection captured correctly
- [ ] Floating window opens with correct size
- [ ] Streaming output visible in real-time
- [ ] Auto-scroll works during streaming
- [ ] UI remains responsive

---

## Milestone 4: Output Actions

### Step 4.1: Action Keybindings
**File:** `lua/fabric-ai/window.lua` (extend)
- [ ] Set up buffer-local keymaps in output window
- [ ] Implement `r` - replace action
- [ ] Implement `y` - yank action
- [ ] Implement `n` - new buffer action
- [ ] Implement `q` - close action

### Step 4.2: Replace Action
**File:** `lua/fabric-ai/actions.lua`
- [ ] Retrieve stored selection range
- [ ] Get output buffer content
- [ ] Replace selection with output
- [ ] Close floating window
- [ ] Handle edge cases (deleted lines, etc.)

### Step 4.3: Yank Action
**File:** `lua/fabric-ai/actions.lua` (continued)
- [ ] Get output buffer content
- [ ] Copy to system clipboard (`+` register)
- [ ] Show confirmation message
- [ ] Close floating window

### Step 4.4: New Buffer Action
**File:** `lua/fabric-ai/actions.lua` (continued)
- [ ] Get output buffer content
- [ ] Create new buffer
- [ ] Set buffer content
- [ ] Set filetype (markdown by default)
- [ ] Close floating window
- [ ] Focus new buffer

### Step 4.5: Window Footer/Header
**File:** `lua/fabric-ai/window.lua` (extend)
- [ ] Add action hints to window border or footer
- [ ] Format: `[r]eplace [y]ank [n]ew buffer [q]uit`
- [ ] Update title to show pattern name

**Milestone 4 Checkpoint:**
- [ ] All four actions work correctly
- [ ] Action hints visible in window
- [ ] Replace preserves undo history
- [ ] Yank uses system clipboard
- [ ] New buffer has correct filetype

---

## Milestone 5: URL Processing

### Step 5.1: URL Detection
**File:** `lua/fabric-ai/url.lua`
- [ ] Create function to get URL under cursor
- [ ] Implement URL pattern matching
- [ ] Handle URLs with/without protocol
- [ ] Return nil if no URL found

### Step 5.2: YouTube Detection
**File:** `lua/fabric-ai/url.lua` (continued)
- [ ] Create function to detect YouTube URLs
- [ ] Match `youtube.com/watch?v=`
- [ ] Match `youtu.be/`
- [ ] Match YouTube playlist URLs
- [ ] Return boolean for is_youtube

### Step 5.3: URL Command
**File:** `lua/fabric-ai/commands.lua` (extend)
- [ ] Implement `:Fabric url` command
- [ ] Detect URL under cursor
- [ ] Determine URL type (YouTube vs other)
- [ ] Build Fabric command with `-y` or `-u` flag
- [ ] Open pattern picker
- [ ] Execute and stream to window

### Step 5.4: URL Error Handling
**File:** `lua/fabric-ai/url.lua` (continued)
- [ ] Handle no URL under cursor
- [ ] Handle invalid URLs
- [ ] Show appropriate error messages

**Milestone 5 Checkpoint:**
- [ ] URL under cursor detected
- [ ] YouTube URLs use `-y` flag
- [ ] Other URLs use `-u` flag
- [ ] Pattern picker works with URLs
- [ ] Errors handled gracefully

---

## Milestone 6: Polish & Documentation

### Step 6.1: Error Handling Audit
**Files:** All modules
- [ ] Review all error paths
- [ ] Add vim.notify for user-facing errors
- [ ] Ensure no silent failures
- [ ] Add timeout handling
- [ ] Test error scenarios

### Step 6.2: Vimdoc Documentation
**File:** `doc/fabric-ai.txt`
- [ ] Write introduction section
- [ ] Document all commands
- [ ] Document configuration options
- [ ] Document keybindings in output window
- [ ] Add examples section
- [ ] Add troubleshooting section
- [ ] Generate help tags

### Step 6.3: README
**File:** `README.md`
- [ ] Write project description
- [ ] Add feature list
- [ ] Add installation instructions (lazy.nvim)
- [ ] Add configuration examples
- [ ] Add usage examples with screenshots/GIFs
- [ ] Add requirements section
- [ ] Add credits/license

### Step 6.4: Example Configuration
**File:** `README.md` (include in)
- [ ] Create complete lazy.nvim spec
- [ ] Include recommended keybindings
- [ ] Show customization examples

### Step 6.5: Final Testing
- [ ] Test fresh installation
- [ ] Test all commands
- [ ] Test all actions
- [ ] Test with/without Telescope
- [ ] Test on macOS
- [ ] Test error scenarios
- [ ] Test with various patterns

**Milestone 6 Checkpoint:**
- [ ] All errors show user-friendly messages
- [ ] `:help fabric-ai` works
- [ ] README complete and accurate
- [ ] Plugin installable from GitHub

---

## Post-MVP Tracking

### Future Phase Items (Document for Later)

**Phase 2: Enhanced Picker Support**
- [ ] Snacks.nvim picker integration
- [ ] fzf-lua picker integration

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
- [ ] `plugin/fabric-ai.lua`
- [ ] `lua/fabric-ai/init.lua`
- [ ] `lua/fabric-ai/config.lua`
- [ ] `lua/fabric-ai/commands.lua`
- [ ] `lua/fabric-ai/picker.lua`
- [ ] `lua/fabric-ai/processor.lua`
- [ ] `lua/fabric-ai/window.lua`
- [ ] `lua/fabric-ai/url.lua`
- [ ] `lua/fabric-ai/patterns.lua`
- [ ] `lua/fabric-ai/actions.lua`
- [ ] `lua/fabric-ai/health.lua`

### Documentation
- [ ] `doc/fabric-ai.txt`
- [ ] `README.md`
- [ ] `LICENSE`

### Configuration
- [ ] `.stylua.toml`
- [ ] `.gitignore`

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
