---@class FabricAI.Picker
---
--- Pattern picker interface with Telescope support and vim.ui.select fallback.
--- Provides a unified API for pattern selection regardless of available dependencies.
local M = {}

local patterns = require "fabric-ai.patterns"

---Check if Telescope is available
---@return boolean
local function has_telescope()
  local ok, _ = pcall(require, "telescope")
  return ok
end

---Show pattern picker using Telescope
---@param pattern_list string[] List of pattern names
---@param on_select fun(pattern: string?) Callback with selected pattern or nil
local function telescope_picker(pattern_list, on_select)
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local previewers = require "telescope.previewers"

  -- Create previewer that shows system.md content
  local pattern_previewer = previewers.new_buffer_previewer {
    title = "Pattern System Prompt",

    define_preview = function(self, entry, _status)
      local pattern_name = entry.value
      local content, err = patterns.get_system_prompt(pattern_name)

      if content then
        -- Split content into lines and set buffer
        local lines = vim.split(content, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        -- Set filetype for syntax highlighting
        vim.bo[self.state.bufnr].filetype = "markdown"
      else
        -- Show error message if system.md not found
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
          "No system prompt available",
          "",
          err or "system.md not found",
        })
      end
    end,
  }

  pickers
    .new({}, {
      prompt_title = "Fabric Patterns",
      finder = finders.new_table {
        results = pattern_list,
        entry_maker = function(pattern_name)
          return {
            value = pattern_name,
            display = pattern_name,
            ordinal = pattern_name,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = pattern_previewer,
      attach_mappings = function(prompt_bufnr, _map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            on_select(selection.value)
          else
            on_select(nil)
          end
        end)
        return true
      end,
    })
    :find()
end

---Show pattern picker using vim.ui.select fallback
---@param pattern_list string[] List of pattern names
---@param on_select fun(pattern: string?) Callback with selected pattern or nil
local function fallback_picker(pattern_list, on_select)
  vim.ui.select(pattern_list, {
    prompt = "Select Fabric Pattern:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    on_select(choice) -- choice is nil if user cancelled
  end)
end

---Pick a pattern using the best available picker
---Shows Telescope if available, otherwise falls back to vim.ui.select
---@param on_select fun(pattern: string?) Callback with selected pattern name, or nil if cancelled/error
function M.pick_pattern(on_select)
  -- Fetch patterns asynchronously
  patterns.list(function(pattern_list, err)
    if err then
      vim.notify("fabric-ai: " .. err, vim.log.levels.ERROR)
      on_select(nil)
      return
    end

    if #pattern_list == 0 then
      vim.notify("fabric-ai: No patterns found. Run 'fabric-ai -U' to download patterns.", vim.log.levels.ERROR)
      on_select(nil)
      return
    end

    -- Use Telescope if available, otherwise fallback
    if has_telescope() then
      telescope_picker(pattern_list, on_select)
    else
      fallback_picker(pattern_list, on_select)
    end
  end)
end

---Check if Telescope is available (exposed for testing/info)
---@return boolean
function M.has_telescope()
  return has_telescope()
end

return M
