local t = require("do-the-needful.utils").indent_str
local deep_copy = require("do-the-needful.utils").deep_copy

local default_log_level = "warn"

---@class TelescopeOpts
---@field actions table
---@field tasks table

---@class Opts
---@field log_level string
---@field tasks table
---@field config_file string
---@field config_order table
---@field edit_mode string
---@field tag_source boolean
---@field global_tokens table
---@field ask_functions table
---@field adapter Adapter

---@enum Adapter
---| "tmux" # Tmux adapter
---| "zellij" # Zellij adapter
---| "terminal" # Terminal adapter
local Adapter = {
  tmux = "tmux",
  zellij = "zellij",
  terminal = "terminal",
}

---@class Constants
---@field get_val fun(): Constants._val
---@return Constants
local M = {}

---@class Constants._val
---@field plugin_name string
---@field task_preview_field_order string[]
---@field token_replacement_fields string[]
---@field lists table
---@field opts Opts
---@field telescope_opts TelescopeOpts
---@field telescope_setup table
---@field task_defaults TaskConfig
---@field default_task_lines string[]
---@field default_log_level string
---@field log_levels string[]
local _val = {
  enum = {
    Relative = {
      after = "after",
      before = "before",
    },
    Source = {
      global = "global",
      project = "project",
      opts = "opts",
    },
    Adapter = Adapter,
  },
  plugin_name = "do-the-needful",
  task_preview_field_order = {
    "name",
    "cmd",
    "cwd",
    "window",
    "tags",
    "ask",
  },
  token_replacement_fields = {
    "cmd",
    "cwd",
    "name",
  },
  lists = {
    edit_modes = { "buffer", "tab", "split", "vsplit" },
    config_order = { "global", "project", "opts" },
  },
  opts = {
    log_level = default_log_level,
    tasks = {},
    config_file = ".tasks.json",
    config_order = {
      "project",
      "global",
      "opts",
    },
    adapter = Adapter.tmux,
    edit_mode = "buffer",
    tag_source = true,
    global_tokens = {
      ["${cwd}"] = vim.fn.getcwd,
      ["${do-the-needful}"] = "please",
    },
    ask_functions = {},
  },
  telescope_setup = {},
  telescope_opts = {
    actions = {
      layout_strategy = "center",
      layout_config = {
        width = 0.25,
        prompt_position = "bottom",
      },
    },
    tasks = {
      layout_config = {
        width = 0.85,
        height = 0.75,
      },
    },
  },
  task_defaults = {
    cwd = vim.fn.getcwd(),
    tags = {},
    window = {
      close = true,
      keep_current = false,
    },
  },
  default_task_lines = {
    "{",
    t(1, '"tasks": ['),
    t(2, "{"),
    t(3, '"name": "",'),
    t(3, '"cmd": "",'),
    t(3, '"tags": [""],'),
    t(3, '"window": {'),
    t(4, '"name": "",'),
    t(4, '"close": false,'),
    t(4, '"keep_current": false,'),
    t(4, '"open_relative": true,'),
    t(4, '"relative": "after"'),
    t(3, "}"),
    t(2, "}"),
    t(1, "]"),
    "}",
  },
  default_log_level = default_log_level,
  log_levels = { "trace", "debug", "info", "warn", "error", "fatal" },
}

M.get = function() return deep_copy(_val) end

return M
