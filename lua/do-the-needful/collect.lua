local get_opts = require("do-the-needful.config").get_opts
local Log = require("do-the-needful").Log
local utils = require("do-the-needful.utils")
local validate = require("do-the-needful.validate")
local sf = utils.string_format

---@class TaskConfig
---@field name? string
---@field cmd? string
---@field cwd? string
---@field tags? string[]
---@field ask? table
---@field window? MultiplexWindow
---@field source? Source
---@enum Source
---| "global"
---| "project"
---| "opts"

---@class MultiplexWindow
---@field name? string
---@field close? boolean
---@field keep_current? boolean
---@field open_relative? boolean
---@field relative? Relative
---@enum Relative
---| "before"
---| "after"

---@class Collect
---@field tasks fun(): TaskConfig[]
---@return Collect
local M = {}

local function add_metadata(tasks, task_config, source)
  if not task_config or not task_config.tasks then
    Log.warn(sf("collect._add_metadata(): no tasks found in config %s", task_config))
    return
  end
  for _, task in pairs(task_config.tasks) do
    task.source = source
    Log.trace(sf("collect._add_metadata(): adding source '%s' to task %s", source, task))
    table.insert(tasks, task)
  end
end

function M.tasks()
  local tasks = {}
  local sources = get_opts().configs
  Log.trace(sf("collect.configs(): parsing configs: %s", sources))
  for _, source in pairs(get_opts().config_order) do
    local path = sources[source].path
    if path then
      local from_json = utils.json_from_path(path)
      if from_json then
        Log.trace(sf("collect.configs(): composing task: %s from path %s", from_json, path))
        add_metadata(tasks, from_json, source)
      end
    else
      add_metadata(tasks, sources[source], source)
    end
  end
  tasks = validate.tasks(tasks)
  Log.debug(sf("collect.configs(): collection %s", tasks))
  return tasks
end

return M
