local collect = require("do-the-needful.collect")
local edit = require("do-the-needful.edit")
local tokens = require("do-the-needful.tokens")
local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format

---@class Telescope
---@field tasks fun(opts: table)
---@field actions fun(opts: table)
---@return Telescope
local M = {}

local function run_task(task)
  local state = require("do-the-needful.state")
  local runner = require("do-the-needful.runner")
  state.set_last_task(task)
  runner.run(task)
end

function M.tasks(opts)
  local telescope_picker = require("do-the-needful.picker.telescope")
  local tasks = collect.tasks()
  telescope_picker.pick_task(tasks, function(selection)
    tokens.replace(selection, function(task)
      dtn.Log.trace(sf("telescope.tasks: running task %s", task))
      run_task(task)
    end)
  end, opts)
end

function M.actions(opts)
  local telescope_picker = require("do-the-needful.picker.telescope")
  local selections = {
    { "Edit project config", edit.edit_config, "project" },
    { "Edit global config", edit.edit_config, "global" },
    { "Do the needful", M.tasks, opts },
  }
  telescope_picker.pick_action(selections, function(action)
    action[2](action[3])
  end, opts)
end

return M
