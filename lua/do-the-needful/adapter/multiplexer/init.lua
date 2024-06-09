---@class MultiplexAdapter
---@field run fun(task: TaskConfig)
---@return MultiplexAdapter
local M = {}

---@param task TaskConfig
function M.run(task)
  require("do-the-needful.adapter.multiplexer.window").open(task)
end

return M
