local Workspaces = require("./lib/workspaces.luau")

local STATE_WORKSPACES = "workspaces"
local STATE_STATUS = "status"
local TRANSPARENT = "#00000000"

local options = {
	labelFormat = noctalia.getConfig("label_format"),
	showAllOutputs = noctalia.getConfig("show_all_outputs") == true,
	hideEmpty = noctalia.getConfig("hide_empty") == true,
	backgroundColor = noctalia.getConfig("background_color"),
	backgroundOpacity = noctalia.getConfig("background_opacity") or 0.10,
	activeColor = noctalia.getConfig("active_color"),
	activeOpacity = noctalia.getConfig("active_opacity") or 0.75,
	textColor = noctalia.getConfig("text_color"),
	urgentColor = noctalia.getConfig("urgent_color"),
	gap = noctalia.getConfig("gap"),
	outerPadding = noctalia.getConfig("outer_padding"),
	itemPadding = noctalia.getConfig("item_padding"),
	backgroundRadius = noctalia.getConfig("background_radius"),
	itemRadius = noctalia.getConfig("item_radius"),
}

local workspaces = noctalia.state.get(STATE_WORKSPACES) or {}
local status = noctalia.state.get(STATE_STATUS) or "connecting"
local outputName = barWidget.outputName()
local isVertical = barWidget.isVertical()

local function colorWithOpacity(color, opacity)
	if type(color) ~= "string" or color == "" or opacity <= 0 then
		return TRANSPARENT
	end

	color = string.match(color, "^([^/]+)/[%d.]+$") or color
	if opacity >= 1 then
		return color
	end

	if string.sub(color, 1, 1) ~= "#" then
		return color .. "/" .. tostring(opacity)
	end

	local hex = string.sub(color, 2)
	if #hex == 3 or #hex == 4 then
		hex = string.sub(hex, 1, 1)
			.. string.sub(hex, 1, 1)
			.. string.sub(hex, 2, 2)
			.. string.sub(hex, 2, 2)
			.. string.sub(hex, 3, 3)
			.. string.sub(hex, 3, 3)
	end

	if #hex == 8 then
		hex = string.sub(hex, 1, 6)
	end
	if #hex ~= 6 then
		return color
	end

	local alpha = math.floor(opacity * 255 + 0.5)
	return "#" .. hex .. string.format("%02X", alpha)
end

local function runOnOutput(outputName, callback)
	local focusedOutput = noctalia.focusedOutputName()
	if outputName ~= nil and outputName ~= focusedOutput then
		local accepted = noctalia.runAsync({ "niri", "msg", "action", "focus-monitor", outputName }, function(result)
			if result.exitCode ~= 0 then
				noctalia.log("Could not focus output " .. outputName .. ": " .. result.stderr)
				return
			end
			callback()
		end)
		if not accepted then
			noctalia.log("Could not queue Niri output focus action")
		end
		return
	end

	callback()
end

local function focusWorkspace(workspace)
	local reference = Workspaces.reference(workspace)
	if reference == nil then
		return
	end

	runOnOutput(workspace.output, function()
		local accepted = noctalia.runAsync({
			"niri",
			"msg",
			"action",
			"focus-workspace",
			reference,
		})
		if not accepted then
			noctalia.log("Could not queue Niri workspace focus action")
		end
	end)
end

local function renderStatus()
	barWidget.setVisible(true)
	barWidget.render(ui.row({
		paddingH = options.outerPadding,
		fill = colorWithOpacity(options.backgroundColor, options.backgroundOpacity),
		radius = options.backgroundRadius,
		align = "center",
	}, {
		ui.label({
			text = status == "unavailable" and "Niri unavailable" or "Connecting to Niri",
			color = options.urgentColor,
		}),
	}))
end

local function render()
	local visible = Workspaces.visible(workspaces, outputName, options.showAllOutputs, options.hideEmpty)

	if #visible == 0 then
		if status ~= "ready" then
			renderStatus()
		else
			barWidget.setVisible(false)
		end
		return
	end

	local items = {}
	for _, workspace in ipairs(visible) do
		local fill = workspace.is_active == true and colorWithOpacity(options.activeColor, options.activeOpacity)
			or TRANSPARENT
		local color = workspace.is_urgent == true and options.urgentColor or options.textColor
		table.insert(
			items,
			ui.row({
				key = "workspace-" .. tostring(workspace.id),
				paddingH = options.itemPadding,
				align = "center",
				justify = "center",
				fill = fill,
				radius = options.itemRadius,
				onClick = function()
					focusWorkspace(workspace)
				end,
			}, {
				ui.label({
					text = Workspaces.formatLabel(workspace, options.labelFormat),
					color = color,
				}),
			})
		)
	end

	local container = isVertical and ui.column or ui.row
	barWidget.setVisible(true)
	barWidget.render(container({
		gap = options.gap,
		paddingH = options.outerPadding,
		align = "stretch",
		fill = colorWithOpacity(options.backgroundColor, options.backgroundOpacity),
		radius = options.backgroundRadius,
	}, items))
end

function update()
	isVertical = barWidget.isVertical()
	render()
end

function onScroll(axis, steps, startsGesture)
	if not startsGesture or steps == 0 then
		return
	end

	local action = steps > 0 and "focus-workspace-down" or "focus-workspace-up"
	local outputName = barWidget.outputName()
	runOnOutput(outputName, function()
		local accepted = noctalia.runAsync({ "niri", "msg", "action", action })
		if not accepted then
			noctalia.log("Could not queue Niri workspace scroll action")
		end
	end)
end

noctalia.state.watch(STATE_WORKSPACES, function(value)
	workspaces = value or {}
	render()
end)

noctalia.state.watch(STATE_STATUS, function(value)
	status = value or "connecting"
	render()
end)

render()
