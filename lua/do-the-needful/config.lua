local log = require("do-the-needful.log").log
local ins = vim.inspect

local M = {}

local _opts = {
	tasks = {},
	config = ".tasks.json",
	config_order = { "project", "global", "opts" },
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

M.tokens = {
	cwd = {
		["${cwd}"] = vim.fn.getcwd(),
	},
}

function M.opts()
	log.trace(string.format("config.opts(): returning _opts %s", ins(_opts)))
	return _opts
end

local validate_config_order = function(config_order)
	local valid = true
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
