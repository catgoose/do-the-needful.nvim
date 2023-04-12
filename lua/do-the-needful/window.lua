local Job = require("plenary.job")
local extend = vim.list_extend
local log = require("do-the-needful.log").log
local tmux = require("do-the-needful.tmux")
local ins = vim.inspect

local M = {}

local compose_job = function(cmd, cwd)
	local command = table.remove(cmd, 1)
	local job_tbl = {
		command = command,
		args = cmd,
		cwd = cwd,
	}
	log.trace(string.format("window._compose_job(): return job_tbl %s", ins(job_tbl)))
	return job_tbl
end

local function build_command(s)
	local cmd = tmux.build_command(s)
	if not cmd then
		log.error("window.build_command(): no return value from tmux.build_command()")
		return
	end
	return compose_job(cmd, s.cwd)
end

local send_cmd_to_pane = function(s, pane)
	local cmd = { "tmux", "send", "-R", "-t", pane }
	extend(cmd, { s.cmd })
	extend(cmd, { "Enter" })
	log.trace(string.format("window._send_cmd_to_pane(): sending cmd %s to pane %s", ins(cmd), pane))
	Job:new(compose_job(cmd, s.cwd)):sync()
end

local function tmux_running()
	if not vim.env.TMUX then
		log.error("checking $TMUX env...tmux is not running")
		return nil
	end
	return true
end

function M.run_task(selection)
	if not tmux_running() then
		return nil
	end
	local cmd = build_command(selection)
	if not cmd then
		log.error("window.run_tasks(): no return value from build_command()")
		return
	end
	local pane = Job:new(cmd):sync()
	if not pane then
		log.debug(
			string.format("window.run_task(): pane not found when running job for selected task %s", ins(selection))
		)
		return
	end
	pane = pane[1]
	if not selection.window.close then
		log.trace(string.format("window.run_task(): sending selected task %s to pane %s", ins(selection), pane))
		send_cmd_to_pane(selection, pane)
	end
end

return M
