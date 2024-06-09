local command = require("do-the-needful.adapter.tmux.command")
local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format

---@class TerminalWindow
---@field open fun(selection: TaskConfig)
---@return TerminalWindow
local M = {}

function M.open(task)
  Log.warn("terminal.window.open: not implemented")
end

return M
