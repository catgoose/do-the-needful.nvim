---@class ZellijAdapter
---@field run fun(task: TaskConfig)
---@return ZellijAdapter
local M = {}

---@param task TaskConfig
function M.run(task)
  require("do-the-needful.adapter.zellij.window").open(task)
end

return M
