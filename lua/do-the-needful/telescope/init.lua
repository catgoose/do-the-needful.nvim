local finders = require("telescope.finders")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local collect = require("do-the-needful.collect")
local const = require("do-the-needful.constants").get()
local edit = require("do-the-needful.edit")
local pickers = require("telescope.pickers")
local tmux = require("do-the-needful.tmux")
local tokens = require("do-the-needful.tokens")
local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format
local util = require("do-the-needful.telescope.util")

---@class Telescope
---@field action_picker fun(opts: table)
---@field tasks fun(opts: table)
---@return Telescope
local M = {}

function M.tasks(opts)
  opts = util.get_telescope_opts(opts)
  local tasks = collect.tasks()
  local tasks_opts = const.telescope_opts.tasks
  pickers
    .new(opts, {
      prompt_title = "Do the needful",
      layout_config = tasks_opts.layout_config,
      finder = finders.new_table({
        results = tasks,
        entry_maker = util.entry_maker,
      }),
      sorter = conf.generic_sorter(),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end
          tokens.replace(selection.value, function(task)
            Log.trace(sf("task_picker: opening task %s", task))
            tmux.run(task)
          end)
        end)
        return true
      end,
      previewer = util.task_previewer(),
    })
    :find()
end

function M.actions(opts)
  opts = util.get_telescope_opts(opts)
  local selections = {
    { "Edit project config", edit.edit_config, "project" },
    { "Edit global config", edit.edit_config, "global" },
    { "Do the needful", M.tasks, opts },
  }
  local actions_opts = const.telescope_opts.actions
  actions_opts.layout_config.height = #selections + 4
  pickers
    .new(opts, {
      prompt_title = "do-the-needful actions",
      layout_strategy = actions_opts.layout_strategy,
      layout_config = actions_opts.layout_config,
      finder = finders.new_table({
        results = selections,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry[1],
            ordinal = entry[1],
          }
        end,
      }),
      sorter = conf.generic_sorter(),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local s = selection.value
          s[2](s[3])
        end)
        return true
      end,
    })
    :find()
end

return M
