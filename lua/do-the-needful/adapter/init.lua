local Log = require("do-the-needful").Log
local sf = require("do-the-needful.utils").string_format
local const = require("do-the-needful.constants").get()

---@class TaskRunAdapter
---@field run fun(task: TaskConfig)
---@return TaskRunAdapter
local M = {}

---@param task TaskConfig
function M.run(task)
  if not task then
    return
  end
  if not const.run_adapter then
    return
  end

  local ok, adapter = pcall(require, string.format("do-the-needful.adapter.%s", const.run_adapter))
  if not ok or not adapter then
    return
  end
  if not adapter.run then
    Log.warn(sf(
      [[adapter.run: adapter '%s' does not implement 'run':
    adapter: %s
    ]],
      const.run_adapter,
      adapter
    ))
    return
  end
  Log.info(sf(
    [[adapter.run:
    run_adapter: %s
    adapter_ok: %s
    adapter: %s
    ]],
    const.run_adapter,
    ok,
    adapter
  ))
  adapter.run(task)
end

return M
