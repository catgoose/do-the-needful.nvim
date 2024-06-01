local Log = require("do-the-needful").Log
local const = require("do-the-needful.constants").get()
local extend = vim.list_extend
local sf = require("do-the-needful.utils").string_format

---@class TmuxCommand
---@field build fun(task: TaskConfig): string[]
---@field build_send_to_pane fun(task: TaskConfig, pane: string): string[]
---@return TmuxCommand
local M = {}

function M.build_cmd_args(task)
  Log.trace(sf("tmux.command.build_command(): using selected task %s", task))
  local cmd_args = { "tmux", "new-window" }
  if task.window.keep_current then
    extend(cmd_args, { "-d" })
  end
  if task.window.open_relative then
    if task.window.relative == const.enum.Relative.before then
      extend(cmd_args, { "-b" })
    else
      extend(cmd_args, { "-a" })
    end
  end
  if task.window.name then
    extend(cmd_args, { "-n", task.window.name })
  else
    extend(cmd_args, { "-n", task.name })
  end
  -- if not window.close compose command to open the pane and get the pane id
  if task.window.close then
    extend(cmd_args, { task.cmd })
  else
    extend(cmd_args, { "-P", "-F", "#{pane_id}" })
  end
  Log.debug(
    sf(
      "tmux.command.build_command(): using selected task %s, building tmux command table: %s",
      task,
      cmd_args
    )
  )
  return cmd_args
end

function M.build_send_to_pane(task, pane)
  local cmd = { "tmux", "send", "-R", "-t", pane }
  extend(cmd, { task.cmd })
  extend(cmd, { "Enter" })
  return cmd
end

return M
