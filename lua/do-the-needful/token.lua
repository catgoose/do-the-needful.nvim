local const = require("do-the-needful.constants").val
local utils = require("do-the-needful.utils")
local cfg = require("do-the-needful.config")

Token = {}

local replace_cmd_tokens = function(cmd)
	local tokens = const.opts.tokens
	for k, v in pairs(tokens) do
		if type(v) == "string" then
			cmd = utils.escaped_replace(cmd, k, v)
		end
		if type(v) == "function" then
			cmd = utils.escaped_replace(cmd, k, v())
		end
	end
	return cmd
end

--  TODO: 2024-02-28 - Can this be made async or use plenary job?
local ask_tokens = function(selection)
	if selection.ask then
		local funcs = cfg.opts().ask_functions
		for k, v in pairs(selection.ask) do
			if selection.cmd:find(k) then
				vim.ui.input(v, function(input)
					selection.cmd = utils.escaped_replace(selection.cmd, k, input)
				end)
			end
		end
	end
	return selection
end

local process_cmd = function(selection)
	selection.cmd = replace_cmd_tokens(selection.cmd)
	selection = ask_tokens(selection)
	return selection.cmd
end

Token.parse = function(selection)
	local task = {
		cmd = process_cmd(selection),
		cwd = selection.cwd,
		window = selection.window,
	}
	vim.print(task)
	return task
end

return Token
