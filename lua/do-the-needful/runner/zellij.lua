local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format

---@class ZellijRunner: RunnerProvider
local M = {}

M.name = "zellij"

---@tag do-the-needful.runner.zellij.is_available
function M.is_available()
  return vim.env.ZELLIJ ~= nil
end

---@tag do-the-needful.runner.zellij.run
function M.run(task)
  dtn.Log.trace(sf("runner.zellij.run(): running task %s", task))
  local cwd = task.cwd or vim.fn.getcwd()
  local win_name = (task.window and task.window.name) or task.name or "needful"
  local opts = task.zellij or {}

  local args = { "zellij", "run", "--name", win_name, "--cwd", cwd }

  if task.window and task.window.close then
    table.insert(args, "--close-on-exit")
  end

  -- Provider-specific options from task.zellij
  if opts.direction then
    vim.list_extend(args, { "--direction", opts.direction })
  end
  if opts.floating then
    table.insert(args, "--floating")
  end
  if opts.in_place then
    table.insert(args, "--in-place")
  end
  if opts.start_suspended then
    table.insert(args, "--start-suspended")
  end
  if opts.width then
    vim.list_extend(args, { "--width", tostring(opts.width) })
  end
  if opts.height then
    vim.list_extend(args, { "--height", tostring(opts.height) })
  end
  if opts.x then
    vim.list_extend(args, { "--x", tostring(opts.x) })
  end
  if opts.y then
    vim.list_extend(args, { "--y", tostring(opts.y) })
  end

  vim.list_extend(args, { "--", "sh", "-c", task.cmd })

  vim.system(args, { cwd = cwd })
end

return M
