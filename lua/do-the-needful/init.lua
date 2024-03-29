local cfg = require("do-the-needful.config")

---@class DoTheNeedful
---@field setup fun(opts: table)
---@field telescope_setup fun(opts: table)
---@field Log Logger
---@field edit_config fun(opts: source)
---@field please fun()
---@return DoTheNeedful
local M = {}

function M.setup(opts)
	opts = opts or {}
	cfg.init(opts)
	M.Log = require("do-the-needful.logger").init()
end

function M.edit_config(opts)
	opts = ("project" or "global") and opts or "project"
	require("do-the-needful.edit").edit_config(opts)
end

function M.please(opts)
	require("do-the-needful.telescope").tasks(opts)
end

function M.action(opts)
	require("do-the-needful.telescope").action_picker(opts)
end

return M
