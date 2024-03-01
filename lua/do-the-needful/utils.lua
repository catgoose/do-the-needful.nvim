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

return Utils
