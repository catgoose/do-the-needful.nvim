local warn = require("do-the-needful.logger").warn
local ins = vim.inspect

---@class Validate
---@field tasks fun(tasks: TaskConfig[]): TaskConfig[]
Validate = {}

Validate.tasks = function(tasks)
	---@type relative
	local relative = { "after", "before" }
	for ti, t in pairs(tasks) do
		if not t.cmd or #t.cmd == 0 then
			warn(
				string.format(
					"tasks.validate_tasks(): task %s is missing a cmd. Excluding task from aggregation",
					ins(t)
				)
			)
			tasks[ti] = nil
			break
		end
		if not t.name then
			local unknown = "Unknown task"
			warn(
				string.format(
					"tasks.validate_tasks(): task %s is missing a name.  Setting value to %s",
					ins(t),
					unknown
				)
			)
			t.name = unknown
		end
		if t.tags and #t.tags == 0 or t.tags[1] == "" then
			t.tags = nil
		end
		if t.tags and type(t.tags) ~= "table" then
			warn(
				string.format(
					"tasks.validate_tasks(): task %s has an invalid tags property: %s.  Expecting a table",
					ins(t),
					ins(t.tags)
				)
			)
			t.tags = nil
		end
		for tgi, tag in ipairs(t.tags) do
			if type(tag) ~= "string" then
				warn(
					string.format(
						"tasks.validate_tasks(): task %s has an invalid tag: %s.  Converting to string",
						ins(t),
						ins(tag)
					)
				)
				t.tags[tgi] = tostring(tag)
			end
		end
		if t.window and t.window.name and #t.window.name == 0 then
			t.window.name = nil
		end
		if t.window and t.window.close and type(t.window.close) ~= "boolean" then
			t.window.close = nil
		end
		if t.window and t.window.keep_current and type(t.window.keep_current) ~= "boolean" then
			t.window.keep_current = nil
		end
		if t.window and t.window.open_relative and type(t.window.open_relative) ~= "boolean" then
			t.window.open_relative = nil
		end
		if t.window and t.window.relative and not vim.tbl_contains(relative, t.window.relative) then
			warn(
				string.format(
					"tasks.validate_tasks(): task %s has an invalid window property: relative.  Expecting one of %s",
					ins(t),
					ins(relative)
				)
			)
			t.window.relative = nil
		end
	end
	return tasks
end

return Validate
