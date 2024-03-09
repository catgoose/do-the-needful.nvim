local Path = require("plenary.path")

---@class Utils
---@field deep_copy fun(orig: table): table
---@field indent_str fun(indent_n: number, str: string): string
---@field escaped_replace fun(str: string, what: string, with: string): string
---@field split_string fun(str: string, del: string): string[]
---@return Utils
Utils = {}

Utils.deep_copy = function(orig)
	local t = type(orig)
	local copy
	if t == "table" then
		copy = {}
		for k, v in pairs(orig) do
			copy[k] = Utils.deep_copy(v)
		end
	else
		copy = orig
	end
	return copy
end

Utils.indent_str = function(indent_n, str)
	return ("\t"):rep(indent_n) .. str
end

-- https://stackoverflow.com/questions/29072601/lua-string-gsub-with-a-hyphen
Utils.escaped_replace = function(str, what, with)
	what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
	with = string.gsub(with, "[%%]", "%%%%")
	return string.gsub(str, what, with)
end

Utils.split_string = function(str, del)
	del = del or " "
	return vim.split(str, del, { plain = true, trimempty = true })
end

Utils.string_format = function(msg, ...)
	local args = { ... }
	for i, v in ipairs(args) do
		if type(v) == "table" then
			args[i] = vim.inspect(v)
		end
	end
	return string.format(msg, unpack(args))
end

Utils.json_from_path = function(path)
	local f_handle = Path:new(path)
	if f_handle:exists() then
		local contents = f_handle:read()
		local ok, json = pcall(vim.json.decode, contents)
		if not ok then
			error(Utils.sf("tasks._decode_json(): invalid json decoded from file: %s", f_handle.filename))
			return nil
		end
		return json
	else
		return nil
	end
end

return Utils
