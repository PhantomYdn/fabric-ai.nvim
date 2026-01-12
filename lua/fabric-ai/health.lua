---@class FabricAI.Health
local M = {}

local config = require "fabric-ai.config"
local processor = require "fabric-ai.processor"

---Run health checks for :checkhealth fabric-ai
function M.check()
  vim.health.start "fabric-ai.nvim"

  -- Check 1: Neovim version
  M._check_neovim_version()

  -- Check 2: Fabric CLI availability
  M._check_fabric_cli()

  -- Check 3: Patterns directory
  M._check_patterns()
end

---Check Neovim version >= 0.10.0
function M._check_neovim_version()
  local version = vim.version()
  local version_str = string.format("%d.%d.%d", version.major, version.minor, version.patch)

  if version.major > 0 or (version.major == 0 and version.minor >= 10) then
    vim.health.ok("Neovim version: " .. version_str)
  else
    vim.health.error(
      "Neovim version " .. version_str .. " is too old",
      { "fabric-ai.nvim requires Neovim 0.10.0 or later", "Please upgrade Neovim" }
    )
  end
end

---Check Fabric CLI availability and version
function M._check_fabric_cli()
  local fabric_path = config.get "fabric_path"

  -- Check if CLI exists
  local available, err = processor.is_available()
  if not available then
    vim.health.error("Fabric CLI not found: " .. fabric_path, {
      "Install Fabric AI: https://github.com/danielmiessler/fabric",
      "Or configure a custom path: require('fabric-ai').setup({ fabric_path = '/path/to/fabric-ai' })",
    })
    return
  end

  vim.health.ok("Fabric CLI found: " .. fabric_path)

  -- Check version
  local version, version_err = processor.get_version()
  if version then
    vim.health.info("Fabric CLI version: " .. version)
  else
    vim.health.warn("Could not determine Fabric CLI version", {
      version_err or "Unknown error",
    })
  end
end

---Check patterns directory and count patterns
function M._check_patterns()
  local patterns_path = config.get_patterns_path()

  -- Check if directory exists
  local exists, err = processor.patterns_dir_exists()
  if not exists then
    vim.health.error("Patterns directory not found: " .. patterns_path, {
      "Run 'fabric-ai -U' to download patterns",
      "Or configure a custom path: require('fabric-ai').setup({ patterns_path = '/path/to/patterns' })",
    })
    return
  end

  vim.health.ok("Patterns directory found: " .. patterns_path)

  -- Count patterns
  local count, count_err = processor.count_patterns()
  if count > 0 then
    vim.health.info(string.format("Available patterns: %d", count))
  elseif count == 0 and not count_err then
    vim.health.warn("No patterns found in directory", {
      "Run 'fabric-ai -U' to download patterns",
    })
  else
    vim.health.warn("Could not count patterns", {
      count_err or "Unknown error",
    })
  end
end

return M
