local Path = require("plenary.path")
local get_opts = require("do-the-needful.config").get_opts
local const = require("do-the-needful.constants").val
local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format

---@class Edit
---@field edit_config fun(config: string)
---@return Edit
local M = {}

local function populate_config()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, const.default_task_lines)
	vim.fn.setcursorcharpos(4, 14)
	Log.trace("edit._populate_config(): populating buffer for nonexisting file")
end

local function edit_file(file)
	local mode = get_opts().edit_mode
	if mode == "buffer" then
		vim.cmd.e(file)
	elseif mode == "vsplit" then
		vim.cmd.vsplit(file)
	elseif mode == "split" then
		vim.cmd.split(file)
	elseif mode == "tab" then
		vim.cmd.tabnew(file)
	else
		Log.error(sf("edit.edit_file(): unknown edit mode: %s", mode))
	end
end

function M.edit_config(config)
	local file = get_opts().configs[config].path
	edit_file(file)
	local file_h = Path:new(file)
	if not file_h:exists() or #file_h:read() == 0 then
		populate_config()
	end
	Log.trace(sf("init.edit_config(): editing config type: %s", config))
end

return M
