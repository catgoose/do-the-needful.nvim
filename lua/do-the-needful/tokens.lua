local utils = require("do-the-needful.utils")
local get_opts = require("do-the-needful.config").get_opts
local Log = require("do-the-needful").Log
local ins = vim.inspect

Token = {}

local replace_cmd_tokens = function(cmd)
	local tokens = get_opts().global_tokens
	for k, v in pairs(tokens) do
		if type(v) == "string" then
			cmd = utils.escaped_replace(cmd, k, v)
		end
		if type(v) == "function" then
			cmd = utils.escaped_replace(cmd, k, v())
		end
	end
	Log.trace(string.format("Token.replace_cmd_tokens: %s", cmd))
	return cmd
end

local input_opts = function(token, ask)
	local funcs = get_opts().ask_functions
	local opts = {
		prompt = (ask.title or token) .. ": ",
	}
	if ask.type == "function" and funcs[ask.default] then
		local ok, default = pcall(funcs[ask.default])
		opts.default = ok and default or ""
	else
		opts.default = ask.default or ""
	end
	return opts
end

local get_input_configs = function(selection)
	local configs = {}
	for token, opts in pairs(selection.ask) do
		if selection.cmd:find(token) then
			table.insert(configs, {
				[token] = input_opts(token, opts),
			})
		end
	end
	return configs
end

local execute_task = function(selection, task_cb)
	local task = {
		cmd = selection.cmd,
		name = selection.name,
		cwd = selection.cwd,
		window = selection.window,
	}
	Log.trace(string.format(
		[[Token.execute_task: task generated:
                %s]],
		ins(task)
	))
	task_cb(task)
end

local ask_tokens = function(selection, task_cb)
	if selection.ask then
		local configs = get_input_configs(selection)
		local count = 0
		for _, config in ipairs(configs) do
			for token, opts in pairs(config) do
				--  TODO: 2024-02-28 - Create function queue to handle multiple inputs
				-- If an input is cancelled the entire chain should be cancelled
				vim.ui.input(opts, function(input)
					if input then
						count = count + 1
						selection.cmd = utils.escaped_replace(selection.cmd, token, input)
						Log.trace(string.format(
							[[Token.ask_tokens: token %s replaced for cmd:
                %s]],
							token,
							selection.cmd
						))
						if count == #configs then
							execute_task(selection, task_cb)
						end
					end
				end)
			end
		end
	else
		execute_task(selection, task_cb)
	end
end

Token.replace = function(selection, task_cb)
	Log.trace(string.format(
		[[Token.replace started for selection:
  %s]],
		ins(selection)
	))
	selection.cmd = replace_cmd_tokens(selection.cmd)
	ask_tokens(selection, task_cb)
end

return Token
