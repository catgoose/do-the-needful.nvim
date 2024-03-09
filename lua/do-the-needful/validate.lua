local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format

---@class Validate
---@field collection fun(configs: CollectionConfig[]): CollectionConfig[]
---@return Validate
Validate = {}

local function validate_task_cmd(task, index)
	if not task.cmd or #task.cmd == 0 or type(task.cmd) ~= "string" then
		Log.warn(
			sf(
				"validate._validate_task_cmd: Task %s is missing a cmd. Excluding task from aggregation: %s",
				index,
				task
			)
		)
		return false
	end
	return true
end

local function validate_job_tasks(job, index)
	if not job.tasks or #job.tasks == 0 or type(job.tasks) ~= "table" then
		Log.warn(
			sf(
				"validate._validate_job_tasks: Job %s is missing a task list. Excluding job from aggregation: %s",
				index,
				job
			)
		)
		return false
	end
	return true
end

local function validate_name(config)
	if not config.name or #config.name == 0 then
		local name = string.format("Unknown %s", config.type)
		config.name = name
		Log.warn(
			sf(
				"validate._validate_name: %s is missing a name. Setting value to '%s'.  %s: %s",
				config.type,
				name,
				config.type,
				config
			)
		)
	end
end

local function validate_tags(config)
	if config.tags then
		if #config.tags == 0 or config.tags[1] == "" then
			config.tags = nil
		elseif type(config.tags) ~= "table" then
			Log.warn(
				sf(
					"validate._validate_tags: %s has an invalid tags property. Expecting a table. task: %s",
					config.type,
					config
				)
			)
			config.tags = nil
		else
			for i, tag in ipairs(config.tags) do
				if type(tag) ~= "string" then
					Log.warn(
						sf(
							"validate.validate_tags: %s has an invalid tag. Converting to string. task: %s",
							config.type,
							config
						)
					)
					config.tags[i] = tostring(tag)
				end
			end
		end
	end
end

local function validate_window(task, relative)
	local window = task.window
	if not window then
		return
	end
	if window.name and #window.name == 0 then
		window.name = nil
	end
	local properties = { "close", "keep_current", "open_relative" }
	for _, prop in ipairs(properties) do
		if window[prop] and type(window[prop]) ~= "boolean" then
			window[prop] = nil
		end
	end
	if window.relative and not vim.tbl_contains(relative, window.relative) then
		Log.warn(sf("Task has an invalid window property: relative. Expecting one of %s. task: %s", relative, task))
		window.relative = nil
	end
end

local get_validation_func = function(type)
	return type == "tasks" and validate_task_cmd
		or type == "jobs" and validate_job_tasks
		or function()
			Log.warn(sf("validate.get_validation_func: No validation function found for type: %s", type))
			return false
		end
end

Validate.collection = function(collection)
	---@type relative
	local relative = { "after", "before" }

	for type, config in pairs(collection) do
		local remove = {}

		for i, cfg in pairs(config) do
			if not get_validation_func(type)(cfg, i) then
				remove[#remove + 1] = i
			else
				validate_name(cfg)
				validate_tags(cfg)
				validate_window(cfg, relative)
			end
		end

		for _, index in ipairs(remove) do
			config[index] = nil
		end
	end
end

return Validate
