local const = require("do-the-needful.constants").val
local utils = require("do-the-needful.utils")

Config = {}

local _opts = const.opts

function Config.opts()
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
	--  TODO: 2024-02-27 - handle tasks defined from setup opts
	opts.priority = ("project" or "global") and opts.priority or "project"
	opts.config_order = opts.config_order or _opts.config_order
	if validate_config_order(opts.config_order) then
		opts.config_order = opts.config_order
	else
		opts.config_order = _opts.config_order
	end
	return opts
end

local set_local_opts = function(opts)
	_opts.log_level = vim.tbl_contains(const.log_levels, opts.log_level) and opts.log_level or const.default_log_level
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	_opts = vim.tbl_extend("keep", {
		configs = {
			global = {
				path = string.format("%s/%s", vim.fn.stdpath("data"), _opts.config),
				tasks = {},
			},
			project = {
				path = string.format("%s/%s", vim.fn.getcwd(), _opts.config),
				tasks = {},
			},
			opts = {
				path = nil,
				tasks = utils.deep_copy(_opts.tasks) or {},
			},
		},
	}, _opts)
	_opts.tasks = nil
end

function Config.init(opts)
	opts = opts or {}
	opts = set_opts_defaults(opts)
	set_local_opts(opts)
	return Config.opts()
end

return Config
