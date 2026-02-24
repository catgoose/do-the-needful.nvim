local h = require("tests.helpers")
local eq = h.eq
local new_set = h.new_set

local T = new_set()

T["constants"] = new_set()

T["constants"]["preview field order includes provider keys"] = function()
  local const = require("do-the-needful.constants").get()
  local order = const.task_preview_field_order

  local has_tmux, has_zellij, has_neovim, has_toggleterm = false, false, false, false
  local window_idx, tags_idx
  for i, field in ipairs(order) do
    if field == "tmux" then has_tmux = true end
    if field == "zellij" then has_zellij = true end
    if field == "neovim" then has_neovim = true end
    if field == "toggleterm" then has_toggleterm = true end
    if field == "window" then window_idx = i end
    if field == "tags" then tags_idx = i end
  end

  eq(has_tmux, true)
  eq(has_zellij, true)
  eq(has_neovim, true)
  eq(has_toggleterm, true)

  -- Provider keys should be between window and tags
  for i, field in ipairs(order) do
    if field == "tmux" or field == "zellij" or field == "neovim" or field == "toggleterm" then
      eq(i > window_idx, true)
      eq(i < tags_idx, true)
    end
  end
end

return T
