Constants = {}

Constants.val = {
	plugin_name = "do-the-needful",
	field_order = {
		"name",
		"cmd",
		"cwd",
		"window",
		"tags",
	},
	wrap_fields_at = 3,
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
		'\t"tasks": [',
		"\t\t{",
		'\t\t\t"name": "",',
		'\t\t\t"cmd": "",',
		'\t\t\t"tags": [""],',
		'\t\t\t"window": {',
		'\t\t\t\t"name": "",',
		'\t\t\t\t"close": false,',
		'\t\t\t\t"keep_current": false,',
		'\t\t\t\t"open_relative": true,',
		'\t\t\t\t"relative": "after"',
		"\t\t\t}",
		"\t\t}",
		"\t]",
		"}",
	},
	default_log_level = "warn",
	log_levels = { "trace", "debug", "info", "warn", "error", "fatal" },
}

return Constants
