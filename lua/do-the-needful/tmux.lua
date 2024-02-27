local extend = vim.list_extend
local Log = require("do-the-needful").Log
local ins = vim.inspect

local M = {}

function M.build_command(s)
	if not s then
		return
	end
	local cmd = { "tmux", "new-window" }
	if s.window.keep_current then
		extend(cmd, { "-d" })
	end
	if s.window.open_relative then
		if s.window.relative == "before" then
			extend(cmd, { "-b" })
		else
			extend(cmd, { "-a" })
		end
	end
	if s.window.name then
		extend(cmd, { "-n", s.window.name })
	else
		extend(cmd, { "-n", s.name })
	end
	if s.window.close then
		extend(cmd, { s.cmd })
	else
		extend(cmd, { "-P", "-F", "#{pane_id}" })
	end
	Log.trace(
		string.format("window.window_opts(): using selected task %s, building tmux command table: %s", ins(s), ins(s))
	)

	return cmd
end

return M
