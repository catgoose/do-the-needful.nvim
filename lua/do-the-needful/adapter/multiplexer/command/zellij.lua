local Log = require("do-the-needful").Log
local const = require("do-the-needful.constants").get()
local extend = vim.list_extend
local sf = require("do-the-needful.utils").string_format

---@class MultiplexZellijCommand
---@field build fun(task: TaskConfig): string[]
---@return MultiplexZellijCommand
local M = {}

function M.build(task, pane)
  Log.warn("zellij.build: not implemented")
end

return M
