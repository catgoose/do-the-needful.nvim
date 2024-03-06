local Path = require("plenary.path")
local get_opts = require("do-the-needful.config").get_opts
local const = require("do-the-needful.constants").val
local Log = require("do-the-needful").Log
local utils = require("do-the-needful.utils")
local validate = require("do-the-needful.validate")
local sf = utils.string_format

---@class TaskConfig
---@field name? string
---@field cmd? string
---@field cwd? string
---@field tags? string[]
---@field window? TmuxWindow
---@field source? source
---@enum source "global" | "project" | "opts"

---@class Tasks
---@func collect_tasks(): Task[]
---@func task_preview(task: Task): string[]
---@return Tasks
Tasks = {}

local function decode_json(f_handle)
	local contents = f_handle:read()
	local ok, json = pcall(vim.json.decode, contents)
	if not ok then
		if #contents == 0 then
			Log.warn(sf("tasks._decode_json(): %s is an empty file", f_handle.filename))
		else
			error(sf("tasks._decode_json(): invalid json decoded from file: %s", f_handle.filename))
		end
	end
	Log.trace(sf("tasks._decode_json(): decoding json for file %s: %s", f_handle.filename, json))
	return ok and json or nil
end

---@fun tasks_from_json(f_handle: Path, tasks: Task[]): Task[]
local tasks_from_json = function(f_handle, tasks)
	if f_handle:exists() then
		local json = decode_json(f_handle)
		if not json then
			Log.warn("tasks._compose_task(): json returned from decode_json is nil. tasks: %s", tasks)
			return nil
		end
		Log.trace(sf("tasks._compose_task(): composing task for file %s withs tasks %s", f_handle.filename, tasks))
		return json.tasks or json or nil
	else
		return nil
	end
end

---@fun add_source_to_tasks(tasks: Task[], source: string): Task[]
local add_source_to_tasks = function(tasks, source)
	for _, t in pairs(tasks) do
		t.source = source
	end
	Log.trace(sf("tasks._add_source_to_tasks(): adding source %s to tasks %s", source, tasks))
	return tasks
end

local function aggregate_tasks()
	local tasks = {}
	local configs = get_opts().configs
	Log.trace(sf("tasks._aggregate_tasks(): parsing configs: %s", configs))
	for _, c in pairs(get_opts().config_order) do
		local path = configs[c].path
		if path then
			local f_handle = Path:new(path)
			local from_json = tasks_from_json(f_handle, tasks)
			if from_json then
				local with_source = add_source_to_tasks(from_json, c)
				local validated = validate.tasks(with_source)
				vim.list_extend(tasks, validated)
				Log.trace(sf("tasks._aggregate_tasks(): composing task: %s from file %s", tasks, f_handle.filename))
			end
		else
			vim.list_extend(tasks, add_source_to_tasks(configs[c].tasks, c))
		end
	end
	Log.debug(sf("tasks._aggregate_tasks(): tasks %s", tasks))
	return tasks
end

---@return TaskConfig[]
function Tasks.collect_tasks()
	local tasks = {}
	for _, t in pairs(aggregate_tasks()) do
		table.insert(tasks, vim.tbl_deep_extend("keep", t, const.task_defaults))
		Log.trace(
			sf(
				"tasks.collect_tasks(): inserting aggregated tasks %s into %s with defaults %s",
				t,
				tasks,
				const.task_defaults
			)
		)
	end
	return tasks
end

---@param task TaskConfig
---@return string[]
function Tasks.task_preview(task)
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

return Tasks
