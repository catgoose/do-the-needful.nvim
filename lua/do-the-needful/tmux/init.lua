local Log = require("do-the-needful").Log
local window = require("do-the-needful.tmux.window")

---@class Tmux
---@field run fun(task: TaskConfig)
---@return Tmux
local M = {}

local function tmux_running()
  if not vim.env.TMUX then
    Log.error("checking $TMUX env...tmux is not running")
    return nil
  end
  return true
end

function M.run(task)
  if not tmux_running() then return nil end
  window.open(task)
end

return M
