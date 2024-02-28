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
			Log.debug("tasks._compose_task(): json returned from decode_json is nil")
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
		Log.debug(string.format("tasks._compose_task(): %s does not exist", f_handle.filename))
		return {}
	end
end

local function parse_tokens(tasks)
	for _, task in pairs(tasks) do
		for field, token in pairs(opts().global_tokens) do
			if task[field] then
				for k, v in pairs(token) do
					task[field] = task[field]:gsub(k, v)
					Log.trace(
						string.format(
							"tasks._parse_tokens(): parsing token key %s, token value %s for field %s",
							k,
							v,
							field
						)
					)
				end
			end
		end
	end
end

local function aggregate_tasks()
	local tasks = {}
	local configs = opts().configs
	for _, c in pairs(opts().config_order) do
		local path = configs[c].path
		if path then
			local f_handle = Path:new(path)
			local _tasks = tasks_from_json(f_handle, tasks)
			vim.list_extend(tasks, _tasks)
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
	parse_tokens(tasks)
	return tasks
end

function Tasks.collect_tasks()
	local tasks = {}
	for _, t in pairs(aggregate_tasks()) do
		--  TODO: 2024-02-27 - look into why this is necessary
		table.insert(tasks, vim.tbl_deep_extend("keep", t, const.task_defaults))
		Log.debug(
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
	local lines = {}
	for _, f in pairs(const.field_order) do
		table.insert(fields, { f, task[f] })
	end
	for _, f in pairs(fields) do
		local items = split(ins(f[2]), ", ")
		local rows = split(ins(f[2]), "\n")
		if type(f[2]) == "string" then
			table.insert(lines, f[1] .. " = " .. '"' .. f[2] .. '"')
		elseif not string.match(ins(f[2]), "\n") then
			if #f[2] > const.wrap_fields_at then
				for i, l in pairs(items) do
					if i == 1 then
						table.insert(lines, f[1] .. " = {")
					elseif i == #items then
						local last = split(l, " }")
						table.insert(lines, "\t" .. last[1])
						table.insert(lines, "}")
					else
						table.insert(lines, "\t" .. l .. ",")
					end
				end
			else
				table.insert(lines, f[1] .. " = " .. ins(f[2]))
			end
		else
			for i, l in pairs(rows) do
				if i == 1 then
					table.insert(lines, f[1] .. " = " .. l)
				else
					table.insert(lines, "\t" .. l)
				end
			end
		end
	end
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
