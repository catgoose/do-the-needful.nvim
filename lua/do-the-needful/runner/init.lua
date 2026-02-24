local get_opts = require("do-the-needful.config").get_opts

---@class RunnerProvider
---@field name string
---@field is_available fun(): boolean
---@field run fun(task: TaskConfig)

---@class RunnerRegistry
---@field resolve fun(name?: string): RunnerProvider|nil
---@field run fun(task: TaskConfig)
---@return RunnerRegistry
local M = {}

local providers = {
  tmux = "do-the-needful.runner.tmux",
  zellij = "do-the-needful.runner.zellij",
  toggleterm = "do-the-needful.runner.toggleterm",
  neovim = "do-the-needful.runner.neovim",
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
  local priority = opts.runner_priority
    or { "tmux", "zellij", "toggleterm", "neovim" }
  for _, provider_name in ipairs(priority) do
    local provider = get_provider(provider_name)
    if provider and provider.is_available() then
      return provider
    end
  end
  return nil
end

function M.run(task)
  local runner_name = task.runner
  if not runner_name then
    local opts = get_opts()
    runner_name = opts.runner
  end
  local provider = M.resolve(runner_name)
  if not provider then
    vim.notify("[do-the-needful] No runner available", vim.log.levels.ERROR)
    return
  end
  provider.run(task)
end

return M
