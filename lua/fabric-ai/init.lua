---@class FabricAI
---@field config FabricAI.ConfigModule
---@field processor FabricAI.Processor
---@field health FabricAI.Health
---@field patterns FabricAI.Patterns
---@field picker FabricAI.Picker
---@field selection FabricAI.Selection
---@field window FabricAI.Window
---@field commands FabricAI.Commands
local M = {}

M._VERSION = "0.1.0"

---@type boolean
local _setup_done = false

---Setup fabric-ai.nvim with user configuration
---@param opts? FabricAI.Config.User
function M.setup(opts)
  if _setup_done then
    return
  end

  -- Initialize configuration
  local config = require "fabric-ai.config"
  config.setup(opts)

  -- Check Fabric CLI availability and warn user if not found
  local processor = require "fabric-ai.processor"
  local available, err = processor.is_available()
  if not available then
    vim.notify("fabric-ai: " .. (err or "Fabric CLI not found"), vim.log.levels.WARN)
  end

  _setup_done = true
end

---Get configuration value
---@param key? string Optional key (supports dot notation)
---@return any
function M.get_config(key)
  return require("fabric-ai.config").get(key)
end

---Check if Fabric CLI is available
---@return boolean available
---@return string? error_message
function M.is_available()
  return require("fabric-ai.processor").is_available()
end

---Run health check
function M.health()
  require("fabric-ai.health").check()
end

---Pick a pattern using Telescope or vim.ui.select fallback
---@param on_select fun(pattern: string?) Callback with selected pattern name, or nil if cancelled
function M.pick_pattern(on_select)
  require("fabric-ai.picker").pick_pattern(on_select)
end

---List all available patterns
---@param callback fun(patterns: string[], err?: string) Callback with pattern list
function M.list_patterns(callback)
  require("fabric-ai.patterns").list(callback)
end

---Get the system prompt for a pattern
---@param name string Pattern name
---@return string? content System prompt content
---@return string? error_message
function M.get_pattern_prompt(name)
  return require("fabric-ai.patterns").get_system_prompt(name)
end

---Run the Fabric workflow on visual selection
---This is the main entry point for programmatic use
---@param opts? table Options (currently unused, for future expansion)
function M.run(opts)
  require("fabric-ai.commands").run(opts or {})
end

---Cancel any running Fabric command
function M.cancel()
  require("fabric-ai.processor").cancel()
end

---Check if a Fabric command is currently running
---@return boolean
function M.is_running()
  return require("fabric-ai.processor").is_running()
end

---Close the output window if open
function M.close_window()
  require("fabric-ai.window").close()
end

---Reset plugin state (mainly for testing/development)
function M._reset()
  require("fabric-ai.config").reset()
  require("fabric-ai.selection").clear_range()
  require("fabric-ai.window").close()
  _setup_done = false
end

return M
