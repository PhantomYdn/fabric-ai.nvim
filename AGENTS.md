# AI Agent Guidelines: fabric-ai.nvim

This document provides guidelines for AI coding agents (Claude, Cursor, Copilot, etc.) working on this repository.

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
| `PRD_v1.md` | Product requirements, milestones, features |
| `PLAN_v1.md` | Step-by-step implementation checklist |
| `IDEA.md` | Original idea and problem statement |
| `README.md` | User-facing documentation |

**Always read `PRD_v1.md` and `PLAN_v1.md` before making changes.**

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
```lua
local ok, result = pcall(function()
  -- risky operation
end)

if not ok then
  vim.notify("fabric-ai: " .. result, vim.log.levels.ERROR)
  return
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

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-12 | Initial guidelines |
