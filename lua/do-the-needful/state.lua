local deep_copy = require("do-the-needful.utils").deep_copy

---@class State
---@field get_last_task fun(): TaskConfig|nil
---@field set_last_task fun(task: TaskConfig)
---@return State
local M = {}

---@type TaskConfig|nil
local _last_task = nil

function M.get_last_task()
  return _last_task
end

function M.set_last_task(task)
  _last_task = deep_copy(task)
end

return M
