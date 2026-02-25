local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format
local get_opts = require("do-the-needful.config").get_opts

---@class UiSelectPicker: PickerProvider
local M = {}

M.name = "ui_select"

---@tag do-the-needful.picker.ui_select.is_available
function M.is_available()
  return true
end

local function format_task(task)
  local parts = { task.name }
  if task.tags and #task.tags > 0 then
    for _, tag in ipairs(task.tags) do
      table.insert(parts, "#" .. tag)
    end
  end
  if get_opts().tag_source then
    table.insert(parts, "#" .. task.source)
  end
  return table.concat(parts, " ")
end

---@tag do-the-needful.picker.ui_select.pick_task
function M.pick_task(tasks, on_select, _)
  vim.ui.select(tasks, {
    prompt = "Do the needful:",
    format_item = format_task,
  }, function(choice)
    if choice then
      dtn.Log.trace(sf("picker.ui_select: selected task %s", choice))
      on_select(choice)
    end
  end)
end

---@tag do-the-needful.picker.ui_select.pick_action
function M.pick_action(action_list, on_select, _)
  vim.ui.select(action_list, {
    prompt = "do-the-needful actions:",
    format_item = function(item)
      return item[1]
    end,
  }, function(choice)
    if choice then
      on_select(choice)
    end
  end)
end

return M
