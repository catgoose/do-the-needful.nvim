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

---@class TmuxWindow
---@field name? string
---@field close? boolean
---@field keep_current? boolean
---@field open_relative? boolean
---@field relative? relative
---@enum relative "before" "after"

---@class Collect
---@func collect_tasks(): Task[]
---@return Collect
Collect = {}

---@fun add_source_to_tasks(tasks: TaskConfig[], source: string): TaskConfig[]
local add_source_to_tasks = function(tasks, source)
	for _, t in pairs(tasks) do
		t.source = source
	end
	Log.trace(sf("tasks._add_source_to_tasks(): adding source %s to tasks %s", source, tasks))
	return tasks
end

local function validate_tasks_and_add_source(tasks, config_tasks, source)
	if not config_tasks then
		return
	end
	local with_source = add_source_to_tasks(config_tasks, source)
	local validated = validate.tasks(with_source)
	vim.list_extend(tasks, validated)
end

local function aggregate_tasks()
	local tasks = {}
	local configs = get_opts().configs
	Log.trace(sf("tasks._aggregate_tasks(): parsing configs: %s", configs))
	for _, source in pairs(get_opts().config_order) do
		local path = configs[source].path
		if path then
			local from_json = utils.json_from_path(path)
			if from_json then
				Log.trace(sf("tasks._aggregate_tasks(): composing task: %s from path %s", from_json, path))
				validate_tasks_and_add_source(tasks, from_json.tasks, source)
			end
		else
			validate_tasks_and_add_source(tasks, configs[source].tasks, source)
		end
	end
	Log.debug(sf("tasks._aggregate_tasks(): tasks %s", tasks))
	return tasks
end

---@return TaskConfig[]
function Collect.collect_tasks()
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

return Collect
