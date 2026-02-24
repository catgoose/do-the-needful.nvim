local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format

---@class NeovimRunner: RunnerProvider
local M = {}

M.name = "neovim"

function M.is_available()
  return true
end

function M.run(task)
  dtn.Log.trace(sf("runner.neovim.run(): running task %s", task))
  local cwd = task.cwd or vim.fn.getcwd()
  local keep_current = task.window and task.window.keep_current
  local close = not task.window or task.window.close ~= false
  local win_name = (task.window and task.window.name) or task.name or "needful"

  local opts = task.neovim or {}
  local split_cmd = opts.split or "botright split"
  if opts.size then
    split_cmd = tostring(opts.size) .. split_cmd
  end

  local prev_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.cmd(split_cmd)
  vim.api.nvim_win_set_buf(0, buf)
  local term_win = vim.api.nvim_get_current_win()

  local ok, _ = pcall(vim.api.nvim_buf_set_name, buf, "needful://" .. win_name)
  if not ok then
    pcall(
      vim.api.nvim_buf_set_name,
      buf,
      "needful://" .. win_name .. "-" .. buf
    )
  end

  vim.fn.jobstart(task.cmd, {
    term = true,
    cwd = cwd,
    on_exit = function(_, exit_code, _)
      dtn.Log.trace(sf("runner.neovim.run(): task exited with code %s", exit_code))
      if close then
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(term_win) then
            vim.api.nvim_win_close(term_win, true)
          end
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end)
      end
    end,
  })

  if keep_current then
    vim.api.nvim_set_current_win(prev_win)
  else
    vim.cmd("startinsert")
  end
end

return M
