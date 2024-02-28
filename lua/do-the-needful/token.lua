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

local get_input_opts = function(token, ask)
	local funcs = cfg.opts().ask_functions
	local opts = {
		prompt = ask.title or token,
	}
	if ask.type == "function" and funcs[ask.default] then
		local ok, default = pcall(funcs[ask.default])
		opts.default = ok and default or ""
	else
		opts.default = ask.default or ""
	end
	return opts
end

--  TODO: 2024-02-28 - Can this be made async or use plenary job?
local ask_tokens = function(selection)
	if selection.ask then
		for k, v in pairs(selection.ask) do
			if selection.cmd:find(k) then
				vim.ui.input(get_input_opts(k, v), function(input)
					if input then
						selection.cmd = utils.escaped_replace(selection.cmd, k, input)
						vim.print(selection.cmd)
					end
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
	return task
end

return Token
