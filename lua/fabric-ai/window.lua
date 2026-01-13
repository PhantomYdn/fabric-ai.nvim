---@class FabricAI.Window
---
--- Floating window management for displaying Fabric AI output.
--- Handles window creation, content updates, and cleanup.
local M = {}

local config = require "fabric-ai.config"

---@class FabricAI.WindowState
---@field win_id number? Window ID
---@field buf_id number? Buffer ID
---@field pattern_name string? Current pattern name (for title)
---@field is_processing boolean Whether processing is in progress

---@type FabricAI.WindowState
M._state = {
  win_id = nil,
  buf_id = nil,
  pattern_name = nil,
  is_processing = false,
}

---Calculate window dimensions based on config
---@return { width: number, height: number, row: number, col: number }
local function calculate_dimensions()
  local win_config = config.get "window"
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  local width = math.floor(editor_width * win_config.width)
  local height = math.floor(editor_height * win_config.height)

  -- Center the window
  local row = math.floor((editor_height - height) / 2)
  local col = math.floor((editor_width - width) / 2)

  return {
    width = width,
    height = height,
    row = row,
    col = col,
  }
end

---Create the window title with pattern name
---@param pattern_name? string
---@return string
local function make_title(pattern_name)
  if pattern_name then
    return " Fabric AI: " .. pattern_name .. " "
  end
  return " Fabric AI "
end

---Open the floating window
---@param opts? { pattern_name?: string }
---@return { win_id: number, buf_id: number }?
---@return string? error
function M.open(opts)
  opts = opts or {}

  -- Close existing window if open
  if M.is_open() then
    M.close()
  end

  local win_config = config.get "window"
  local dims = calculate_dimensions()

  -- Create buffer
  local buf_id = vim.api.nvim_create_buf(false, true)
  if buf_id == 0 then
    return nil, "Failed to create buffer"
  end

  -- Set buffer options
  vim.bo[buf_id].buftype = "nofile"
  vim.bo[buf_id].bufhidden = "wipe"
  vim.bo[buf_id].swapfile = false
  vim.bo[buf_id].filetype = "markdown"

  -- Create window
  -- Footer shows processing indicator initially; will be updated when processing completes
  local win_id = vim.api.nvim_open_win(buf_id, true, {
    relative = "editor",
    width = dims.width,
    height = dims.height,
    row = dims.row,
    col = dims.col,
    style = "minimal",
    border = win_config.border,
    title = make_title(opts.pattern_name),
    title_pos = "center",
    footer = " Processing... [q]uit to cancel ",
    footer_pos = "center",
  })

  if win_id == 0 then
    vim.api.nvim_buf_delete(buf_id, { force = true })
    return nil, "Failed to create window"
  end

  -- Set window options
  vim.wo[win_id].wrap = true
  vim.wo[win_id].linebreak = true
  vim.wo[win_id].cursorline = false
  vim.wo[win_id].number = false
  vim.wo[win_id].relativenumber = false
  vim.wo[win_id].signcolumn = "no"

  -- Store state
  M._state = {
    win_id = win_id,
    buf_id = buf_id,
    pattern_name = opts.pattern_name,
    is_processing = true,
  }

  -- Set initial content
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { "Processing..." })

  return { win_id = win_id, buf_id = buf_id }, nil
end

---Close the floating window
function M.close()
  if M._state.win_id and vim.api.nvim_win_is_valid(M._state.win_id) then
    vim.api.nvim_win_close(M._state.win_id, true)
  end

  -- Buffer is wiped automatically due to bufhidden=wipe
  M._state = {
    win_id = nil,
    buf_id = nil,
    pattern_name = nil,
    is_processing = false,
  }
end

---Check if window is open and valid
---@return boolean
function M.is_open()
  return M._state.win_id ~= nil and vim.api.nvim_win_is_valid(M._state.win_id)
end

