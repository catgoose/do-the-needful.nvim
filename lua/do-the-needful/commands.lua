local M = {}

local function get_task_names()
  local collect = require("do-the-needful.collect")
  local tasks = collect.tasks()
  local names = {}
  for _, task in ipairs(tasks) do
    if task.name then
      names[#names + 1] = task.name
    end
  end
  return names
end

local function get_all_tags()
  local collect = require("do-the-needful.collect")
  local tasks = collect.tasks()
  local tag_set = {}
  for _, task in ipairs(tasks) do
    if task.tags then
      for _, tag in ipairs(task.tags) do
        tag_set[tag] = true
      end
    end
  end
  local tags = {}
  for tag in pairs(tag_set) do
    tags[#tags + 1] = tag
  end
  table.sort(tags)
  return tags
end

function M.register()
  vim.api.nvim_create_user_command("Needful", function(cmd_opts)
    local dtn = require("do-the-needful")
    local tags = {}
    if cmd_opts.fargs and #cmd_opts.fargs > 0 then
      tags = cmd_opts.fargs
    end
    dtn.please({ tags = #tags > 0 and tags or nil })
  end, {
    nargs = "*",
    complete = function(arg_lead, _, _)
      local tags = get_all_tags()
      if arg_lead == "" then
        return tags
      end
      return vim.tbl_filter(function(tag)
        return tag:find(arg_lead, 1, true) == 1
      end, tags)
    end,
    desc = "Open do-the-needful picker, optionally filter by tags",
  })

  vim.api.nvim_create_user_command("NeedfulRerun", function()
    require("do-the-needful").rerun()
  end, {
    desc = "Re-run the last executed task",
  })

  vim.api.nvim_create_user_command("NeedfulRun", function(cmd_opts)
    local name = vim.trim(cmd_opts.args or "")
    if name == "" then
      vim.notify("[do-the-needful] Usage: :NeedfulRun <task-name>", vim.log.levels.WARN)
      return
    end
    require("do-the-needful").run_by_name(name)
  end, {
    nargs = "+",
    complete = function(arg_lead, cmd_line, _)
      local names = get_task_names()
      local prefix = cmd_line:match("^NeedfulRun%s+(.*)$") or arg_lead
      prefix = vim.trim(prefix)
      if prefix == "" then
        return names
      end
      return vim.tbl_filter(function(name)
        return name:lower():find(prefix:lower(), 1, true) == 1
      end, names)
    end,
    desc = "Run a task by name directly",
  })

  vim.api.nvim_create_user_command("NeedfulEdit", function(cmd_opts)
    local scope = cmd_opts.fargs[1] or "project"
    if scope ~= "project" and scope ~= "global" then
      vim.notify(
        "[do-the-needful] Usage: :NeedfulEdit [project|global]",
        vim.log.levels.WARN
      )
      return
    end
    require("do-the-needful").edit_config(scope)
  end, {
    nargs = "?",
    complete = function(arg_lead, _, _)
      local options = { "project", "global" }
      if arg_lead == "" then
        return options
      end
      return vim.tbl_filter(function(opt)
        return opt:find(arg_lead, 1, true) == 1
      end, options)
    end,
    desc = "Edit do-the-needful config files",
  })
end

return M
