local originalRequire = require

function require(path)
	if path == "./lib/workspaces.luau" then
		return dofile("lib/workspaces.luau")
	end
	return originalRequire(path)
end

local config = {
	label_format = "%L",
	show_all_outputs = false,
	hide_empty = false,
	background_color = "on_surface",
	active_color = "#336699",
	text_color = "on_surface",
	urgent_color = "error",
	gap = 5,
	outer_padding = 4,
	item_padding = 8,
	background_radius = 4,
	item_radius = 2,
}

local state = {
	status = "ready",
	workspaces = {
		{
			id = 1,
			idx = 1,
			name = "Web",
			output = "eDP-1",
			is_active = false,
			is_urgent = false,
			active_window_id = 10,
		},
		{
			id = 2,
			idx = 2,
			name = "Code",
			output = "eDP-1",
			is_active = true,
			is_urgent = false,
			active_window_id = 20,
		},
		{
			id = 3,
			idx = 1,
			name = "Chat",
			output = "DP-1",
			is_active = true,
			is_urgent = false,
			active_window_id = 30,
		},
	},
}

local watchers = {}
local commands = {}

noctalia = {
	getConfig = function(key)
		return config[key]
	end,
	focusedOutputName = function()
		return "eDP-1"
	end,
	runAsync = function(command, callback)
		table.insert(commands, command)
		if callback ~= nil then
			callback({ exitCode = 0, stderr = "" })
		end
		return true
	end,
	log = function() end,
	state = {
		get = function(key)
			return state[key]
		end,
		watch = function(key, callback)
			watchers[key] = callback
		end,
	},
}

local function node(kind)
	return function(props, children)
		return { kind = kind, props = props, children = children or {} }
	end
end

ui = {
	row = node("row"),
	column = node("column"),
	label = node("label"),
}

local rendered = nil
local visible = nil
local widgetOutputName = "eDP-1"
local widgetIsVertical = false
barWidget = {
	outputName = function()
		return widgetOutputName
	end,
	isVertical = function()
		return widgetIsVertical
	end,
	setVisible = function(value)
		visible = value
	end,
	render = function(tree)
		rendered = tree
	end,
}

dofile("widget.luau")

assert(visible == true)
assert(rendered.kind == "row")
assert(#rendered.children == 2)
assert(rendered.props.fill == "on_surface/0.1")
assert(rendered.children[1].children[1].props.text == "Web")
assert(rendered.children[1].props.fill == "#00000000")
assert(rendered.children[2].props.fill == "#336699BF")

widgetOutputName = nil
watchers.workspaces(state.workspaces)
assert(#rendered.children == 2)
widgetOutputName = "eDP-1"

widgetIsVertical = true
update()
assert(rendered.kind == "column")
widgetIsVertical = false
watchers.workspaces(state.workspaces)
assert(rendered.kind == "column")
widgetIsVertical = true

rendered.children[1].props.onClick()
assert(commands[1][4] == "focus-workspace")
assert(commands[1][5] == "Web")

onScroll("vertical", 1, true)
assert(commands[2][4] == "focus-workspace-down")

state.workspaces[1].is_urgent = true
watchers.workspaces(state.workspaces)
assert(rendered.children[1].children[1].props.color == "error")

print("widget tests passed")