---Append text to the buffer (streaming support)
---@param text string Text to append (may contain newlines)
function M.append_text(text)
  if not M.is_open() then
    return
  end

  local buf_id = M._state.buf_id
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  -- Make buffer modifiable temporarily
  vim.bo[buf_id].modifiable = true

  -- Get current line count
  local line_count = vim.api.nvim_buf_line_count(buf_id)

  -- Get the last line content
  local last_line = vim.api.nvim_buf_get_lines(buf_id, line_count - 1, line_count, false)[1] or ""

  -- Check if this is the initial "Processing..." message
  if last_line == "Processing..." then
    -- Replace it with the new content
    local lines = vim.split(text, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  else
    -- Split the incoming text into lines
    local new_lines = vim.split(text, "\n", { plain = true })

    if #new_lines > 0 then
      -- Append first part to the last existing line
      local updated_last_line = last_line .. new_lines[1]
      vim.api.nvim_buf_set_lines(buf_id, line_count - 1, line_count, false, { updated_last_line })

      -- Append remaining lines if any
      if #new_lines > 1 then
        local remaining_lines = { unpack(new_lines, 2) }
        vim.api.nvim_buf_set_lines(buf_id, -1, -1, false, remaining_lines)
      end
    end
  end

  -- Make buffer non-modifiable again during processing
  if M._state.is_processing then
    vim.bo[buf_id].modifiable = false
  end

  -- Auto-scroll to bottom
  M.scroll_to_bottom()
end

---Set the entire buffer content (replaces everything)
---@param lines string[] Lines to set
function M.set_content(lines)
  if not M.is_open() then
    return
  end

  local buf_id = M._state.buf_id
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  vim.bo[buf_id].modifiable = true
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

  if M._state.is_processing then
    vim.bo[buf_id].modifiable = false
  end
end

---Scroll the window to the bottom
function M.scroll_to_bottom()
  if not M.is_open() then
    return
  end

  local win_id = M._state.win_id
  local buf_id = M._state.buf_id

  if not win_id or not buf_id then
    return
  end

  if not vim.api.nvim_win_is_valid(win_id) or not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(buf_id)
  vim.api.nvim_win_set_cursor(win_id, { line_count, 0 })
end

---Mark processing as complete (makes buffer readable)
function M.processing_complete()
  M._state.is_processing = false

  if M._state.buf_id and vim.api.nvim_buf_is_valid(M._state.buf_id) then
    -- Keep buffer non-modifiable but allow reading
    vim.bo[M._state.buf_id].modifiable = false
  end
end

---Get the current buffer content as lines
---@return string[]?
function M.get_content()
  if not M._state.buf_id or not vim.api.nvim_buf_is_valid(M._state.buf_id) then
    return nil
  end

  return vim.api.nvim_buf_get_lines(M._state.buf_id, 0, -1, false)
end

---Get the current buffer content as a single string
---@return string?
function M.get_content_string()
  local lines = M.get_content()
  if not lines then
    return nil
  end
  return table.concat(lines, "\n")
end

---Update the window title
---@param title string
function M.set_title(title)
  if not M.is_open() then
    return
  end

  vim.api.nvim_win_set_config(M._state.win_id, {
    title = " " .. title .. " ",
    title_pos = "center",
  })
end

---Get the footer text based on available actions
---@param replace_available boolean Whether replace action is available
---@return string
local function get_footer_text(replace_available)
  if replace_available then
    return " [r]eplace [y]ank [n]ew buffer [q]uit "
  else
    return " [y]ank [n]ew buffer [q]uit "
  end
end

---Update the window footer based on available actions
---@param replace_available boolean Whether replace action is available
function M.update_footer(replace_available)
  if not M.is_open() then
    return
  end

  vim.api.nvim_win_set_config(M._state.win_id, {
    footer = get_footer_text(replace_available),
    footer_pos = "center",
  })
end

---Get current window state
---@return FabricAI.WindowState
function M.get_state()
  return vim.deepcopy(M._state)
end

---Get buffer ID
---@return number?
function M.get_buf_id()
  return M._state.buf_id
end

---Get window ID
---@return number?
function M.get_win_id()
  return M._state.win_id
end

return M
