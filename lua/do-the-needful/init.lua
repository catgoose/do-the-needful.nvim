---@mod do-the-needful Do The Needful
---@tag do-the-needful.nvim
---@brief [[
---Task runner with multiple picker and runner backends.
---Pick a task, run it anywhere.
---
---Requires Neovim >= 0.10
---
---Usage:
---
--->lua
---  require("do-the-needful").setup({
---    tasks = {
---      { name = "build", cmd = "make build", tags = { "build" } },
---    },
---  })
---<
---
---COMMANDS ~
---
---  `:Needful [tags...]`       Open task picker, optionally filter by tags
---  `:NeedfulRerun`            Re-run the last executed task
---  `:NeedfulRun <name>`       Run a task by name (tab completion supported)
---  `:NeedfulEdit [scope]`     Edit project or global config
---
---LUA API ~
---
--->lua
---  require("do-the-needful").please()                    -- open picker
---  require("do-the-needful").please({ tags = {"build"} }) -- filter by tags
---  require("do-the-needful").actions()                   -- actions picker
---  require("do-the-needful").rerun()                     -- re-run last task
---  require("do-the-needful").run_by_name("tests")        -- run by name
---  require("do-the-needful").edit_config("project")      -- edit config
---<
---@brief ]]

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

--- Setup do-the-needful with user options.
---@param opts? Opts User configuration, merged with defaults
function M.setup(opts)
  opts = opts or {}
  cfg.init(opts)
  M.Log = require("do-the-needful.logger").init()
  require("do-the-needful.commands").register()
end

---@tag do-the-needful.edit_config
--- Edit a task config file.
---@param opts? string Config scope: "project" (default) or "global"
function M.edit_config(opts)
  opts = opts or "project"
  require("do-the-needful.edit").edit_config(opts)
end

--- Open the task picker. Optionally filter by tags.
---@param opts? table Options table, supports `tags` key for filtering
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

---@tag do-the-needful.actions
--- Open the actions picker (edit config, run tasks, etc).
---@param opts? table Picker options
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

--- Re-run the last executed task.
function M.rerun()
  local state = require("do-the-needful.state")
  local last = state.get_last_task()
  if not last then
    vim.notify("[do-the-needful] No previous task to re-run", vim.log.levels.WARN)
    return
  end
  run_task(last)
end

--- Run a task by its name directly, without opening a picker.
---@param name string The task name to match
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
