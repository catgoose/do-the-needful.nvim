local log = require("do-the-needful.log").log
local ins = vim.inspect

local M = {}

local config_file = ".do-the-needful.json"
local global_config = string.format("%s/%s", vim.fn.stdpath("data"), config_file)
local project_config = string.format("%s/%s", vim.loop.cwd(), config_file)

local _opts = {
	needful = {},
	configs = {
		global = global_config,
		project = project_config,
	},
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

function M.opts()
	log.trace(string.format("config.opts(): returning _opts %s", ins(_opts)))
	return _opts
end

function M.init(opts)
	opts = opts or {}
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	log.trace(string.format("config.init(): extending opts %s over _opts %s", ins(opts), ins(_opts)))
	return M.opts()
end

return M
