local log = require("do-the-needful.log").log
local ins = vim.inspect

local M = {}

local _opts = {
	tasks = {},
	config = ".tasks.json",
	config_order = {
		"project",
		"global",
		-- "opts",
	},
	--  TODO: 2024-02-26 - Validate global_tokens
	global_tokens = {
		cwd = {
			["${cwd}"] = vim.fn.getcwd(),
		},
	},
}

M.field_order = {
	"name",
	"cmd",
	"cwd",
	"window",
	"tags",
}

M.task_defaults = {
	cwd = vim.fn.getcwd(),
	tags = {},
	window = {
		close = true,
		keep_current = false,
	},
}

M.wrap_fields_at = 3

function M.opts()
	log.trace(string.format("config.opts(): returning _opts %s", ins(_opts)))
	return _opts
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

function M.init(opts)
	opts = opts or {}
	opts.priority = ("project" or "global") and opts.priority or "project"
	opts.config_order = opts.config_order or _opts.config_order
	if validate_config_order(opts.config_order) then
		opts.config_order = opts.config_order
	else
		--  TODO: 2024-02-26 - does this need to be a deep extend?
		opts.config_order = _opts.config_order
	end
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	_opts = vim.tbl_extend("keep", {
		configs = {
			global = string.format("%s/%s", vim.fn.stdpath("data"), _opts.config),
			project = string.format("%s/%s", vim.fn.getcwd(), _opts.config),
		},
	}, _opts)

	log.trace(string.format("config.init(): extending opts %s over _opts %s", ins(opts), ins(_opts)))
	return M.opts()
end

return M
