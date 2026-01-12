---@class FabricAI.Url
---
--- URL detection and classification for fabric-ai.nvim.
--- Handles extracting URLs from cursor position and determining URL type (YouTube vs generic).
local M = {}

---@class FabricAI.UrlResult
---@field url string The detected URL
---@field start_col number 1-indexed start column in line
---@field end_col number 1-indexed end column in line
---@field row number 1-indexed line number
---@field bufnr number Buffer number

--- YouTube URL patterns (case-insensitive matching)
local YOUTUBE_PATTERNS = {
  "youtube%.com/watch",
  "youtube%.com/playlist",
  "youtube%.com/shorts/",
  "youtube%.com/live/",
  "youtu%.be/",
}

---Extract a URL from a string, handling common wrapping characters
---@param text string The text to search for a URL
---@return string? url The extracted URL, or nil if not found
local function extract_url_from_text(text)
  if not text or text == "" then
    return nil
  end

  -- Try to match URL with protocol
  local url = text:match "https?://[%w%-%./_~:?#%[%]@!$&'()*+,;=%%]+"

  if url then
    -- Clean up trailing punctuation that's likely not part of the URL
    url = url:gsub("[,;:%.%)%]>\"']+$", "")
    return url
  end

  -- Try to match www. prefixed URL without protocol
  local www_url = text:match "www%.[%w%-%./_~:?#%[%]@!$&'()*+,;=%%]+"
  if www_url then
    www_url = www_url:gsub("[,;:%.%)%]>\"']+$", "")
    return "https://" .. www_url
  end

  return nil
end

---Get the URL under the cursor with its position
---@return FabricAI.UrlResult? result URL result with position info
---@return string? error Error message if no URL found
function M.get_url_under_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2] + 1 -- Convert 0-indexed to 1-indexed

  -- Get the current line
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
  if not line or line == "" then
    return nil, "No URL found under cursor"
  end

  -- Strategy: Find all URLs in the line and check if cursor is within one
  -- This handles cases where the URL might be wrapped in parentheses, quotes, etc.

  -- Pattern to find URLs (protocol required or www. prefix)
  -- Note: string.find returns (start, end, capture1, capture2, ...)
  local patterns = {
    "(https?://[%w%-%./_~:?#%[%]@!$&'()*+,;=%%]+)",
    "(www%.[%w%-%./_~:?#%[%]@!$&'()*+,;=%%]+)",
  }

  for _, pattern in ipairs(patterns) do
    local search_start = 1
    while true do
      local match_start, match_end, url_match = line:find(pattern, search_start)
      if not match_start then
        break
      end

      -- Clean up the URL (remove trailing punctuation)
      local clean_url = url_match:gsub("[,;:%.%)%]>\"']+$", "")
      local clean_end = match_start + #clean_url - 1

      -- Check if cursor is within this URL
      if col >= match_start and col <= clean_end then
        -- Found it!
        local final_url = clean_url
        if not final_url:match "^https?://" then
          final_url = "https://" .. final_url
        end

        return {
          url = final_url,
          start_col = match_start,
          end_col = clean_end,
          row = row,
          bufnr = bufnr,
        },
          nil
      end

      search_start = match_end + 1
    end
  end

  -- Fallback: Try getting the WORD under cursor and extract URL from it
  local cword = vim.fn.expand "<cWORD>"
  local extracted = extract_url_from_text(cword)

  if extracted then
    -- Find the position of this URL in the line
    local word_start = line:find(vim.pesc(cword), 1, true)
    if word_start then
      -- Find URL within the word
      local url_in_word = cword:find(extracted:gsub("^https://", ""), 1, true) or cword:find(extracted, 1, true) or 1
      local start_col = word_start + url_in_word - 1

      -- Calculate end based on the extracted URL length
      local display_url = extracted:match "^https?://(.+)" or extracted
      local end_col = start_col + #display_url - 1

      -- Adjust if we added https://
      if not cword:match "^https?://" and extracted:match "^https://" then
        -- The original didn't have protocol, find the www. or domain start
        local orig_match = cword:match "www%.[%w%-%./_~:?#%[%]@!$&'()*+,;=%%]+"
          or cword:match "[%w%-]+%.[%w]+[%w%-%./_~:?#%[%]@!$&'()*+,;=%%]*"
        if orig_match then
          orig_match = orig_match:gsub("[,;:%.%)%]>\"']+$", "")
          end_col = word_start + #orig_match - 1
        end
      end

      return {
        url = extracted,
        start_col = word_start,
        end_col = end_col,
        row = row,
        bufnr = bufnr,
      },
        nil
    end
  end

  return nil, "No URL found under cursor"
end

---Check if a URL is a YouTube URL
---@param url string The URL to check
---@return boolean is_youtube True if this is a YouTube URL
function M.is_youtube_url(url)
  if not url then
    return false
  end

  local lower_url = url:lower()

  for _, pattern in ipairs(YOUTUBE_PATTERNS) do
    if lower_url:find(pattern) then
      return true
    end
  end

  return false
end

---Get the type of a URL
---@param url string The URL to classify
---@return "youtube" | "generic" url_type The URL type
function M.get_url_type(url)
  if M.is_youtube_url(url) then
    return "youtube"
  end
  return "generic"
end

return M
