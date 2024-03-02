local trace = require("do-the-needful").trace
local extend = vim.list_extend
local ins = vim.inspect

---@class Tmux
---@field build_command fun(task: TaskConfig): string[]
---@return Tmux
Tmux = {}

---@class TmuxWindow
---@field name? string
---@field close? boolean
---@field keep_current? boolean
---@field open_relative? boolean
---@field relative? relative
---@enum relative "before" "after"

function Tmux.build_command(task)
	trace(string.format("tmux.build_command(): using selected task %s", ins(task)))
	if not task then
		return
	end
	local cmd = { "tmux", "new-window" }
	if task.window.keep_current then
		extend(cmd, { "-d" })
	end
	if task.window.open_relative then
		if task.window.relative == "before" then
			extend(cmd, { "-b" })
		else
			extend(cmd, { "-a" })
		end
	end
	if task.window.name then
		extend(cmd, { "-n", task.window.name })
	else
		extend(cmd, { "-n", task.name })
	end
	if task.window.close then
		extend(cmd, { task.cmd })
	else
		extend(cmd, { "-P", "-F", "#{pane_id}" })
	end
	trace(
		string.format(
			"window.window_opts(): using selected task %s, building tmux command table: %s",
			ins(task),
			ins(cmd)
		)
	)

	return cmd
end

return Tmux
