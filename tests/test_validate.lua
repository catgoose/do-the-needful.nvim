local h = require("tests.helpers")
local eq = h.eq
local new_set = h.new_set

local T = new_set()

T["validate"] = new_set({
  hooks = {
    pre_case = function()
      package.loaded["do-the-needful"] = nil
      package.loaded["do-the-needful.config"] = nil
      package.loaded["do-the-needful.validate"] = nil
      package.loaded["do-the-needful.logger"] = nil
      require("do-the-needful").setup({})
    end,
  },
})

T["validate"]["provider opts tables pass through"] = function()
  local validate = require("do-the-needful.validate")
  local tasks = {
    {
      name = "test",
      cmd = "echo hello",
      tmux = { split = true, size = "30%" },
      zellij = { floating = true, direction = "down" },
      neovim = { split = "vsplit", size = 40 },
      toggleterm = { direction = "float", size = 20 },
    },
  }
  local result = validate.tasks(tasks)
  eq(result[1].tmux.split, true)
  eq(result[1].tmux.size, "30%")
  eq(result[1].zellij.floating, true)
  eq(result[1].zellij.direction, "down")
  eq(result[1].neovim.split, "vsplit")
  eq(result[1].neovim.size, 40)
  eq(result[1].toggleterm.direction, "float")
  eq(result[1].toggleterm.size, 20)
end

T["validate"]["non-table provider opts are removed"] = function()
  local validate = require("do-the-needful.validate")
  local tasks = {
    {
      name = "test",
      cmd = "echo hello",
      tmux = "invalid",
      zellij = 42,
      neovim = true,
      toggleterm = false,
    },
  }
  local result = validate.tasks(tasks)
  eq(result[1].tmux, nil)
  eq(result[1].zellij, nil)
  eq(result[1].neovim, nil)
  eq(result[1].toggleterm, nil)
end

T["validate"]["absent provider keys stay nil"] = function()
  local validate = require("do-the-needful.validate")
  local tasks = {
    {
      name = "test",
      cmd = "echo hello",
    },
  }
  local result = validate.tasks(tasks)
  eq(result[1].tmux, nil)
  eq(result[1].zellij, nil)
  eq(result[1].neovim, nil)
  eq(result[1].toggleterm, nil)
end

return T
