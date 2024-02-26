local Path = require("plenary.path")
local cfg = require("do-the-needful.config")
local opts = cfg.opts
local ins = vim.inspect
local log = require("do-the-needful.log").log

local M = {}

local split = function(var, str)
	str = str or " "
	return vim.split(var, str, { plain = true, trimempty = true })
end

local function decode_json(f_handle)
	local contents = f_handle:read()
	local ok, json = pcall(vim.json.decode, contents)
	if not ok then
		if #contents == 0 then
			log.warn(string.format("tasks._decode_json(): %s is an empty file", f_handle.filename))
		else
			log.error(string.format("tasks._decode_json(): invalid json decoded from file: %s", f_handle.filename))
		end
	end
	log.trace(string.format("tasks._decode_json(): decoding json for file %s: %s", f_handle.filename, ins(json)))
	return ok and json or nil
end

local compose_task = function(f_handle, tasks)
	if f_handle:exists() then
		local json = decode_json(f_handle)
		if not json then
			log.debug("tasks._compose_task(): json returned from decode_json is nil")
			return {}
		end
		vim.list_extend(tasks, json.tasks)
		log.trace(
			string.format(
				"tasks._compose_task(): composing task for file %s and tasks %s",
				f_handle.filename,
				ins(tasks)
			)
		)
	end
	return tasks
end

local function tasks_from_configs()
	local tasks = {}
	local configs = opts().configs
	--  TODO: 2024-02-26 - Handle opts defined tasks
	for _, c in pairs(opts().config_order) do
		local f_handle = Path:new(configs[c])
		tasks = compose_task(f_handle, tasks)
		log.trace(
			string.format("tasks._tasks_from_configs(): composing task: %s from file %s", ins(tasks), f_handle.filename)
		)
	end
	log.trace(string.format("tasks._tasks_from_configs(): parsing configs: %s", configs))
	return tasks
end

local function parse_tokens(tasks)
	for _, task in pairs(tasks) do
		for field, token in pairs(opts().global_tokens) do
			if task[field] then
				for k, v in pairs(token) do
					task[field] = task[field]:gsub(k, v)
					log.trace(
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
	vim.list_extend(tasks, tasks_from_configs())
	vim.list_extend(tasks, opts().tasks)
	parse_tokens(tasks)
	return tasks
end

function M.collect_tasks()
	local tasks = {}
	for _, t in pairs(aggregate_tasks()) do
		table.insert(tasks, vim.tbl_deep_extend("keep", t, cfg.task_defaults))
		log.trace(
			string.format(
				"tasks.collect_tasks(): inserting aggregated tasks %s into %s with defaults %s",
				ins(t),
				ins(tasks),
				ins(cfg.task_defaults)
			)
		)
	end
	return tasks
end

function M.task_preview(task)
	local fields = {}
	local lines = {}
	for _, f in pairs(cfg.field_order) do
		table.insert(fields, { f, task[f] })
	end
	for _, f in pairs(fields) do
		local items = split(ins(f[2]), ", ")
		local rows = split(ins(f[2]), "\n")
		if type(f[2]) == "string" then
			table.insert(lines, f[1] .. " = " .. '"' .. f[2] .. '"')
		elseif not string.match(ins(f[2]), "\n") then
			if #f[2] > cfg.wrap_fields_at then
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
	log.trace(
		string.format(
			"task.task_preview(): using field order: %s for task %s to create lines %s to be used for preview",
			ins(cfg.field_order),
			ins(task),
			ins(lines)
		)
	)
	return lines
end

return M
