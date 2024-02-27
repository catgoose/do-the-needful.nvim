local const = require("do-the-needful.constants").val

Config = {}

local _opts = {
	dev = false,
	log_level = const.default_log_level,
	tasks = {},
	config = ".tasks.json",
	config_order = {
		"project",
		"global",
		-- "opts",
	},
	--  TODO: 2024-02-26 - Validate global_tokens
	global_tokens = {
		cwd = {
			["${cwd}"] = vim.fn.getcwd(),
		},
	},
}

function Config.opts()
	return _opts
end

local validate_config_order = function(config_order)
	local valid = true
	if not vim.tbl_islist(config_order) then
		return not valid
	end
	for _, c in pairs(config_order) do
		if c ~= "project" and c ~= "global" and c ~= "opts" then
			valid = false
			break
		end
	end
	return valid
end

function Config.init(opts)
	opts = opts or {}
	opts.priority = ("project" or "global") and opts.priority or "project"
	opts.config_order = opts.config_order or _opts.config_order
	if validate_config_order(opts.config_order) then
		opts.config_order = opts.config_order
	else
		--  TODO: 2024-02-26 - does this need to be a deep extend?
		opts.config_order = _opts.config_order
	end
	_opts.log_level = vim.tbl_contains(const.log_levels, opts.log_level) and opts.log_level or const.default_log_level
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	_opts = vim.tbl_extend("keep", {
		configs = {
			global = string.format("%s/%s", vim.fn.stdpath("data"), _opts.config),
			project = string.format("%s/%s", vim.fn.getcwd(), _opts.config),
		},
	}, _opts)

	return Config.opts()
end

return Config
