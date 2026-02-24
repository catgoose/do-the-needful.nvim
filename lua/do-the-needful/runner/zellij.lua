local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format

---@class ZellijRunner: RunnerProvider
local M = {}

M.name = "zellij"

function M.is_available()
  return vim.env.ZELLIJ ~= nil
end

function M.run(task)
  dtn.Log.trace(sf("runner.zellij.run(): running task %s", task))
  local cwd = task.cwd or vim.fn.getcwd()
  local win_name = (task.window and task.window.name) or task.name or "needful"

  local args = { "zellij", "run", "--name", win_name, "--cwd", cwd }

  if task.window and task.window.close then
    table.insert(args, "--close-on-exit")
  end

  if task.window and task.window.keep_current then
    table.insert(args, "--floating")
  end

  vim.list_extend(args, { "--", "sh", "-c", task.cmd })

  vim.system(args, { cwd = cwd })
end

return M
