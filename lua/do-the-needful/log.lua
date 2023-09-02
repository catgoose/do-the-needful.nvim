local M = {}

local log_levels = { "trace", "debug", "info", "warn", "error", "fatal" }
local default_log_level = "warn"

local function set_log_level()
	local log_level = vim.env.DO_THE_NEEDFUL_LOG_LEVEL or vim.g.do_the_needful_log_level
	return vim.tbl_contains(log_levels, log_level) and log_level or default_log_level
end

M.log = require("plenary.log").new({
	plugin = "do-the-needful",
	level = set_log_level(),
})

return M
