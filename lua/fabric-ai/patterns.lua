---@class FabricAI.Patterns
---
--- Pattern discovery and metadata retrieval.
--- Handles listing patterns via Fabric CLI and reading pattern system prompts.
local M = {}

local config = require "fabric-ai.config"

---Parse pattern list output from Fabric CLI
---@param output string Raw stdout from `fabric-ai -l`
---@return string[] patterns List of pattern names
local function parse_pattern_list(output)
  local patterns = {}
  for line in output:gmatch "[^\r\n]+" do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      table.insert(patterns, trimmed)
    end
  end
  return patterns
end

---List all available patterns asynchronously
---@param callback fun(patterns: string[], err?: string) Called with pattern list or error
function M.list(callback)
  local fabric_path = config.get "fabric_path"

  -- Check if CLI is available
  if vim.fn.executable(fabric_path) ~= 1 then
    vim.schedule(function()
      callback({}, string.format("Fabric CLI '%s' not found", fabric_path))
    end)
    return
  end

  vim.system({ fabric_path, "-l" }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        callback({}, "Failed to list patterns: " .. (result.stderr or "unknown error"))
        return
      end

      local patterns = parse_pattern_list(result.stdout or "")
      callback(patterns, nil)
    end)
  end)
end

---List all available patterns synchronously
---@return string[] patterns List of pattern names
---@return string? error_message
function M.list_sync()
  local fabric_path = config.get "fabric_path"

  -- Check if CLI is available
  if vim.fn.executable(fabric_path) ~= 1 then
    return {}, string.format("Fabric CLI '%s' not found", fabric_path)
  end

  local result = vim.system({ fabric_path, "-l" }, { text = true }):wait()

  if result.code ~= 0 then
    return {}, "Failed to list patterns: " .. (result.stderr or "unknown error")
  end

  local patterns = parse_pattern_list(result.stdout or "")
  return patterns, nil
end

---Get the full path to a pattern directory
---@param name string Pattern name
---@return string path Full path to pattern directory
function M.get_pattern_path(name)
  local patterns_path = config.get_patterns_path()
  return patterns_path .. "/" .. name
end

---Check if a pattern exists
---@param name string Pattern name
---@return boolean exists
function M.exists(name)
  local pattern_path = M.get_pattern_path(name)
  return vim.fn.isdirectory(pattern_path) == 1
end

---Read the system prompt (system.md) for a pattern
---@param name string Pattern name
---@return string? content System prompt content, or nil if not found
---@return string? error_message
function M.get_system_prompt(name)
  local pattern_path = M.get_pattern_path(name)
  local system_md_path = pattern_path .. "/system.md"

  -- Check if file exists
  if vim.fn.filereadable(system_md_path) ~= 1 then
    return nil, string.format("system.md not found for pattern '%s'", name)
  end

  -- Read file contents
  local lines = vim.fn.readfile(system_md_path)
  if not lines or #lines == 0 then
    return nil, string.format("system.md is empty for pattern '%s'", name)
  end

  return table.concat(lines, "\n"), nil
end

---Read the user prompt (user.md) for a pattern
---@param name string Pattern name
---@return string? content User prompt content, or nil if not found
function M.get_user_prompt(name)
  local pattern_path = M.get_pattern_path(name)
  local user_md_path = pattern_path .. "/user.md"

  -- Check if file exists
  if vim.fn.filereadable(user_md_path) ~= 1 then
    return nil
  end

  -- Read file contents
  local lines = vim.fn.readfile(user_md_path)
  if not lines or #lines == 0 then
    return nil
  end

  return table.concat(lines, "\n")
end

return M
