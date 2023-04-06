local cfg = require("do-the-needful.config")
local e = require("do-the-needful.edit")

local M = {}

function M.setup(config)
	config = config or {}
	cfg.init(config)
end

function M.edit_config(config)
	config = ("project" or "global") and config or "project"
	e.edit_config(config)
end

function M.please()
	require("do-the-needful.telescope").tasks()
end

return M
