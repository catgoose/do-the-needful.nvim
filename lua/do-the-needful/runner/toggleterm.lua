local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format

---@class ToggletrmRunner: RunnerProvider
local M = {}

M.name = "toggleterm"

---@tag do-the-needful.runner.toggleterm.is_available
function M.is_available()
  local ok = pcall(require, "toggleterm")
  return ok
end

---@tag do-the-needful.runner.toggleterm.run
function M.run(task)
  dtn.Log.trace(sf("runner.toggleterm.run(): running task %s", task))
  local Terminal = require("toggleterm.terminal").Terminal
  local cwd = task.cwd or vim.fn.getcwd()
  local win_name = (task.window and task.window.name) or task.name or "needful"
  local close = not task.window or task.window.close ~= false
  local keep_current = task.window and task.window.keep_current

  local opts = task.toggleterm or {}

  local prev_win = vim.api.nvim_get_current_win()
  local term_opts = {
    cmd = task.cmd,
    dir = cwd,
    display_name = win_name,
    close_on_exit = close,
  }
  if opts.direction then
    term_opts.direction = opts.direction
  end
  if opts.size then
    term_opts.size = opts.size
  end
  local term = Terminal:new(term_opts)
  term:toggle()
  if keep_current then
    vim.api.nvim_set_current_win(prev_win)
  end
end

return M
