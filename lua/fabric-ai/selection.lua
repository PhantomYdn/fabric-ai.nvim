---@class FabricAI.Selection
---
--- Handles visual selection capture and storage for later replacement.
--- Supports all visual modes: character-wise (v), line-wise (V), and block-wise (<C-v>).
local M = {}

---@class FabricAI.SelectionRange
---@field start_row number 1-indexed start line
---@field start_col number 1-indexed start column
---@field end_row number 1-indexed end line
---@field end_col number 1-indexed end column
---@field mode string Visual mode: 'v', 'V', or '\22' (block)
---@field bufnr number Buffer number where selection was made

---@type FabricAI.SelectionRange?
M._last_range = nil

---Get the current visual selection text
---Must be called while in visual mode or immediately after (before marks are cleared)
---@return string? text The selected text as a single string
---@return string? error Error message if selection failed
function M.get_visual_text()
  local range, err = M.get_visual_range()
  if not range then
    return nil, err
  end

  local lines = M._get_lines_from_range(range)
  if not lines or #lines == 0 then
    return nil, "No text in selection"
  end

  return table.concat(lines, "\n"), nil
end

---Get the visual selection range (positions)
---Stores the range for later use (e.g., replacement)
---@return FabricAI.SelectionRange? range
---@return string? error
function M.get_visual_range()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get visual selection marks
  -- Note: In command mode (after :), '< and '> contain the last visual selection
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  -- getpos returns {bufnum, lnum, col, off}
  local start_row = start_pos[2]
  local start_col = start_pos[3]
  local end_row = end_pos[2]
  local end_col = end_pos[3]

  -- Validate positions
  if start_row == 0 or end_row == 0 then
    return nil, "No visual selection found"
  end

  -- Get the visual mode from the last visual selection
  -- vim.fn.visualmode() returns the mode of the last visual selection
  local mode = vim.fn.visualmode()
  if mode == "" then
    mode = "v" -- Default to character-wise
  end

  ---@type FabricAI.SelectionRange
  local range = {
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col,
    mode = mode,
    bufnr = bufnr,
  }

  -- Store for later use
  M._last_range = range

  return range, nil
end

---Get lines from a selection range
---@param range FabricAI.SelectionRange
---@return string[]? lines
function M._get_lines_from_range(range)
  local bufnr = range.bufnr
  local mode = range.mode

  -- Get buffer lines (0-indexed for nvim_buf_get_lines)
  local lines = vim.api.nvim_buf_get_lines(bufnr, range.start_row - 1, range.end_row, false)

  if #lines == 0 then
    return nil
  end

  if mode == "V" then
    -- Line-wise: return complete lines as-is
    return lines
  elseif mode == "v" then
    -- Character-wise: trim first and last lines
    if #lines == 1 then
      -- Single line selection
      lines[1] = string.sub(lines[1], range.start_col, range.end_col)
    else
      -- Multi-line selection
      lines[1] = string.sub(lines[1], range.start_col)
      lines[#lines] = string.sub(lines[#lines], 1, range.end_col)
    end
    return lines
  elseif mode == "\22" or mode == "^V" then
    -- Block-wise (Ctrl-V): extract columns from each line
    local result = {}
    local col_start = math.min(range.start_col, range.end_col)
    local col_end = math.max(range.start_col, range.end_col)

    for _, line in ipairs(lines) do
      local extracted = string.sub(line, col_start, col_end)
      table.insert(result, extracted)
    end
    return result
  end

  -- Fallback
  return lines
end

---Get the last stored selection range
---@return FabricAI.SelectionRange?
function M.get_last_range()
  return M._last_range
end

---Clear the stored selection range
function M.clear_range()
  M._last_range = nil
end

---Check if there is a stored selection range
---@return boolean
function M.has_range()
  return M._last_range ~= nil
end

---Store a selection range manually (used for URL replacement)
---@param range FabricAI.SelectionRange The range to store
function M.store_range(range)
  M._last_range = range
end

---Get the buffer number from the last selection
---@return number?
function M.get_source_bufnr()
  if M._last_range then
    return M._last_range.bufnr
  end
  return nil
end

-- Future Enhancement Ideas:
-- TODO: Support prompting for input when no selection (vim.ui.input)
-- TODO: Support using current buffer content as input
-- TODO: Support using current line as input
-- TODO: Support using word under cursor as input

return M
