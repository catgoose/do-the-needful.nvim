local finders = require("telescope.finders")
local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local tokens = require("do-the-needful.tokens")
local win = require("do-the-needful.window")
local tsk = require("do-the-needful.tasks")
local edit = require("do-the-needful.edit")
local Log = require("do-the-needful").Log
local get_opts = require("do-the-needful.config").get_opts

---@class Telescope
---@field action_picker fun(opts: table)
---@field tasks fun(opts: table)
---@return Telescope
Telescope = {}

local function get_tasks()
	return tsk.collect_tasks()
end

local function entry_ordinal(task)
	local tags = vim.tbl_map(function(tag)
		return "#" .. tag
	end, task.tags)
	return table.concat(tags, " ") .. " " .. task.name
end

local function entry_display(entry)
	Log.trace("entry_display", entry)
	local items = { entry.value.name, " " }
	local highlights = {}
	local start = #table.concat(items, "")
	if #entry.value.tags > 1 and #entry.value.tags[1] > 0 then
		for _, tag in pairs(entry.value.tags) do
			vim.list_extend(items, { "#", tag, " " })
			vim.list_extend(highlights, {
				{ { start, start + 1 }, "TelescopeResultsOperator" },
				{ { start + 1, start + 1 + #tag }, "TelescopeResultsIdentifier" },
			})
			start = start + 1 + #tag + 1
		end
	end
	if get_opts().tag_source then
		vim.list_extend(items, { "#" .. entry.value.source })
		vim.list_extend(highlights, {
			{ { start, start + #entry.value.source + 1 }, "TelescopeResultsComment" },
		})
	end
	return table.concat(items), highlights
end

local function entry_maker(task)
	return {
		value = task,
		display = entry_display,
		ordinal = entry_ordinal(task),
	}
end

local function task_previewer()
	return previewers.new_buffer_previewer({
		title = "please",
		define_preview = function(self, entry, _)
			vim.api.nvim_set_option_value("filetype", "lua", { buf = self.state.bufnr })
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, tsk.task_preview(entry.value))
		end,
	})
end

local function task_picker(opts)
	local tasks = get_tasks()
	pickers
		.new(opts, {
			prompt_title = "Do the needful",
			finder = finders.new_table({
				results = tasks,
				entry_maker = entry_maker,
			}),
			sorter = conf.generic_sorter(),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					tokens.replace(selection.value, function(task)
						win.open(task)
					end)
				end)
				return true
			end,
			previewer = task_previewer(),
		})
		:find()
end

function Telescope.action_picker(opts)
	local selections = {
		{ "Edit project config", edit.edit_config, "project" },
		{ "Edit global config", edit.edit_config, "global" },
		{ "Do the needful", task_picker, opts },
	}
	local ap_opts = get_opts().telescope.action_picker
	pickers
		.new(opts, {
			prompt_title = "do-the-needful actions",
			layout_strategy = ap_opts.layout_strategy,
			layout_config = {
				width = ap_opts.layout_config.width,
				height = #selections + 4,
				prompt_position = ap_opts.layout_config.prompt_position,
			},
			finder = finders.new_table({
				results = selections,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[1],
						ordinal = entry[1],
					}
				end,
			}),
			sorter = conf.generic_sorter(),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local s = selection.value
					s[2](s[3])
				end)
				return true
			end,
		})
		:find()
end

function Telescope.tasks(opts)
	opts = opts or {}
	task_picker(opts)
end

return Telescope
