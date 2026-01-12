---@class FabricAI.Config.Window
---@field width number Window width as fraction of editor (0.0-1.0)
---@field height number Window height as fraction of editor (0.0-1.0)
---@field border string Border style for floating window

---@class FabricAI.Config
---@field fabric_path string Path to Fabric CLI executable
---@field patterns_path? string Custom patterns directory (nil = auto-detect)
---@field window FabricAI.Config.Window Floating window settings
---@field timeout number Command timeout in milliseconds
---@field default_action string Default output action ("window", "replace", "yank", "new")

---@class FabricAI.Config.User
---@field fabric_path? string
---@field patterns_path? string
---@field window? FabricAI.Config.Window
---@field timeout? number
---@field default_action? string

---@class FabricAI.ConfigModule
---@field _config FabricAI.Config
---@field _initialized boolean
local M = {}

---@type FabricAI.Config
local DEFAULT_CONFIG = {
  fabric_path = "fabric-ai",
  patterns_path = nil,
  window = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
  timeout = 120000,
  default_action = "window",
}

---@type FabricAI.Config
M._config = vim.deepcopy(DEFAULT_CONFIG)
M._initialized = false

---@type table<string, string>
local VALID_ACTIONS = {
  window = "window",
  replace = "replace",
  yank = "yank",
  new = "new",
}

---@type table<string, boolean>
local VALID_BORDERS = {
  none = true,
  single = true,
  double = true,
  rounded = true,
  solid = true,
  shadow = true,
}

---Validate configuration options and warn on invalid values
---@param opts FabricAI.Config.User
---@return FabricAI.Config.User validated options with invalid values removed
local function validate_opts(opts)
  local validated = vim.deepcopy(opts)

  -- Validate fabric_path (string)
  if validated.fabric_path ~= nil and type(validated.fabric_path) ~= "string" then
    vim.notify("fabric-ai: config.fabric_path must be a string, using default", vim.log.levels.WARN)
    validated.fabric_path = nil
  end

  -- Validate patterns_path (string or nil)
  if validated.patterns_path ~= nil and type(validated.patterns_path) ~= "string" then
    vim.notify("fabric-ai: config.patterns_path must be a string or nil, using default", vim.log.levels.WARN)
    validated.patterns_path = nil
  end

  -- Validate timeout (positive number)
  if validated.timeout ~= nil then
    if type(validated.timeout) ~= "number" or validated.timeout <= 0 then
      vim.notify("fabric-ai: config.timeout must be a positive number, using default", vim.log.levels.WARN)
      validated.timeout = nil
    end
  end

  -- Validate default_action
  if validated.default_action ~= nil then
    if not VALID_ACTIONS[validated.default_action] then
      vim.notify(
        string.format(
          "fabric-ai: config.default_action '%s' is invalid, must be one of: window, replace, yank, new",
          validated.default_action
        ),
        vim.log.levels.WARN
      )
      validated.default_action = nil
    end
  end

  -- Validate window options
  if validated.window ~= nil then
    if type(validated.window) ~= "table" then
      vim.notify("fabric-ai: config.window must be a table, using default", vim.log.levels.WARN)
      validated.window = nil
    else
      -- Validate window.width
      if validated.window.width ~= nil then
        if type(validated.window.width) ~= "number" or validated.window.width <= 0 or validated.window.width > 1 then
          vim.notify("fabric-ai: config.window.width must be between 0 and 1, using default", vim.log.levels.WARN)
          validated.window.width = nil
        end
      end

      -- Validate window.height
      if validated.window.height ~= nil then
        if type(validated.window.height) ~= "number" or validated.window.height <= 0 or validated.window.height > 1 then
          vim.notify("fabric-ai: config.window.height must be between 0 and 1, using default", vim.log.levels.WARN)
          validated.window.height = nil
        end
      end

      -- Validate window.border
      if validated.window.border ~= nil then
        if type(validated.window.border) ~= "string" and type(validated.window.border) ~= "table" then
          vim.notify("fabric-ai: config.window.border must be a string or table, using default", vim.log.levels.WARN)
          validated.window.border = nil
        elseif type(validated.window.border) == "string" and not VALID_BORDERS[validated.window.border] then
          vim.notify(
            string.format("fabric-ai: config.window.border '%s' is invalid, using default", validated.window.border),
            vim.log.levels.WARN
          )
          validated.window.border = nil
        end
      end
    end
  end

  return validated
end

---Deep merge two tables
---@param base table
---@param override table
---@return table
local function deep_merge(base, override)
  local result = vim.deepcopy(base)
  for k, v in pairs(override) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = deep_merge(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

---Initialize configuration with user options
---@param opts? FabricAI.Config.User
function M.setup(opts)
  opts = opts or {}

  -- Validate and filter invalid options
  local validated = validate_opts(opts)

  -- Merge with defaults
  M._config = deep_merge(DEFAULT_CONFIG, validated)
  M._initialized = true
end

---Get configuration value
---@param key? string Optional key to get specific value (supports dot notation: "window.width")
---@return any
function M.get(key)
  if not M._initialized then
    M.setup()
  end

  if key == nil then
    return vim.deepcopy(M._config)
  end

  -- Support dot notation for nested keys
  local value = M._config
  for part in string.gmatch(key, "[^.]+") do
    if type(value) ~= "table" then
      return nil
    end
    value = value[part]
  end

  return value
end

---Get the resolved patterns path
---@return string
function M.get_patterns_path()
  if not M._initialized then
    M.setup()
  end

  if M._config.patterns_path then
    return vim.fn.expand(M._config.patterns_path)
  end

  -- Default to ~/.config/fabric/patterns/
  return vim.fn.expand "~/.config/fabric/patterns"
end

---Check if configuration has been initialized
---@return boolean
function M.is_initialized()
  return M._initialized
end

---Reset configuration to defaults (mainly for testing)
function M.reset()
  M._config = vim.deepcopy(DEFAULT_CONFIG)
  M._initialized = false
end

return M
