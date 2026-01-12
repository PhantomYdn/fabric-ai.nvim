---@class FabricAI.Commands
---
--- Command implementations for fabric-ai.nvim.
--- Handles the `:Fabric` command and its subcommands.
local M = {}

local selection = require "fabric-ai.selection"
local window = require "fabric-ai.window"
local processor = require "fabric-ai.processor"
local picker = require "fabric-ai.picker"

---Run the main Fabric workflow: capture selection -> pick pattern -> execute -> display
---This is the handler for `:Fabric` and `:Fabric run`
---@param opts table Command options from nvim_create_user_command
function M.run(opts)
  -- Step 1: Capture visual selection (if in visual mode)
  local input_text, err = selection.get_visual_text()

  if not input_text then
    vim.notify("fabric-ai: " .. (err or "No text selected"), vim.log.levels.ERROR)
    vim.notify("fabric-ai: Select text in visual mode, then run :Fabric", vim.log.levels.INFO)
    return
  end

  -- Step 2: Open pattern picker
  picker.pick_pattern(function(pattern)
    if not pattern then
      -- User cancelled picker
      return
    end

    -- Step 3: Open floating window
    local win_result, win_err = window.open { pattern_name = pattern }
    if not win_result then
      vim.notify("fabric-ai: " .. (win_err or "Failed to open window"), vim.log.levels.ERROR)
      return
    end

    -- Step 4: Execute with streaming
    processor.run_pattern(pattern, input_text, {
      on_stdout = function(data)
        -- Stream output to window as it arrives
        window.append_text(data)
      end,

      on_stderr = function(data)
        -- Show stderr in the window as well (errors from Fabric)
        window.append_text(data)
      end,

      on_complete = function(code)
        window.processing_complete()

        if code ~= 0 then
          -- Append error indicator (the actual error should already be displayed via stderr)
          window.append_text("\n\n[Process exited with code " .. code .. "]")
        end

        -- Set up action keybindings now that processing is complete
        M._setup_window_keymaps()
      end,
    })
  end)
end

---Set up keybindings in the output window for actions
---These are implemented in Milestone 4, but we set up the basic structure here
function M._setup_window_keymaps()
  local buf_id = window.get_buf_id()
  if not buf_id then
    return
  end

  local keymap_opts = { buffer = buf_id, noremap = true, silent = true }

  -- Close window (q)
  vim.keymap.set("n", "q", function()
    window.close()
    selection.clear_range()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Close window" }))

  -- Escape also closes
  vim.keymap.set("n", "<Esc>", function()
    window.close()
    selection.clear_range()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Close window" }))

  -- Replace selection (r) - Milestone 4 implementation
  vim.keymap.set("n", "r", function()
    M._action_replace()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Replace selection with output" }))

  -- Yank to clipboard (y) - Milestone 4 implementation
  vim.keymap.set("n", "y", function()
    M._action_yank()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Yank output to clipboard" }))

  -- New buffer (n) - Milestone 4 implementation
  vim.keymap.set("n", "n", function()
    M._action_new_buffer()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Open output in new buffer" }))
end

---Action: Replace original selection with output
---Full implementation in Milestone 4
function M._action_replace()
  local range = selection.get_last_range()
  if not range then
    vim.notify("fabric-ai: No selection range stored", vim.log.levels.ERROR)
    return
  end

  local content = window.get_content()
  if not content then
    vim.notify("fabric-ai: No output content", vim.log.levels.ERROR)
    return
  end

  -- Get the source buffer
  local source_bufnr = range.bufnr
  if not vim.api.nvim_buf_is_valid(source_bufnr) then
    vim.notify("fabric-ai: Source buffer no longer exists", vim.log.levels.ERROR)
    return
  end

  -- Replace the selection
  -- For line-wise, replace entire lines
  -- For character-wise, we need more careful handling
  if range.mode == "V" then
    -- Line-wise: simple line replacement
    vim.api.nvim_buf_set_lines(source_bufnr, range.start_row - 1, range.end_row, false, content)
  else
    -- Character-wise: use nvim_buf_set_text for precise replacement
    -- Note: end_col needs adjustment for nvim_buf_set_text (exclusive)
    vim.api.nvim_buf_set_text(
      source_bufnr,
      range.start_row - 1,
      range.start_col - 1,
      range.end_row - 1,
      range.end_col,
      content
    )
  end

  -- Close window and clean up
  window.close()
  selection.clear_range()

  vim.notify("fabric-ai: Selection replaced", vim.log.levels.INFO)
end

---Action: Yank output to system clipboard
---Full implementation in Milestone 4
function M._action_yank()
  local content = window.get_content_string()
  if not content then
    vim.notify("fabric-ai: No output content", vim.log.levels.ERROR)
    return
  end

  -- Copy to system clipboard (+ register)
  vim.fn.setreg("+", content)

  -- Also copy to unnamed register for convenience
  vim.fn.setreg('"', content)

  -- Close window and clean up
  window.close()
  selection.clear_range()

  vim.notify("fabric-ai: Output copied to clipboard", vim.log.levels.INFO)
end

---Action: Open output in new buffer
---Full implementation in Milestone 4
function M._action_new_buffer()
  local content = window.get_content()
  if not content then
    vim.notify("fabric-ai: No output content", vim.log.levels.ERROR)
    return
  end

  -- Close the floating window first
  window.close()
  selection.clear_range()

  -- Create new buffer
  local new_buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, content)

  -- Set buffer options
  vim.bo[new_buf].filetype = "markdown"
  vim.bo[new_buf].modified = true

  -- Switch to the new buffer
  vim.api.nvim_set_current_buf(new_buf)

  vim.notify("fabric-ai: Output opened in new buffer", vim.log.levels.INFO)
end

---Run health check (wrapper for checkhealth)
function M.health()
  vim.cmd "checkhealth fabric-ai"
end

return M
