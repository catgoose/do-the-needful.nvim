local const = require("do-the-needful.constants").val
local utils = require("do-the-needful.utils")
local sf = string.format

---@class Config
---@field get_opts fun(): Opts
---@field init fun(opts: Opts): Opts
---@return Config
Config = {}

local _opts = const.opts

function Config.get_opts()
	return utils.deep_copy(_opts)
end

local validate_config_order = function(config_order)
	local valid = true
	if not vim.tbl_islist(config_order) then
		return not valid
	end
	for _, c in pairs(config_order) do
		if c ~= "project" and c ~= "global" and c ~= "opts" then
			valid = false
			break
		end
	end
	return valid
end

local set_opts_defaults = function(opts)
	opts.priority = ("project" or "global") and opts.priority or "project"
	opts.config_order = validate_config_order(opts.config_order) and opts.config_order or _opts.config_order
	if #opts.config_order < 3 then
		opts.config_order = vim.tbl_extend("keep", opts.config_order, _opts.config_order)
	end
	return opts
end

local set_local_opts = function(opts)
	_opts.log_level = vim.tbl_contains(const.log_levels, opts.log_level) and opts.log_level or const.default_log_level
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

function Config.init(opts)
	opts = opts or {}
	opts = set_opts_defaults(opts)
	set_local_opts(opts)
	return Config.get_opts()
end

return Config
