local Job = require("plenary.job")
local Log = require("do-the-needful").Log
local tmux = require("do-the-needful.tmux")
local extend = vim.list_extend
local ins = vim.inspect

---@class Window
---@func open(selection: TaskConfig)
---@return Window
local Window = {}

local compose_job = function(cmd, cwd)
	Log.trace(string.format("window._compose_job(): cmd %s, cwd %s", ins(cmd), cwd))
	local command = table.remove(cmd, 1)
	local job_tbl = {
		command = command,
		args = cmd,
		cwd = cwd,
	}
	Log.trace(string.format("window._compose_job(): return job_tbl %s", ins(job_tbl)))
	return job_tbl
end

local function build_command(s)
	local cmd = tmux.build_command(s)
	if not cmd then
		Log.error("window.build_command(): no return value from tmux.build_command()")
		return
	end
	return compose_job(cmd, s.cwd)
end

local send_cmd_to_pane = function(selection, pane)
	local cmd = { "tmux", "send", "-R", "-t", pane }
	extend(cmd, { selection.cmd })
	extend(cmd, { "Enter" })
	Log.trace(string.format("window._send_cmd_to_pane(): sending cmd %s to pane %s", ins(cmd), pane))
	Job:new(compose_job(cmd, selection.cwd)):sync()
end

local function tmux_running()
	if not vim.env.TMUX then
		Log.error("checking $TMUX env...tmux is not running")
		return nil
	end
	return true
end

function Window.open(selection)
	vim.print(selection)
	if not tmux_running() then
		return nil
	end
	local cmd = build_command(selection)
	Log.trace(string.format("window.run_task(): cmd %s", ins(cmd)))
	if not cmd then
		Log.error("window.run_tasks(): no return value from build_command()")
		return nil
	end
	local pane = Job:new(cmd):sync()
	if not pane then
		Log.warn(
			string.format("window.run_task(): pane not found when running job for selected task %s", ins(selection))
		)
		return nil
	end
	pane = pane[1]
	if not selection.window.close then
		Log.trace(string.format("window.run_task(): sending selected task %s to pane %s", ins(selection), pane))
		send_cmd_to_pane(selection, pane)
	end
end

return Window
