---@class TerminalAdapter
---@field run fun(task: TaskConfig)
---@return TerminalAdapter
local M = {}

---@param task TaskConfig
function M.run(task)
  vim.print("terminal")
  vim.print(task)
end

return M
