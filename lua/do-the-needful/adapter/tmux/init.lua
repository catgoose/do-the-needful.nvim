---@class TmuxAdapter
---@field run fun(task: TaskConfig)
---@return TmuxAdapter
local M = {}

---@param task TaskConfig
function M.run(task)
  require("do-the-needful.adapter.tmux.window").open(task)
end

return M
