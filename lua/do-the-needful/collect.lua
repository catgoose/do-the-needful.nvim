local get_opts = require("do-the-needful.config").get_opts
local Log = require("do-the-needful").Log
local utils = require("do-the-needful.utils")
local validate = require("do-the-needful.validate")
local sf = utils.string_format

---@class TaskConfig
---@field id? string
---@field name? string
---@field cmd? string
---@field cwd? string
---@field tags? string[]
---@field ask? table
---@field hidden? boolean
---@field window? TmuxWindow
---@field source? source
---@field type? collection_type
---@enum source "global" | "project" | "opts"
---@enum collection_type "task" | "job"

---@class TmuxWindow
---@field name? string
---@field close? boolean
---@field keep_current? boolean
---@field open_relative? boolean
---@field relative? relative
---@enum relative "before" "after"

---@class JobConfig
---@field name? string
---@field tags? string[]
---@field tasks? string[]
---@field source? source
---@field type? collection_type
---@field window? TmuxWindow

---@class CollectionConfig
---@field tasks? TaskConfig[]
---@field jobs? JobConfig[]

---@class Collect
---@func configs(): CollectionConfig[]
---@return Collect
Collect = {}

local function add_metadata(collection, config, source)
	if not config then
		return
	end
	for type, c in pairs(config) do
		for _, t in pairs(c) do
			t.source = source
			t.type = string.gsub(type, "(s)$", "")
			Log.trace(sf("collect._add_metadata(): adding source '%s' and type '%s' to config %s", source, type, c))
		end
		collection[type] = collection[type] or {}
		vim.list_extend(collection[type], c)
	end
end

---@return TaskConfig[]
function Collect.configs()
	local collection = {}
	local sources = get_opts().configs
	Log.trace(sf("collect.configs(): parsing configs: %s", sources))
	for _, source in pairs(get_opts().config_order) do
		local path = sources[source].path
		if path then
			local from_json = utils.json_from_path(path)
			if from_json then
				Log.trace(sf("collect.configs(): composing task: %s from path %s", from_json, path))
				add_metadata(collection, from_json, source)
			end
		else
			add_metadata(collection, sources[source], source)
		end
	end
	collection = validate.collection(collection)
	Log.debug(sf("collect.configs(): collection %s", collection))
	return collection
end

return Collect
