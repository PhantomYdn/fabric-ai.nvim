-- Prevent double-loading
if vim.g.loaded_fabric_ai then
  return
end
vim.g.loaded_fabric_ai = true

-- Placeholder: commands will be implemented in Milestone 1
vim.api.nvim_create_user_command("Fabric", function(opts)
  require("fabric-ai").setup()
  vim.notify("fabric-ai: Command implementation coming in Milestone 1", vim.log.levels.INFO)
end, {
  nargs = "*",
  range = true,
  desc = "Run Fabric AI patterns on text",
})
