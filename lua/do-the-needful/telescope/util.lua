local previewers = require("telescope.previewers")
local preview = require("do-the-needful.telescope.preview")
local get_opts = require("do-the-needful.config").get_opts
local Log = require("do-the-needful").Log

---@class TelescopeUtil
---@field get_telescope_opts fun(opts: table): table
---@field entry_ordinal fun(task: table): string
---@field entry_display fun(entry: table): string, table
---@field entry_maker fun(task: table): table
local M = {}

function M.get_telescope_opts(opts)
	local telescope_opts = require("do-the-needful.config").get_telescope_opts()
	if opts and next(opts) ~= nil then
		vim.tbl_extend("keep", telescope_opts, opts)
	else
		opts = telescope_opts
	end
	return opts
end

function M.entry_ordinal(task)
	local tags = vim.tbl_map(function(tag)
		return "#" .. tag
	end, task.tags)
	return table.concat(tags, " ") .. " " .. task.name
end

function M.entry_display(entry)
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

function M.entry_maker(task)
	return {
		value = task,
		display = M.entry_display,
		ordinal = M.entry_ordinal(task),
	}
end

function M.task_previewer()
	return previewers.new_buffer_previewer({
		title = "please",
		define_preview = function(self, entry, _)
			vim.api.nvim_set_option_value("filetype", "lua", { buf = self.state.bufnr })
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview.render(entry.value))
		end,
	})
end
return M
