local get_opts = require("do-the-needful.config").get_opts
local const = require("do-the-needful.constants").val

---@class Logger
---@field log table
---@field init fun()
---@field trace fun(msg: string, ...: any)
---@field debug fun(msg: string, ...: any)
---@field info fun(msg: string, ...: any)
---@field warn fun(msg: string, ...: any)
---@field error fun(msg: string, ...: any)
---@return Logger
Logger = {}

local log = nil

Logger.trace = function(msg, ...)
	if log then
		log.trace(string.format(msg, ...))
	end
end
Logger.debug = function(msg, ...)
	if log then
		log.debug(string.format(msg, ...))
	end
end
Logger.info = function(msg, ...)
	if log then
		log.info(string.format(msg, ...))
	end
end
Logger.warn = function(msg, ...)
	if log then
		log.warn(string.format(msg, ...))
	end
end
Logger.err = function(msg, ...)
	if log then
		log.error(string.format(msg, ...))
	end
end

Logger.init = function()
	log = require("plenary.log").new({
		plugin = const.plugin_name,
		level = get_opts().log_level,
		fmt_msg = function(_, mode_name, src_path, src_line, msg)
			local nameupper = mode_name:upper()
			local lineinfo = vim.fn.fnamemodify(src_path, ":t") .. ":" .. src_line
			local log_message = string.format("[%s %s] %s: %s", nameupper, os.date("%H:%M:%S"), lineinfo, msg)
			return log_message
		end,
	})
	return log
end

return Logger
