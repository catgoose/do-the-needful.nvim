local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format

---@class TelescopePicker: PickerProvider
local M = {}

M.name = "telescope"

---@tag do-the-needful.picker.telescope.is_available
function M.is_available()
  local ok = pcall(require, "telescope")
  return ok
end

---@tag do-the-needful.picker.telescope.pick_task
function M.pick_task(tasks, on_select, opts)
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local pickers = require("telescope.pickers")
  local util = require("do-the-needful.telescope.util")
  local const = require("do-the-needful.constants").get()

  opts = util.get_telescope_opts(opts)
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
          dtn.Log.trace(sf("picker.telescope: selected task %s", selection.value))
          on_select(selection.value)
        end)
        return true
      end,
      previewer = util.task_previewer(),
    })
    :find()
end

---@tag do-the-needful.picker.telescope.pick_action
function M.pick_action(action_list, on_select, opts)
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local pickers = require("telescope.pickers")
  local util = require("do-the-needful.telescope.util")
  local const = require("do-the-needful.constants").get()

  opts = util.get_telescope_opts(opts)
  local actions_opts = const.telescope_opts.actions
  actions_opts.layout_config.height = #action_list + 4
  pickers
    .new(opts, {
      prompt_title = "do-the-needful actions",
      layout_strategy = actions_opts.layout_strategy,
      layout_config = actions_opts.layout_config,
      finder = finders.new_table({
        results = action_list,
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
          on_select(selection.value)
        end)
        return true
      end,
    })
    :find()
end

return M
