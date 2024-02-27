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

return Utils
