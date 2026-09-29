local function assertEqual(actual, expected)
	assert(actual == expected, string.format("expected %s, got %s", tostring(expected), tostring(actual)))
end

local state = {}
local publications = {}
local rendered = nil
local closed = 0

local function node(kind)
	return function(props, children)
		return { kind = kind, props = props, children = children or {} }
	end
end

local function loadPanel()
	local environment = setmetatable({
		noctalia = {
			tr = function(key)
				assertEqual(key, "menu.refresh")
				return "Refresh"
			end,
			state = {
				get = function(key)
					return state[key]
				end,
				set = function(key, value)
					state[key] = value
					table.insert(publications, { key = key, value = value })
				end,
			},
		},
		panel = {
			render = function(tree)
				rendered = tree
			end,
			close = function()
				closed = closed + 1
			end,
		},
		ui = {
			column = node("column"),
			button = node("button"),
		},
	}, { __index = _G })
	local chunk, loadError = loadfile("panel.luau", "t", environment)
	assert(chunk ~= nil, loadError)
	chunk()
	return environment
end

local callbacks = loadPanel()
callbacks.onOpen()
assertEqual(#publications, 0)
assertEqual(closed, 0)
assertEqual(rendered.kind, "column")
assertEqual(#rendered.children, 1)
local button = rendered.children[1]
assertEqual(button.kind, "button")
assertEqual(button.props.text, "Refresh")
assertEqual(button.props.glyph, "refresh")
assertEqual(button.props.onClick, "onRefresh")

callbacks[button.props.onClick]()
assertEqual(#publications, 1)
assertEqual(publications[1].key, "refresh_request")
assertEqual(publications[1].value, 1)
assertEqual(closed, 1)

-- Reopening does not fetch until clicked; each click publishes a new value.
callbacks.onOpen()
assertEqual(#publications, 1)
callbacks.onRefresh()
assertEqual(publications[2].value, 2)
assertEqual(closed, 2)

-- A fresh panel VM must not reuse the previous request value.
callbacks = loadPanel()
callbacks.onOpen()
assertEqual(#publications, 2)
callbacks.onRefresh()
assertEqual(publications[3].value, 3)
assertEqual(closed, 3)

print("panel tests passed")
