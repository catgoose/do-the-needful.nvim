local get_opts = require("do-the-needful.config").get_opts

---@class PickerProvider
---@field name string
---@field is_available fun(): boolean
---@field pick_task fun(tasks: TaskConfig[], on_select: fun(task: TaskConfig), opts?: table)
---@field pick_action fun(actions: table[], on_select: fun(action: table), opts?: table)

---@class PickerRegistry
---@field resolve fun(name?: string): PickerProvider|nil
---@field pick_task fun(tasks: TaskConfig[], on_select: fun(task: TaskConfig), opts?: table)
---@field pick_action fun(actions: table[], on_select: fun(action: table), opts?: table)
---@return PickerRegistry
local M = {}

local providers = {
  telescope = "do-the-needful.picker.telescope",
  fzf_lua = "do-the-needful.picker.fzf_lua",
  snacks = "do-the-needful.picker.snacks",
  ui_select = "do-the-needful.picker.ui_select",
}

local function get_provider(name)
  local mod_path = providers[name]
  if not mod_path then
    return nil
  end
  local ok, provider = pcall(require, mod_path)
  if ok then
    return provider
  end
  return nil
end

function M.resolve(name)
  if name and name ~= "auto" then
    local provider = get_provider(name)
    if provider and provider.is_available() then
      return provider
    end
    return nil
  end
  local opts = get_opts()
  local priority = opts.picker_priority
    or { "telescope", "fzf_lua", "snacks", "ui_select" }
  for _, provider_name in ipairs(priority) do
    local provider = get_provider(provider_name)
    if provider and provider.is_available() then
      return provider
    end
  end
  return nil
end

function M.pick_task(tasks, on_select, opts)
  local config = get_opts()
  local provider = M.resolve(config.picker)
  if not provider then
    vim.notify("[do-the-needful] No picker available", vim.log.levels.ERROR)
    return
  end
  provider.pick_task(tasks, on_select, opts)
end

function M.pick_action(actions, on_select, opts)
  local config = get_opts()
  local provider = M.resolve(config.picker)
  if not provider then
    vim.notify("[do-the-needful] No picker available", vim.log.levels.ERROR)
    return
  end
  provider.pick_action(actions, on_select, opts)
end

return M
