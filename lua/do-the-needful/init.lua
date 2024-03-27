local cfg = require("do-the-needful.config")

---@class DoTheNeedful
---@field setup fun(config: table)
---@field Log Logger
---@field edit_config fun(config: source)
---@field please fun()
---@return DoTheNeedful
local M = {}

function M.setup(config)
	config = config or {}
	cfg.init(config)
	M.Log = require("do-the-needful.logger").init()
end

function M.edit_config(config)
	config = ("project" or "global") and config or "project"
	require("do-the-needful.edit").edit_config(config)
end

function M.please()
	require("do-the-needful.telescope").tasks()
end

return M
