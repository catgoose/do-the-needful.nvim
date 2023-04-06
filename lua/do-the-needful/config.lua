local log = require("do-the-needful.log").log
local ins = vim.inspect

local M = {}

local _opts = {
	tasks = {},
	config = ".tasks.json",
}

M.config_order = { "project", "global" }

M.field_order = {
	"name",
	"cmd",
	"cwd",
	"window",
	"tags",
}

M.task_defaults = {
	cwd = vim.loop.cwd(),
	tags = {},
	window = {
		close = true,
		keep_current = false,
	},
}

M.wrap_fields_at = 3

M.tokens = {
	cwd = {
		["${cwd}"] = vim.loop.cwd(),
	},
}

function M.opts()
	log.trace(string.format("config.opts(): returning _opts %s", ins(_opts)))
	return _opts
end

function M.init(opts)
	opts = opts or {}
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	_opts = vim.tbl_extend("keep", {
		configs = {
			global = string.format("%s/%s", vim.fn.stdpath("data"), _opts.config),
			project = string.format("%s/%s", vim.loop.cwd(), _opts.config),
		},
	}, _opts)

	log.trace(string.format("config.init(): extending opts %s over _opts %s", ins(opts), ins(_opts)))
	return M.opts()
end

return M
