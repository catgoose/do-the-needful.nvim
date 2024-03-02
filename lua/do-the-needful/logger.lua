local get_opts = require("do-the-needful.config").get_opts
local const = require("do-the-needful.constants").val

---@class Logger
---@field log table
---@field init fun()
---@return Logger
Logger = {}


Logger.log = nil

Logger.init = function()
	Logger.log = require("plenary.log").new({
		plugin = const.plugin_name,
		level = get_opts().log_level,
		fmt_msg = function(_, mode_name, src_path, src_line, msg)
			local nameupper = mode_name:upper()
			local lineinfo = vim.fn.fnamemodify(src_path, ":t") .. ":" .. src_line
			local log_message = string.format("[%s %s] %s: %s", nameupper, os.date("%H:%M:%S"), lineinfo, msg)
			return log_message
		end,
	})
	return Logger.log
end

return Logger
