local cfg = require("do-the-needful.config")

---@class DoTheNeedful
---@field setup fun(opts: table)
---@field telescope_setup fun(opts: table)
---@field Log Logger
---@field edit_config fun(opts: source)
---@field please fun(opts?: table)
---@field actions fun(opts?: table)
---@field rerun fun()
---@field run_by_name fun(name: string)
---@return DoTheNeedful
local M = {}

local function run_task(task)
  local state = require("do-the-needful.state")
  local runner = require("do-the-needful.runner")
  state.set_last_task(task)
  runner.run(task)
end

local function collect_tasks(opts)
  local collect = require("do-the-needful.collect")
  local tasks = collect.tasks()
  if opts and opts.tags and #opts.tags > 0 then
    local filtered = {}
    for _, task in ipairs(tasks) do
      if task.tags then
        for _, filter_tag in ipairs(opts.tags) do
          if vim.tbl_contains(task.tags, filter_tag) then
            table.insert(filtered, task)
            break
          end
        end
      end
    end
    tasks = filtered
  end
  return tasks
end

function M.setup(opts)
  opts = opts or {}
  cfg.init(opts)
  M.Log = require("do-the-needful.logger").init()
  require("do-the-needful.commands").register()
end

function M.edit_config(opts)
  opts = opts or "project"
  require("do-the-needful.edit").edit_config(opts)
end

function M.please(opts)
  local tokens = require("do-the-needful.tokens")
  local picker = require("do-the-needful.picker")
  local tasks = collect_tasks(opts)
  picker.pick_task(tasks, function(selection)
    tokens.replace(selection, function(task)
      M.Log.trace(
        require("do-the-needful.utils").string_format("init.please: running task %s", task)
      )
      run_task(task)
    end)
  end, opts)
end

function M.actions(opts)
  local edit = require("do-the-needful.edit")
  local picker = require("do-the-needful.picker")
  local selections = {
    { "Edit project config", edit.edit_config, "project" },
    { "Edit global config", edit.edit_config, "global" },
    { "Do the needful", M.please, opts },
  }
  picker.pick_action(selections, function(action)
    action[2](action[3])
  end, opts)
end

function M.rerun()
  local state = require("do-the-needful.state")
  local last = state.get_last_task()
  if not last then
    vim.notify("[do-the-needful] No previous task to re-run", vim.log.levels.WARN)
    return
  end
  run_task(last)
end

function M.run_by_name(name)
  local tokens = require("do-the-needful.tokens")
  local tasks = collect_tasks()
  for _, task in ipairs(tasks) do
    if task.name == name then
      tokens.replace(task, function(resolved)
        run_task(resolved)
      end)
      return
    end
  end
  vim.notify(
    string.format("[do-the-needful] Task not found: %s", name),
    vim.log.levels.WARN
  )
end

return M
