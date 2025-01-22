local const = require("do-the-needful.constants").get()
local utils = require("do-the-needful.utils")
local sf = utils.string_format

---@class Config
---@field get_opts fun(): Opts
---@field init fun(opts: Opts): Opts
---@field telescope_setup fun(opts: TelescopeOpts): TelescopeOpts
---@return Config
local M = {}

local _opts = const.opts
local _telescope_opts = const.telescope_setup

function M.get_opts()
  -- _opts.configs.project.path = sf("%s/%s", vim.fn.getcwd(), _opts.config_file)
  return utils.deep_copy(_opts)
end

function M.get_telescope_opts()
  return utils.deep_copy(_telescope_opts)
end

local function validate_config_order(config_order)
  local valid = true
  local is_list = vim.fn.has("nvim-0.10") == 1 and vim.islist or vim.tbl_islist
  if not is_list(config_order) then
    return not valid
  end
  if #config_order ~= #const.lists.config_order then
    return not valid
  end
  local found = {}
  for _, c in pairs(config_order) do
    if c ~= "project" and c ~= "global" and c ~= "opts" then
      valid = false
      break
    end
    if found[c] then
      valid = false
      break
    end
    found[c] = true
  end
  return valid
end

local function set_opts_defaults(opts)
  opts.config_order = validate_config_order(opts.config_order) and opts.config_order
    or _opts.config_order
  opts.edit_mode = vim.tbl_contains(const.lists.edit_modes, opts.edit_mode) and opts.edit_mode
    or _opts.edit_mode
  if #opts.config_order < 3 then
    opts.config_order = vim.tbl_extend("keep", opts.config_order, _opts.config_order)
  end
  return opts
end

local function set_local_opts(opts)
  _opts.log_level = vim.tbl_contains(const.log_levels, opts.log_level) and opts.log_level
    or const.default_log_level
  _opts = vim.tbl_deep_extend("keep", opts, _opts)
  _opts.configs = {
    global = {
      path = sf("%s/%s", vim.fn.stdpath("data"), _opts.config_file),
      tasks = {},
    },
    project = {
      path = sf("%s/%s", vim.fn.getcwd(), _opts.config_file),
      tasks = {},
    },
    opts = {
      tasks = utils.deep_copy(_opts.tasks) or {},
    },
  }
  _opts.tasks = nil
end

function M.init(opts)
  opts = opts or {}
  opts = set_opts_defaults(opts)
  set_local_opts(opts)
  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    pattern = "global",
    callback = function()
      _opts.configs.project.path = sf("%s/%s", vim.fn.getcwd(), _opts.config_file)
    end,
  })
  return M.get_opts()
end

function M.telescope_setup(opts)
  opts = opts or {}
  _telescope_opts = opts
  return _telescope_opts
end

return M
