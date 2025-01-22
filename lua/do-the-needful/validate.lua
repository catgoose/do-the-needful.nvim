local Log = require("do-the-needful").Log
local const = require("do-the-needful.constants").get()
local sf = require("do-the-needful.utils").string_format
local deep_copy = require("do-the-needful.utils").deep_copy

---@class Validate
---@field collection fun(configs: TaskConfig[]): TaskConfig[]
---@return Validate
local M = {}

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

local function validate_name(config)
  if not config.name or #config.name == 0 then
    local name = string.format("Unnamed %s", config.type)
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
    Log.warn(
      sf(
        "Task has an invalid window property: relative. Expecting one of %s. task: %s",
        relative,
        task
      )
    )
    window.relative = nil
  end
end

local function merge_defaults(config)
  local defaults = const.task_defaults
  Log.debug(sf(
    [[validate._merge_defaults:
Merging:

config:%s

with defaults: %s]],
    config,
    defaults
  ))
  local merged_defaults = vim.tbl_deep_extend("keep", config, deep_copy(defaults))
  Log.debug(sf(
    [[validate._merge_defaults:
Merged:

config: %s

merged_defaults: %s]],
    config,
    merged_defaults
  ))
  merged_defaults.window.name = merged_defaults.window.name or merged_defaults.name
  return merged_defaults
end

function M.tasks(tasks)
  ---@type relative
  local relative = { "after", "before" }

  local remove = {}
  for i, task in pairs(tasks) do
    if not validate_task_cmd(task, i) then
      remove[#remove + 1] = i
    else
      validate_name(task)
      validate_tags(task)
      validate_window(task, relative)
      tasks[i] = merge_defaults(task)
    end
  end
  for _, index in ipairs(remove) do
    tasks[index] = nil
  end

  return deep_copy(tasks)
end

return M
