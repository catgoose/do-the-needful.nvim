local Path = require("plenary.path")

---@class Utils
---@field deep_copy fun(orig: table): table
---@field indent_str fun(indent_n: number, str: string): string
---@field escaped_replace fun(str: string, what: string, with: string): string
---@field split_string fun(str: string, del: string): string[]
---@field string_format fun(msg: string, ...): string
---@field json_from_path fun(path: string): table
---@return Utils
local M = {}

function M.deep_copy(orig)
  local t = type(orig)
  local copy
  if t == "table" then
    copy = {}
    for k, v in pairs(orig) do
      copy[k] = M.deep_copy(v)
    end
  else
    copy = orig
  end
  return copy
end

M.indent_str = function(indent_n, str)
  return ("\t"):rep(indent_n) .. str
end

-- https://stackoverflow.com/questions/29072601/lua-string-gsub-with-a-hyphen
function M.escaped_replace(str, what, with)
  what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
  with = string.gsub(with, "[%%]", "%%%%")
  return string.gsub(str, what, with)
end

function M.split_string(str, del)
  del = del or " "
  return vim.split(str, del, { plain = true, trimempty = true })
end

function M.string_format(msg, ...)
  local args = { ... }
  for i, v in ipairs(args) do
    if type(v) == "table" then
      args[i] = vim.inspect(v)
    end
  end
  return string.format(msg, unpack(args))
end

function M.json_from_path(path)
  local f_handle = Path:new(path)
  if f_handle:exists() then
    local contents = f_handle:read()
    local ok, json = pcall(vim.json.decode, contents)
    if not ok then
      local warning_message = M.string_format(
        "tasks._decode_json(): invalid json decoded from file: %s",
        f_handle.filename
      )
      vim.api.nvim_echo({ { "Warning: ", "WarningMsg" }, { warning_message } }, false, {})
    else
      return json
    end
  end
  return
end

return M
