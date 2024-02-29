local Path = require("plenary.path")
local opts = require("do-the-needful.config").opts
local Log = require("do-the-needful").Log
local const = require("do-the-needful.constants").val
local ins = vim.inspect

Tasks = {}

local split = function(var, str)
	str = str or " "
	return vim.split(var, str, { plain = true, trimempty = true })
end

local function decode_json(f_handle)
	local contents = f_handle:read()
	local ok, json = pcall(vim.json.decode, contents)
	if not ok then
		if #contents == 0 then
			Log.warn(string.format("tasks._decode_json(): %s is an empty file", f_handle.filename))
		else
			Log.error(string.format("tasks._decode_json(): invalid json decoded from file: %s", f_handle.filename))
		end
	end
	Log.trace(string.format("tasks._decode_json(): decoding json for file %s: %s", f_handle.filename, ins(json)))
	return ok and json or nil
end

local tasks_from_json = function(f_handle, tasks)
	if f_handle:exists() then
		local json = decode_json(f_handle)
		if not json then
			Log.warn("tasks._compose_task(): json returned from decode_json is nil")
			return {}
		end
		Log.trace(
			string.format(
				"tasks._compose_task(): composing task for file %s and tasks %s",
				f_handle.filename,
				ins(tasks)
			)
		)
		return json.tasks
	else
		return {}
	end
end

local function aggregate_tasks()
	local tasks = {}
	local configs = opts().configs
	for _, c in pairs(opts().config_order) do
		local path = configs[c].path
		if path then
			local f_handle = Path:new(path)
			local json_tasks = tasks_from_json(f_handle, tasks)
			vim.list_extend(tasks, json_tasks)
			Log.trace(
				string.format(
					"tasks._aggregate_tasks(): composing task: %s from file %s",
					ins(tasks),
					f_handle.filename
				)
			)
		else
			vim.list_extend(tasks, configs[c].tasks)
		end
	end
	Log.trace(string.format("tasks._aggregate_tasks(): parsing configs: %s", configs))
	return tasks
end

function Tasks.collect_tasks()
	local tasks = {}
	for _, t in pairs(aggregate_tasks()) do
		table.insert(tasks, vim.tbl_deep_extend("keep", t, const.task_defaults))
		Log.trace(
			string.format(
				"tasks.collect_tasks(): inserting aggregated tasks %s into %s with defaults %s",
				ins(t),
				ins(tasks),
				ins(const.task_defaults)
			)
		)
	end
	return tasks
end

function Tasks.task_preview(task)
	local fields = {}
	local lines = { "{" }
	for _, f in pairs(const.field_order) do
		table.insert(fields, { f, task[f] })
	end
	for _, f in pairs(fields) do
		if f[2] then
			local rows = split(ins(f[2]), "\n")
			if type(f[2]) == "string" then
				table.insert(lines, string.format('  %s = "%s",', f[1], f[2]))
			else
				for i, l in pairs(rows) do
					if i == 1 then
						table.insert(lines, string.format("  %s = %s", f[1], l))
					else
						table.insert(lines, string.format("  %s", l))
					end
				end
			end
		end
	end
	table.insert(lines, "}")
	Log.trace(
		string.format(
			"task.task_preview(): using field order: %s for task %s to create lines %s to be used for preview",
			ins(const.field_order),
			ins(task),
			ins(lines)
		)
	)
	return lines
end

return Tasks
