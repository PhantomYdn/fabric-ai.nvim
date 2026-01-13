# AI Agent Guidelines: fabric-ai.nvim

This document provides guidelines for AI coding agents (Claude, Cursor, Copilot, etc.) working on this repository.

---

## AI Workflow Rules

1. **Ask before assuming** - Gather requirements in chunks of 1-5 questions; reach 9/10 confidence before implementing
2. **Read docs first** - Always read `PRD_v1.md`, `PLAN_v1.md`, and relevant external docs (Fabric, Neovim API) before making changes
3. **Keep PLAN_v1.md current** - Mark tasks complete/in-progress as you work; this is the source of truth for progress
4. **Keep all docs up-to-date** - When technical details change, immediately update affected documentation
5. **Commit after completing** - Always commit changes when a logical unit of work is done
6. **Present options clearly** - Use A/B/C format for tradeoffs; let user decide
7. **Start simple** - Choose easier/OOB solutions for MVP; enhance later
8. **Prefer built-ins** - Use Neovim native features over external dependencies when possible
9. **Track progress visibly** - Use todo lists for multi-step work; update `PLAN_v1.md`; keep user informed
10. **Preserve milestone checkpoints** - Only mark individual step items complete in PLAN_v1.md, NOT milestone checkpoint items - those are for user manual testing
11. **Offer commits at milestones** - After completing a milestone implementation, ask user if they want to commit before proceeding
12. **Document key decisions** - When making implementation choices (caching strategy, error handling, etc.), add them to the "Milestone X Decisions" table in PLAN_v1.md
13. **Document testing as you go** - When implementing features, add corresponding test cases to `TESTING.md`. Write tests BEFORE or DURING implementation, not after.
14. **Sync PRD and PLAN future features** - When adding future feature ideas: add to PRD first (what/why in 2-4 bullets), then PLAN (how: implementation checklist). Keep feature names and order consistent between documents. Phase/priority planning happens separately.

---

## Project Overview

**fabric-ai.nvim** is a Neovim plugin that integrates Fabric AI's 220+ text processing patterns directly into the editor.

**Tech Stack:**
- Language: Lua 5.1 (Neovim embedded)
- Target: Neovim 0.10.0+
- External Dependency: Fabric AI CLI (`fabric-ai`)

---

## Key Documents

| Document | Purpose |
|----------|---------|
| `PRD_v1.md` | **What** to build: product requirements, milestones, feature descriptions |
| `PLAN_v1.md` | **How** to build: step-by-step implementation checklists, technical details |
| `IDEA.md` | Original idea and problem statement |
| `README.md` | User-facing documentation |
| `TESTING.md` | Manual testing procedures and test cases |

**PRD vs PLAN relationship:**
- PRD defines features (what & why) - 2-4 bullet points per feature
- PLAN defines implementation (how) - detailed task checklists per feature
- Feature names and order must match between documents
- When adding new features: PRD first, then PLAN

---

## Code Style

### Formatting
- Use **StyLua** for formatting
- Config: `.stylua.toml` in repo root
- Run `stylua lua/` before committing

### Naming Conventions
- **Files**: `snake_case.lua`
- **Functions**: `snake_case`
- **Local variables**: `snake_case`
- **Module tables**: `PascalCase` (e.g., `local M = {}`)
- **Constants**: `SCREAMING_SNAKE_CASE`

### Module Pattern
```lua
---@class FabricAI.ModuleName
local M = {}

-- Private functions (not in M)
local function private_helper()
end

-- Public functions
function M.public_function()
end

return M
```

### LuaCATS Annotations
**Always add type annotations for:**
- Function parameters and returns
- Module tables
- Configuration options
- Complex data structures

```lua
---@param pattern string The pattern name to execute
---@param input string Text to process
---@param opts? { timeout?: number } Optional settings
---@return string? output, string? error
function M.run_pattern(pattern, input, opts)
end
```

---

## Architecture Guidelines

### Module Responsibilities

| Module | Responsibility |
|--------|---------------|
| `init.lua` | Public API, setup(), module coordination |
| `config.lua` | Configuration management, defaults, validation |
| `commands.lua` | Vim command definitions, argument parsing |
| `picker.lua` | Pattern picker (Telescope + vim.ui.select) |
| `processor.lua` | Fabric CLI execution, streaming |
| `window.lua` | Floating window management |
| `url.lua` | URL detection and classification |
| `patterns.lua` | Pattern discovery, reading system.md |
| `actions.lua` | Output actions (replace, yank, etc.) |
| `health.lua` | :checkhealth integration |

### Key Principles

1. **Single Responsibility**: Each module does one thing well
2. **Lazy Loading**: Defer requires until needed
3. **No Global State**: Use module-local state or pass explicitly
4. **Graceful Degradation**: Work without optional dependencies (Telescope)
5. **User Feedback**: Use `vim.notify()` for all user-facing messages

### Async Pattern
Use `vim.system()` for async CLI execution:

```lua
vim.system(
  { "fabric-ai", "-p", pattern },
  {
    stdin = input,
    stdout = function(err, data)
      if data then
        -- Handle streaming output
        vim.schedule(function()
          -- Update UI on main thread
        end)
      end
    end,
  },
  function(result)
    -- Completion callback
  end
)
```

---

## Testing Guidelines

