local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format
local extend = vim.list_extend

---@class TmuxRunner: RunnerProvider
local M = {}

M.name = "tmux"

---@tag do-the-needful.runner.tmux.is_available
function M.is_available()
  return vim.env.TMUX ~= nil
end

local function build_cmd_args(task)
  dtn.Log.trace(sf("runner.tmux.build_cmd_args(): using selected task %s", task))
  local opts = task.tmux or {}
  local is_split = opts.split == true

  local cmd_args = { "tmux", is_split and "split-window" or "new-window" }
  extend(cmd_args, { "-c", task.cwd or vim.fn.getcwd() })

  if task.window and task.window.keep_current then
    extend(cmd_args, { "-d" })
  end

  if is_split then
    -- Split-specific flags
    if opts.direction == "horizontal" then
      extend(cmd_args, { "-h" })
    elseif opts.direction == "vertical" then
      extend(cmd_args, { "-v" })
    end
    if opts.size then
      extend(cmd_args, { "-l", tostring(opts.size) })
    end
    if opts.full_span then
      extend(cmd_args, { "-f" })
    end
  else
    -- New-window-specific flags
    if task.window and task.window.open_relative then
      if task.window.relative == "before" then
        extend(cmd_args, { "-b" })
      else
        extend(cmd_args, { "-a" })
      end
    end
    if opts.reuse then
      extend(cmd_args, { "-S" })
    end
    local win_name = (task.window and task.window.name) or task.name
    if win_name then
      extend(cmd_args, { "-n", win_name })
    end
  end

  -- Environment variables (both split and new-window)
  if opts.environment then
    for k, v in pairs(opts.environment) do
      extend(cmd_args, { "-e", k .. "=" .. v })
    end
  end

  if task.window and task.window.close then
    extend(cmd_args, { task.cmd })
  else
    extend(cmd_args, { "-P", "-F", "#{pane_id}" })
  end
  dtn.Log.debug(sf("runner.tmux.build_cmd_args(): cmd table: %s", cmd_args))
  return cmd_args
end

local function build_send_to_pane(task, pane)
  local cmd = { "tmux", "send", "-R", "-t", pane }
  extend(cmd, { task.cmd })
  extend(cmd, { "Enter" })
  return cmd
end

---@tag do-the-needful.runner.tmux.run
function M.run(task)
  if not M.is_available() then
    dtn.Log.error("runner.tmux.run(): tmux is not running")
    return
  end
  local cmd_args = build_cmd_args(task)
  local closes = not task.window or task.window.close ~= false

  if closes then
    vim.system(cmd_args, { cwd = task.cwd })
  else
    vim.system(cmd_args, { cwd = task.cwd }, function(result)
      local pane = vim.trim(result.stdout or "")
      if pane == "" then
        dtn.Log.error(sf("runner.tmux.run(): pane not found for task: %s", task))
        return
      end
      dtn.Log.trace(sf("runner.tmux.run(): sending task to pane %s", pane))
      local pane_cmd = build_send_to_pane(task, pane)
      vim.system(pane_cmd, { cwd = task.cwd })
    end)
  end
end

return M
