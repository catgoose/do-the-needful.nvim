local has_telescope, telescope = pcall(require, "telescope")
local pickers = require("do-the-needful.telescope")
local log = require("do-the-needful.logger").log

if not has_telescope then
	log.error("unable to load telescope")
	return
end

return telescope.register_extension({
	exports = {
		please = function(opts)
			pickers.tasks(opts)
		end,
		["do-the-needful"] = function(opts)
			pickers.action_picker(opts)
		end,
		project = function()
			require("do-the-needful.edit").edit_config("project")
		end,
		global = function()
			require("do-the-needful.edit").edit_config("global")
		end,
	},
})
