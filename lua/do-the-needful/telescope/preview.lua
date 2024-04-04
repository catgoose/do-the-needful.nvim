local const = require("do-the-needful.constants").get()
local utils = require("do-the-needful.utils")
local sf = utils.string_format
local Log = require("do-the-needful").Log

---@class Preview
---@field render fun(task: table)
---@return Preview
local M = {}

function M.render(task)
	local fields = {}
	local lines = { "{" }
	for _, f in pairs(const.task_preview_field_order) do
		table.insert(fields, { f, task[f] })
	end
	for _, f in pairs(fields) do
		if f[2] then
			local rows = utils.split_string(vim.inspect(f[2]), "\n")
			if type(f[2]) == "string" then
				table.insert(lines, sf('  %s = "%s",', f[1], f[2]))
			else
				for i, l in pairs(rows) do
					if i == 1 then
						table.insert(lines, sf("  %s = %s", f[1], l))
					else
						table.insert(lines, sf("  %s", l))
					end
				end
				lines[#lines] = sf("%s,", lines[#lines])
			end
		end
	end
	lines[#lines] = lines[#lines]:sub(1, -2)
	table.insert(lines, "}")
	Log.trace(
		sf(
			"task.task_preview(): using field order: %s for task %s to create lines %s to be used for preview",
			const.task_preview_field_order,
			task,
			lines
		)
	)
	return lines
end

return M
