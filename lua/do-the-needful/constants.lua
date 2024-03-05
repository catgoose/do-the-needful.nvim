local t = require("do-the-needful.utils").indent_str

local default_log_level = "warn"

---@class Opts
---@field dev boolean
---@field log_level string
---@field tasks table
---@field jobs table
---@field config_file string
---@field config_order table
---@field tag_source boolean
---@field global_tokens table
---@field ask_functions table
---@field telescope table

---@class Constants
---@field val Constants.val
---@return Constants
Constants = {}

---@class Constants.val
---@field plugin_name string
---@field task_preview_field_order string[]
---@field token_replacement_fields string[]
---@field opts Opts
---@field task_defaults TaskConfig
---@field default_task_lines string[]
---@field default_log_level string
---@field log_levels string[]
Constants.val = {
	plugin_name = "do-the-needful",
	task_preview_field_order = {
		"name",
		"cmd",
		"cwd",
		"window",
		"tags",
		"ask",
	},
	token_replacement_fields = {
		"cmd",
		"cwd",
		"name",
	},
	opts = {
		dev = false,
		log_level = default_log_level,
		tasks = {},
		jobs = {},
		config_file = ".tasks.json",
		config_order = {
			"global",
			"project",
			"opts",
		},
		tag_source = true,
		global_tokens = {
			["${cwd}"] = vim.fn.getcwd,
			["${do-the-needful}"] = "please",
		},
		ask_functions = {},
		telescope = {
			action_picker = {
				layout_strategy = "center",
				layout_config = {
					width = 0.25,
					prompt_position = "bottom",
				},
			},
		},
	},
	task_defaults = {
		cwd = vim.fn.getcwd(),
		tags = {},
		window = {
			close = true,
			keep_current = false,
		},
	},
	default_task_lines = {
		"{",
		t(1, '"tasks": ['),
		t(2, "{"),
		t(3, '"name": "",'),
		t(3, '"cmd": "",'),
		t(3, '"tags": [""],'),
		t(3, '"window": {'),
		t(4, '"name": "",'),
		t(4, '"close": false,'),
		t(4, '"keep_current": false,'),
		t(4, '"open_relative": true,'),
		t(4, '"relative": "after"'),
		t(3, "}"),
		t(2, "}"),
		t(1, "]"),
		"}",
	},
	default_log_level = default_log_level,
	log_levels = { "trace", "debug", "info", "warn", "error", "fatal" },
}

return Constants
