local Log = require("do-the-needful").Log
local const = require("do-the-needful.constants").get()
local extend = vim.list_extend
local sf = require("do-the-needful.utils").string_format

---@class MultiplexTmuxCommand
---@field build fun(task: TaskConfig): string[]
---@return MultiplexTmuxCommand
local M = {}

local function window_cmd(task)
  Log.trace(sf(
    [[command.tmux.build_cmd(): using selected task:
  %s]],
    task
  ))
  local cmd = { "tmux", "new-window" }
  if task.window.keep_current then
    extend(cmd, { "-d" })
  end
  if task.window.open_relative then
    if task.window.relative == const.enum.Relative.before then
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
  -- if not window.close compose command to open the pane and get the pane id
  if task.window.close then
    extend(cmd, { task.cmd })
  else
    extend(cmd, { "-P", "-F", "#{pane_id}" })
  end
  Log.debug(sf(
    [[command.%s.build_cmd()
      command table: %s
      task: %s
      ]],
    const.run_adapter,
    task.name,
    cmd
  ))
  return cmd
end

local function pane_cmd(task, pane)
  local cmd = { "tmux", "send", "-R", "-t", pane }
  extend(cmd, { task.cmd })
  extend(cmd, { "Enter" })
  return cmd
end

function M.build(task, pane)
  local cmd = pane and pane_cmd(task, pane) or window_cmd(task)
  return cmd
end

return M
