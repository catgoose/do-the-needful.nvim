local M = {}

local log_levels = { "trace", "debug", "info", "warn", "error", "fatal" }
local function set_log_level()
	local log_level = vim.env.TMUX_TASKS_LOG or vim.g.tmux_tasks_log_level
	for _, level in pairs(log_levels) do
		if level == log_level then
			return log_level
		end
	end
	return "warn"
end

local log_level = set_log_level()
M.log = require("plenary.log").new({
	plugin = "do-the-needful",
	level = log_level,
})

return M
