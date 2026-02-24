local dtn = require("do-the-needful")
local sf = require("do-the-needful.utils").string_format
local get_opts = require("do-the-needful.config").get_opts

---@class FzfLuaPicker: PickerProvider
local M = {}

M.name = "fzf_lua"

function M.is_available()
  local ok = pcall(require, "fzf-lua")
  return ok
end

local function format_task_entry(task)
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

function M.pick_task(tasks, on_select, _)
  local fzf = require("fzf-lua")
  local entries = {}
  local task_map = {}
  for _, task in ipairs(tasks) do
    local entry = format_task_entry(task)
    entries[#entries + 1] = entry
    task_map[entry] = task
  end
  fzf.fzf_exec(entries, {
    prompt = "Do the needful> ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local task = task_map[selected[1]]
          if task then
            dtn.Log.trace(sf("picker.fzf_lua: selected task %s", task))
            on_select(task)
          end
        end
      end,
    },
  })
end

function M.pick_action(action_list, on_select, _)
  local fzf = require("fzf-lua")
  local entries = {}
  local action_map = {}
  for _, action in ipairs(action_list) do
    entries[#entries + 1] = action[1]
    action_map[action[1]] = action
  end
  fzf.fzf_exec(entries, {
    prompt = "do-the-needful actions> ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local action = action_map[selected[1]]
          if action then
            on_select(action)
          end
        end
      end,
    },
  })
end

return M
