local cfg = require("do-the-needful.config")

---@class DoTheNeedful
---@field setup fun(config: table)
---@field Log Logger
---@field edit_config fun(config: source)
---@field please fun()
---@return DoTheNeedful
local DoTheNeedful = {}

function DoTheNeedful.setup(config)
	config = config or {}
	cfg.init(config)
	DoTheNeedful.Log = require("do-the-needful.logger").init()
end

function DoTheNeedful.edit_config(config)
	config = ("project" or "global") and config or "project"
	require("do-the-needful.edit").edit_config(config)
end

function DoTheNeedful.please()
	require("do-the-needful.telescope").tasks()
end

return DoTheNeedful