### Manual Testing (MVP)
Test these scenarios:
1. Plugin loads without errors
2. `:checkhealth fabric-ai` passes
3. `:Fabric` with visual selection works
4. `:Fabric url` with URL under cursor works
5. All output actions (r, y, n, q) work
6. Fallback to vim.ui.select without Telescope
7. Error handling (no Fabric CLI, timeout, etc.)

### Future: Automated Testing
- Framework: busted
- Location: `spec/` directory
- Naming: `*_spec.lua`

---

## Commit Guidelines

### Commit Message Format
```
type(scope): description

[optional body]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code change that neither fixes nor adds
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(picker): add Telescope integration with preview
fix(processor): handle timeout for long-running patterns
docs(readme): add installation instructions
```

### Commit Scope
Use module names: `config`, `picker`, `processor`, `window`, `url`, `patterns`, `actions`, `health`, `commands`

---

## Common Patterns

### Error Handling

**Log Level Guidelines:**
- `vim.log.levels.ERROR` - System errors (failed to create window, CLI crash)
- `vim.log.levels.WARN` - User errors (no selection, invalid input)
- `vim.log.levels.INFO` - Success messages, hints

```lua
-- User error (recoverable, user's fault)
if not input_text then
  vim.notify("fabric-ai: No text selected", vim.log.levels.WARN)
  vim.notify("fabric-ai: Select text in visual mode, then run :Fabric", vim.log.levels.INFO)
  return
end

-- System error (unexpected failure)
local ok, result = pcall(function()
  -- risky operation
end)

if not ok then
  vim.notify("fabric-ai: " .. result, vim.log.levels.ERROR)
  return
end

-- Always check buffer/window validity before operations
if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
  return  -- Silently return, resource no longer exists
end
```

### Optional Dependency Check
```lua
local has_telescope, telescope = pcall(require, "telescope")
if has_telescope then
  -- Use Telescope
else
  -- Fallback to vim.ui.select
end
```

### Floating Window
```lua
local buf = vim.api.nvim_create_buf(false, true)
local win = vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = math.floor(vim.o.columns * 0.8),
  height = math.floor(vim.o.lines * 0.8),
  row = math.floor(vim.o.lines * 0.1),
  col = math.floor(vim.o.columns * 0.1),
  style = "minimal",
  border = "rounded",
  title = " Fabric AI ",
  title_pos = "center",
})
```

### Buffer-Local Keymaps
```lua
vim.keymap.set("n", "q", function()
  vim.api.nvim_win_close(win, true)
end, { buffer = buf, desc = "Close window" })
```

---

## What NOT to Do

1. **Don't use global variables** - Use module-local or pass state
2. **Don't block the UI** - Always use async for CLI calls
3. **Don't assume Telescope** - Always have vim.ui.select fallback
4. **Don't hardcode paths** - Use `vim.fn.expand()` and config
5. **Don't ignore errors** - Always handle and notify user
6. **Don't skip annotations** - LuaCATS for all public APIs
7. **Don't create files outside the spec** - Follow PRD structure

---

## Useful Neovim APIs

### Buffer Operations
```lua
vim.api.nvim_buf_get_lines(buf, start, end_, strict)
vim.api.nvim_buf_set_lines(buf, start, end_, strict, lines)
vim.api.nvim_buf_set_option(buf, name, value)
```

### Window Operations
```lua
vim.api.nvim_open_win(buf, enter, config)
vim.api.nvim_win_close(win, force)
vim.api.nvim_win_set_cursor(win, {row, col})
```

### Visual Selection
```lua
local start_pos = vim.fn.getpos("'<")
local end_pos = vim.fn.getpos("'>")
local lines = vim.fn.getline(start_pos[2], end_pos[2])
```

### Notifications
```lua
vim.notify("Message", vim.log.levels.INFO)  -- INFO, WARN, ERROR
```

### Async Execution (0.10+)
```lua
vim.system(cmd, opts, on_exit)
```

---

## Questions?

If unclear about implementation:
1. Check `PRD_v1.md` for requirements
2. Check `PLAN_v1.md` for task breakdown
3. Follow patterns in existing modules
4. Ask the user for clarification

---

## Fabric CLI Reference

**Pattern Discovery:**
- `fabric-ai -l` - Lists all patterns, one per line (includes custom patterns)
- Output format: plain text, one pattern name per line

**Pattern Structure:**
- Location: `~/.config/fabric/patterns/{pattern_name}/`
- Files: `system.md` (required), `user.md` (optional)
- Custom patterns are stored in the same directory

**Execution:**
- `fabric-ai -p <pattern>` - Run pattern with stdin input
- `fabric-ai -y <url>` - Process YouTube URL (transcript extraction)
- `fabric-ai -u <url>` - Process generic URL (web page content)
- `fabric-ai --version` - Get CLI version
- `fabric-ai -U` - Update/download patterns

**Config Location:**
- Fabric config: `~/.config/fabric/`
- API keys stored in: `~/.config/fabric/.env` (NEVER read or expose this file)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-12 | Initial guidelines |
| 1.1 | 2026-01-12 | Added rules 10-12 (checkpoints, commits, decisions); Added Fabric CLI Reference |
| 1.2 | 2026-01-12 | Added rule 13 (document testing); Added TESTING.md to Key Documents |
| 1.3 | 2026-01-13 | Added rule 14 (sync PRD/PLAN future features); Clarified PRD vs PLAN relationship in Key Documents |
