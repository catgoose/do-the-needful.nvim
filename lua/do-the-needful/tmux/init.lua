local Log = require("do-the-needful").Log
local window = require("do-the-needful.tmux.window")

---@class Tmux
---@field run fun(task: TaskConfig)
---@return Tmux
Tmux = {}

---@class TmuxWindow
---@field name? string
---@field close? boolean
---@field keep_current? boolean
---@field open_relative? boolean
---@field relative? relative
---@enum relative "before" "after"

local function tmux_running()
	if not vim.env.TMUX then
		Log.error("checking $TMUX env...tmux is not running")
		return nil
	end
	return true
end

function Tmux.run(task)
	if not tmux_running() then
		return nil
	end
	window.open(task)
end

return Tmux
