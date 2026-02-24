local h = require("tests.helpers")
local eq = h.eq
local new_set = h.new_set

local T = new_set()

T["config"] = new_set()

T["config"]["init returns opts table"] = function()
  local config = require("do-the-needful.config")
  local opts = config.init({})
  eq(type(opts), "table")
  eq(opts.config_file, ".tasks.json")
  eq(opts.edit_mode, "buffer")
  eq(opts.log_level, "warn")
end

T["config"]["get_opts returns deep copy"] = function()
  local config = require("do-the-needful.config")
  config.init({})
  local a = config.get_opts()
  local b = config.get_opts()
  eq(a.config_file, b.config_file)
  -- Verify it's a copy, not the same reference
  a.config_file = "changed"
  eq(b.config_file, ".tasks.json")
end

T["config"]["init respects user overrides"] = function()
  local config = require("do-the-needful.config")
  local opts = config.init({ edit_mode = "tab" })
  eq(opts.edit_mode, "tab")
end

return T
