local Job = require("plenary.job")
local command = require("do-the-needful.tmux.command")
local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format

---@class TmuxWindow
---@field open fun(selection: TaskConfig)
---@return TmuxWindow
local M = {}

local function compose_job(cmd, cwd)
	Log.trace(sf("window._compose_job(): cmd %s, cwd %s", cmd, cwd))
	local job_command = table.remove(cmd, 1)
	if not job_command then
		Log.error(sf("window._compose_job(): no job_command found in cmd %s", cmd))
		return nil
	end
	local job_args = cmd
	local job_tbl = {
		command = job_command,
		args = job_args,
		cwd = cwd,
	}
	Log.trace(sf("window._compose_job(): return job_tbl %s", job_tbl))
	return job_tbl
end

local function build_commands(task, pane)
	local cmd = pane and command.build_send_to_pane(task, pane) or command.build_cmd_args(task)
	if not cmd then
		Log.error(
			sf(
				"window.build_commands(): no return value from tmux.%s(). task: %s",
				pane and "build_send_to_pane" or "build_cmd_args",
				task
			)
		)
		return nil
	end
	Log.debug(sf("window.build_commands(): cmd %s", cmd))
	return compose_job(cmd, task.cwd)
end

function M.open(task)
	local cmd = build_commands(task)
	Log.trace(sf("window.open(): cmd %s", cmd))
	if not cmd then
		Log.error("window.open(): no return value from build_command(). selection %s", task)
		return nil
	end
	local pane = Job:new(cmd):sync()
	if not task.window.close then
		if not pane or not pane[1] then
			Log.error(sf("window.open(): pane not found when running job for selected task %s", task))
			return nil
		end
		pane = pane[1]
		Log.trace(sf(
			[[window.open(): sending selected task to pane.
    task: %s
    pane: %s
    ]],
			task,
			pane
		))
		local pane_cmd = build_commands(task, pane)
		if not pane_cmd then
			Log.error("window.run_tasks(): no return value from build_send_to_pane(). selection %s", task)
			return nil
		end
		return Job:new(pane_cmd):sync()
	end
end

return M
