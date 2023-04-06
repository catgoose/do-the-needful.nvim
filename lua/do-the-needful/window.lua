local Job = require("plenary.job")
local extend = vim.list_extend
local log = require("do-the-needful.log").log
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

local function window_opts(s)
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
	log.trace(
		string.format("window.window_opts(): using selected task %s, building tmux command table: %s", ins(s), ins(s))
	)
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

function M.run_task(s)
	if not tmux_running() then
		return nil
	end
	local pane = Job:new(window_opts(s)):sync()
	if not pane then
		log.debug(string.format("window.run_task(): pane not found when running job for selected task %s", ins(s)))
		return
	end
	pane = pane[1]
	if not s.window.close then
		log.trace(string.format("window.run_task(): sending selected task %s to pane %s", ins(s), pane))
		send_cmd_to_pane(s, pane)
	end
end

return M
