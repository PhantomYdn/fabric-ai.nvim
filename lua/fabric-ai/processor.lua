---@class FabricAI.Processor
---
--- Handles Fabric CLI detection, execution, and pattern management.
---
--- SECURITY NOTE: Fabric stores API keys in ~/.config/fabric/.env
--- This module should NEVER read, log, or expose the contents of that file.
--- Health checks only verify directory existence, not file contents.
local M = {}

local config = require "fabric-ai.config"

---@type vim.SystemObj?
M._current_job = nil

---Check if Fabric CLI is available and executable
---@return boolean available
---@return string? error_message
function M.is_available()
  local fabric_path = config.get "fabric_path"

  -- Check if command exists
  if vim.fn.executable(fabric_path) ~= 1 then
    return false,
      string.format("Fabric CLI '%s' not found. Please install Fabric AI or configure fabric_path.", fabric_path)
  end

  return true, nil
end

---Get Fabric CLI version
---@return string? version
---@return string? error_message
function M.get_version()
  local available, err = M.is_available()
  if not available then
    return nil, err
  end

  local fabric_path = config.get "fabric_path"
  local result = vim.system({ fabric_path, "--version" }, { text = true }):wait()

  if result.code ~= 0 then
    return nil, "Failed to get Fabric version: " .. (result.stderr or "unknown error")
  end

  local version = vim.trim(result.stdout or "")
  if version == "" then
    return nil, "Fabric returned empty version"
  end

  return version, nil
end

---Count available patterns in the patterns directory
---@return number count
---@return string? error_message
function M.count_patterns()
  local patterns_path = config.get_patterns_path()

  if vim.fn.isdirectory(patterns_path) ~= 1 then
    return 0, string.format("Patterns directory not found: %s", patterns_path)
  end

  -- Count directories in patterns path (each pattern is a directory)
  local handle = vim.loop.fs_scandir(patterns_path)
  if not handle then
    return 0, "Failed to read patterns directory"
  end

  local count = 0
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == "directory" then
      count = count + 1
    end
  end

  return count, nil
end

---Check if patterns directory exists
---@return boolean exists
---@return string? error_message
function M.patterns_dir_exists()
  local patterns_path = config.get_patterns_path()

  if vim.fn.isdirectory(patterns_path) ~= 1 then
    return false, string.format("Patterns directory not found: %s", patterns_path)
  end

  return true, nil
end

---Execute a Fabric command asynchronously (basic, non-streaming)
---This is a placeholder that will be enhanced with streaming in Milestone 3
---@param args string[] Command arguments (e.g., {"-p", "summarize"})
---@param input? string Text to send to stdin
---@param on_complete fun(result: {code: number, stdout: string, stderr: string})
function M.execute(args, input, on_complete)
  local available, err = M.is_available()
  if not available then
    vim.schedule(function()
      on_complete { code = 1, stdout = "", stderr = err or "Fabric CLI not available" }
    end)
    return
  end

  local fabric_path = config.get "fabric_path"
  local cmd = { fabric_path }
  vim.list_extend(cmd, args)

  local opts = {
    text = true,
    timeout = config.get "timeout",
  }

  if input then
    opts.stdin = input
  end

  M._current_job = vim.system(cmd, opts, function(result)
    vim.schedule(function()
      M._current_job = nil
      on_complete {
        code = result.code,
        stdout = result.stdout or "",
        stderr = result.stderr or "",
      }
    end)
  end)
end

---Cancel any running Fabric command
function M.cancel()
  if M._current_job then
    M._current_job:kill(9) -- SIGKILL
    M._current_job = nil
  end
end

---Check if a command is currently running
---@return boolean
function M.is_running()
  return M._current_job ~= nil
end

return M
