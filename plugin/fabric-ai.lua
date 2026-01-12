-- Prevent double-loading
if vim.g.loaded_fabric_ai then
  return
end
vim.g.loaded_fabric_ai = true

-- Check Neovim version
if vim.fn.has "nvim-0.10.0" ~= 1 then
  vim.notify("fabric-ai.nvim requires Neovim 0.10.0 or later", vim.log.levels.ERROR)
  return
end

-- Subcommand definitions
---@type table<string, fun(opts: table)>
local subcommands = {
  -- Run pattern on text (default command)
  run = function(_opts)
    require("fabric-ai").pick_pattern(function(pattern)
      if pattern then
        -- Milestone 2: Notify selection (actual processing added in Milestone 3)
        vim.notify(
          "fabric-ai: Selected pattern '" .. pattern .. "' (processing coming in Milestone 3)",
          vim.log.levels.INFO
        )
      end
    end)
  end,

  -- Health check subcommand (works even when lazy-loaded)
  health = function(_)
    vim.cmd "checkhealth fabric-ai"
  end,
}

---@type string[]
local subcommand_names = vim.tbl_keys(subcommands)

-- Create the :Fabric command
vim.api.nvim_create_user_command("Fabric", function(opts)
  -- Ensure plugin is set up
  require("fabric-ai").setup()

  local args = opts.fargs
  local subcommand = args[1]

  -- No subcommand - default to 'run'
  if not subcommand then
    subcommands.run(opts)
    return
  end

  -- Check for valid subcommand
  local handler = subcommands[subcommand]
  if handler then
    handler(opts)
  else
    vim.notify(string.format("fabric-ai: Unknown subcommand '%s'", subcommand), vim.log.levels.ERROR)
  end
end, {
  nargs = "*",
  range = true,
  desc = "Run Fabric AI patterns on text",
  complete = function(arg_lead, cmd_line, cursor_pos)
    -- Simple completion for subcommands
    local matches = {}
    for _, name in ipairs(subcommand_names) do
      if name:find("^" .. arg_lead) then
        table.insert(matches, name)
      end
    end
    return matches
  end,
})
