local Job = require("plenary.job")
local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format
local command = require("do-the-needful.adapter.tmux.command")
local const = require("do-the-needful.constants").get()

---@class TmuxWindow
---@field open fun(selection: TaskConfig)
---@return TmuxWindow
local M = {}

local function compose_job(cmd, cwd)
  Log.trace(sf("tmux.window._compose_job(): cmd %s, cwd %s", cmd, cwd))
  local job_command = table.remove(cmd, 1)
  if not job_command then
    Log.error(sf("tmux.window._compose_job(): no job_command found in cmd %s", cmd))
    return nil
  end
  local job_args = cmd
  local job_tbl = {
    command = job_command,
    args = job_args,
    cwd = cwd,
  }
  Log.trace(sf("tmux.window._compose_job(): return job_tbl %s", job_tbl))
  return job_tbl
end

local function build_task(task, pane)
  local cmd = command.build(task, pane)
  if not cmd then
    Log.error(sf(
      [[tmux.window.build_task(): no return value from %s(). 
        task: %s
        run_adapter: %s
        ]],
      pane and "build_send_to_pane" or "build_cmd_args",
      task,
      const.run_adapter
    ))
    return
  end
  Log.debug(sf("tmux.window.build_task(): cmd %s", cmd))
  return cmd
end

local function build_commands(task, pane)
  local cmd = build_task(task, pane)
  if not cmd then
    return
  end
  return compose_job(cmd, task.cwd)
end

function M.open(task)
  local cmd = build_commands(task)
  Log.trace(sf("tmux.window.open(): cmd %s", cmd))
  if not cmd then
    Log.error(
      [[tmux.window.open(): no return value from build_commands().
    task: %s]],
      task
    )
    return
  end
  local pane = Job:new(cmd):sync()
  if not task.window.close then
    if not pane or not pane[1] then
      Log.error(sf(
        [[tmux.window.open(): pane not found when running job: 
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
      [[tmux.window.open(): sending selected task to pane.
    task: %s
    pane: %s
    ]],
      task,
      pane
    ))
    local pane_cmd = build_commands(task, pane)
    if not pane_cmd then
      Log.error(
        "tmux.window.run_tasks(): no return value from build_send_to_pane(). selection %s",
        task
      )
      return
    end
    return Job:new(pane_cmd):sync()
  end
end

return M
