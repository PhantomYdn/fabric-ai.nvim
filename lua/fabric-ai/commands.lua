---@class FabricAI.Commands
---
--- Command implementations for fabric-ai.nvim.
--- Handles the `:Fabric` command and its subcommands.
local M = {}

local selection = require "fabric-ai.selection"
local window = require "fabric-ai.window"
local processor = require "fabric-ai.processor"
local picker = require "fabric-ai.picker"
local url_module = require "fabric-ai.url"

---Set up keybindings during processing (cancel/quit only)
---@param buf_id number Buffer ID
local function setup_processing_keymaps(buf_id)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  local keymap_opts = { buffer = buf_id, noremap = true, silent = true }

  local function cancel_and_close()
    processor.cancel()
    window.append_text "\n\n[Cancelled]"
    -- Small delay to show the message before closing
    vim.defer_fn(function()
      window.close()
      selection.clear_range()
    end, 100)
  end

  -- q closes/cancels
  vim.keymap.set("n", "q", cancel_and_close, vim.tbl_extend("force", keymap_opts, { desc = "Cancel and close" }))

  -- Escape also closes/cancels
  vim.keymap.set("n", "<Esc>", cancel_and_close, vim.tbl_extend("force", keymap_opts, { desc = "Cancel and close" }))

  -- Ctrl-C also closes/cancels
  vim.keymap.set("n", "<C-c>", cancel_and_close, vim.tbl_extend("force", keymap_opts, { desc = "Cancel and close" }))
end

---Prompt user for input text when no selection/range is provided
---@param callback fun(text: string?) Called with input text, or nil if cancelled
function M._prompt_for_input(callback)
  vim.ui.input({ prompt = "Ask Fabric: " }, function(input)
    if input and input ~= "" then
      callback(input)
    else
      callback(nil)
    end
  end)
end

---Execute the Fabric workflow with given input text
---@param input_text string The text to process
---@param pattern string The pattern to run
local function execute_fabric(input_text, pattern)
  -- Open floating window
  local win_result, win_err = window.open { pattern_name = pattern }
  if not win_result then
    vim.notify("fabric-ai: " .. (win_err or "Failed to open window"), vim.log.levels.ERROR)
    return
  end

  -- Set up cancel keymaps during processing
  setup_processing_keymaps(win_result.buf_id)

  -- Execute with streaming
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
end

---Run the main Fabric workflow with input text and pattern picker
---@param input_text string The text to process
local function run_with_input(input_text)
  picker.pick_pattern(function(pattern)
    if not pattern then
      -- User cancelled picker, clear any stored range
      selection.clear_range()
      return
    end

    execute_fabric(input_text, pattern)
  end)
end

---Run the main Fabric workflow: capture selection -> pick pattern -> execute -> display
---This is the handler for `:Fabric` and `:Fabric run`
---
---Supports three input modes:
---1. Visual selection: Select text, then `:Fabric` or `:'<,'>Fabric`
---2. Range selection: `:%Fabric` (whole file), `:5,10Fabric` (lines 5-10)
---3. Prompt input: `:Fabric` without selection shows input prompt
---
---@param opts table Command options from nvim_create_user_command
function M.run(opts)
  local input_text, err

  if opts.range == 0 then
    -- Case 1: No range provided -> show input prompt
    -- Clear any stale selection range (fixes bug where old visual marks were used)
    selection.clear_range()

    M._prompt_for_input(function(text)
      if not text then
        -- User cancelled or empty input
        return
      end

      -- No selection range stored = replace action won't be available
      run_with_input(text)
    end)
    return
  end

  -- Case 2 & 3: Range provided (visual selection or explicit range like :%Fabric)
  -- Use opts.line1 and opts.line2 which work for both cases
  input_text, err = selection.get_range_text(opts.line1, opts.line2)

  if not input_text then
    vim.notify("fabric-ai: " .. (err or "Failed to get text"), vim.log.levels.WARN)
    return
  end

  run_with_input(input_text)
end

---Set up keybindings in the output window for actions
---These are implemented in Milestone 4, but we set up the basic structure here
function M._setup_window_keymaps()
  local buf_id = window.get_buf_id()
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  local keymap_opts = { buffer = buf_id, noremap = true, silent = true }
  local has_range = selection.has_range()

  -- Update window footer to reflect available actions
  window.update_footer(has_range)

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

  -- Ctrl-C also closes (processing already complete)
  vim.keymap.set("n", "<C-c>", function()
    window.close()
    selection.clear_range()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Close window" }))

  -- Replace selection (r) - only available if there's a selection to replace
  if has_range then
    vim.keymap.set("n", "r", function()
      M._action_replace()
    end, vim.tbl_extend("force", keymap_opts, { desc = "Replace selection with output" }))
  end

  -- Yank to clipboard (y)
  vim.keymap.set("n", "y", function()
    M._action_yank()
  end, vim.tbl_extend("force", keymap_opts, { desc = "Yank output to clipboard" }))

  -- New buffer (n)
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

---Run the URL processing workflow: detect URL -> pick pattern -> execute -> display
---This is the handler for `:Fabric url`
---@param opts table Command options from nvim_create_user_command
function M.url(opts)
  -- Step 1: Get URL under cursor
  local url_result, err = url_module.get_url_under_cursor()

  if not url_result then
    vim.notify("fabric-ai: " .. (err or "No URL found"), vim.log.levels.WARN)
    vim.notify("fabric-ai: Place cursor on a URL, then run :Fabric url", vim.log.levels.INFO)
    return
  end

  local url = url_result.url
  local url_type = url_module.get_url_type(url)

  -- Step 2: Store the URL position as a selection range for replacement
  selection.store_range {
    start_row = url_result.row,
    start_col = url_result.start_col,
    end_row = url_result.row, -- URLs are single-line
    end_col = url_result.end_col,
    mode = "v", -- Character-wise replacement
    bufnr = url_result.bufnr,
  }

  -- Step 3: Open pattern picker
  picker.pick_pattern(function(pattern)
    if not pattern then
      -- User cancelled picker
      selection.clear_range()
      return
    end

    -- Step 4: Open floating window
    local win_result, win_err = window.open { pattern_name = pattern }
    if not win_result then
      vim.notify("fabric-ai: " .. (win_err or "Failed to open window"), vim.log.levels.ERROR)
      selection.clear_range()
      return
    end

    -- Step 4.5: Set up cancel keymaps during processing
    setup_processing_keymaps(win_result.buf_id)

    -- Step 5: Execute with streaming
    processor.run_url(url, url_type, pattern, {
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

---Run health check (wrapper for checkhealth)
function M.health()
  vim.cmd "checkhealth fabric-ai"
end

return M
