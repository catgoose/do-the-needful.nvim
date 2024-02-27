local Path = require("plenary.path")
local cfg = require("do-the-needful.config")
local Log = require("do-the-needful").Log
local const = require("do-the-needful.constants").val

local M = {}

local function populate_config()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, const.default_task_lines)
	vim.fn.setcursorcharpos(4, 13)
	Log.trace("edit._populate_config(): populating buffer for nonexisting file")
end

function M.edit_config(config)
	local file = cfg.opts().configs[config]
	vim.cmd.e(file)
	local file_h = Path:new(file)
	if not file_h:exists() or #file_h:read() == 0 then
		populate_config()
	end

	Log.trace(string.format("init.edit_config(): editing config type: %s", config))
end

return M
