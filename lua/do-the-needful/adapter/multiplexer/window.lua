local Job = require("plenary.job")
local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format
local const = require("do-the-needful.constants").get()
local tmux = require("do-the-needful.adapter.multiplexer.command.tmux")
local zellij = require("do-the-needful.adapter.multiplexer.command.zellij")

---@class MultiplexWindow
---@field open fun(selection: TaskConfig)
---@return MultiplexWindow
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

local function build_task(task, pane, command)
  local cmd = command.build(task, pane)
  if not cmd then
    Log.error(sf(
      [[window.build_task(): no return value from %s(). 
        task: %s
        run_adapter: %s
        ]],
      pane and "build_send_to_pane" or "build_cmd_args",
      task,
      const.run_adapter
    ))
    return
  end
  Log.debug(sf("window.build_task(): cmd %s", cmd))
  return cmd
end

local function build_commands(task, pane)
  local command = const.run_adapter == const.enum.RunAdapter.tmux and tmux
    or const.run_adapter == const.enum.RunAdapter.zellij and zellij
    or nil
  if not command then
    Log.warn(sf(
      [[window.build_commands(): no command found for run_adapter %s.
        task: %s
        ]],
      const.run_adapter,
      task
    ))
    return
  end
  local cmd = build_task(task, pane, command)
  if not cmd then
    return
  end
  return compose_job(cmd, task.cwd)
end

function M.open(task)
  local cmd = build_commands(task)
  Log.trace(sf("window.open(): cmd %s", cmd))
  if not cmd then
    Log.error(
      [[window.open(): no return value from build_commands().
    task: %s]],
      task
    )
    return
  end
  local pane = Job:new(cmd):sync()
  if not task.window.close then
    if not pane or not pane[1] then
      Log.error(sf(
        [[window.open(): pane not found when running job: 
      task: %s
      pane: %s
      ]],
        task,
        pane
      ))
      return
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
      return
    end
    return Job:new(pane_cmd):sync()
  end
end

return M
