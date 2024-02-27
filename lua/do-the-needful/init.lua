local cfg = require("do-the-needful.config")
local e = require("do-the-needful.edit")

Needful = {}

function Needful.setup(config)
	config = config or {}
	cfg.init(config)
	Needful.Log = require("do-the-needful.logger").init()
end

function Needful.edit_config(config)
	config = ("project" or "global") and config or "project"
	e.edit_config(config)
end

function Needful.please()
	require("do-the-needful.telescope").tasks()
end

return Needful
