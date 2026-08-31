local state = {}
local streamCallback = nil
local streamCommand = nil
local updateInterval = nil
local asyncCommands = {}

noctalia = {
	json = {
		decode = function(line)
			if line == "bad" then
				return nil, "invalid JSON"
			elseif line == "snapshot" then
				return {
					{ id = 1, idx = 1, output = "eDP-1", is_active = true, is_focused = true },
					{ id = 2, idx = 2, output = "eDP-1", is_active = false, is_focused = false },
				}
			elseif line == "activated" then
				return { WorkspaceActivated = { id = 2, focused = true } }
			end
			return {
				WorkspacesChanged = {
					workspaces = { { id = 3, idx = 3, output = "eDP-1", is_active = true } },
				},
			}
		end,
	},
	log = function() end,
	runAsync = function(command, callback)
		table.insert(asyncCommands, command)
		callback({ exitCode = 0, stdout = "snapshot", stderr = "" })
		return true
	end,
	runStream = function(command, callback)
		streamCommand = command
		streamCallback = callback
		return true
	end,
	setUpdateInterval = function(interval)
		updateInterval = interval
	end,
	state = {
		set = function(key, value)
			state[key] = value
		end,
	},
}

dofile("service.luau")

assert(state.status == "ready")
assert(state.workspaces[1].id == 1)
assert(streamCallback ~= nil)
assert(streamCommand == "niri msg --json event-stream")
assert(updateInterval == 60000)
assert(asyncCommands[1][3] == "--json")
assert(asyncCommands[1][4] == "workspaces")

streamCallback("activated")
assert(state.workspaces[1].is_active == false)
assert(state.workspaces[1].is_focused == false)
assert(state.workspaces[2].is_active == true)
assert(state.workspaces[2].is_focused == true)

streamCallback("event")
assert(state.status == "ready")
assert(state.workspaces[1].id == 3)

streamCallback("bad")
assert(state.status == "ready")

update()
assert(#asyncCommands == 2)

print("service tests passed")
