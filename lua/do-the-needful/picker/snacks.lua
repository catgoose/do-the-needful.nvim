local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format
local get_opts = require("do-the-needful.config").get_opts

---@class SnacksPicker: PickerProvider
local M = {}

M.name = "snacks"

---@tag do-the-needful.picker.snacks.is_available
function M.is_available()
  local ok, snacks = pcall(require, "snacks")
  return ok and snacks.picker ~= nil
end

local function format_task_text(task)
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

---@tag do-the-needful.picker.snacks.pick_task
function M.pick_task(tasks, on_select, _)
  local snacks = require("snacks")
  local items = {}
  for i, task in ipairs(tasks) do
    items[#items + 1] = {
      idx = i,
      text = format_task_text(task),
      task = task,
    }
  end
  snacks.picker.pick({
    title = "Do the needful",
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        dtn.Log.trace(sf("picker.snacks: selected task %s", item.task))
        on_select(item.task)
      end
    end,
  })
end

---@tag do-the-needful.picker.snacks.pick_action
function M.pick_action(action_list, on_select, _)
  local snacks = require("snacks")
  local items = {}
  for i, action in ipairs(action_list) do
    items[#items + 1] = {
      idx = i,
      text = action[1],
      action = action,
    }
  end
  snacks.picker.pick({
    title = "do-the-needful actions",
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        on_select(item.action)
      end
    end,
  })
end

return M
