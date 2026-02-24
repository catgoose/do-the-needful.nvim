local M = {}

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
local deps = root .. "/deps"
local mini = deps .. "/mini.nvim"
local plenary = deps .. "/plenary.nvim"

if not vim.uv.fs_stat(mini) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini,
  })
end

if not vim.uv.fs_stat(plenary) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/nvim-lua/plenary.nvim",
    plenary,
  })
end

vim.opt.rtp:prepend(mini)
vim.opt.rtp:prepend(plenary)
vim.opt.rtp:prepend(root)

require("mini.test").setup()

M.expect = MiniTest.expect
M.eq = MiniTest.expect.equality
M.new_set = MiniTest.new_set

return M
