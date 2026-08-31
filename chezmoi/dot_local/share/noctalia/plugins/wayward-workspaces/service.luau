local STATE_WORKSPACES = "workspaces"
local STATE_STATUS = "status"
local RESYNC_MS = 60000

local workspaces = {}

local function publishWorkspaces()
	noctalia.state.set(STATE_WORKSPACES, workspaces)
	noctalia.state.set(STATE_STATUS, "ready")
end

local function applyWorkspaces(list)
	workspaces = {}
	for _, workspace in ipairs(list) do
		table.insert(workspaces, workspace)
	end
	table.sort(workspaces, function(a, b)
		return (a.idx or 0) < (b.idx or 0)
	end)
	publishWorkspaces()
end

local function applyActivated(id, isFocused)
	local activated = nil
	for _, workspace in ipairs(workspaces) do
		if workspace.id == id then
			activated = workspace
			break
		end
	end

	if activated == nil then
		return false
	end

	for _, workspace in ipairs(workspaces) do
		if workspace.output == activated.output then
			workspace.is_active = workspace.id == id
		end
		if isFocused then
			workspace.is_focused = workspace.id == id
		end
	end

	publishWorkspaces()
	return true
end

local function snapshot()
	local accepted = noctalia.runAsync({ "niri", "msg", "--json", "workspaces" }, function(result)
		if result.exitCode ~= 0 then
			noctalia.log("Could not read Niri workspaces: " .. result.stderr)
			return
		end

		local list, err = noctalia.json.decode(result.stdout)
		if type(list) ~= "table" then
			noctalia.log("Could not decode Niri workspaces: " .. tostring(err))
			return
		end

		applyWorkspaces(list)
	end)

	if not accepted then
		noctalia.log("Could not queue a Niri workspace snapshot")
	end
end

local function publishEvent(line)
	local event, err = noctalia.json.decode(line)
	if event == nil then
		noctalia.log("Could not decode Niri event: " .. tostring(err))
		return
	end

	if type(event.WorkspacesChanged) == "table" and type(event.WorkspacesChanged.workspaces) == "table" then
		applyWorkspaces(event.WorkspacesChanged.workspaces)
		return
	end

	local activated = event.WorkspaceActivated
	if type(activated) == "table" and not applyActivated(activated.id, activated.focused == true) then
		snapshot()
	end
end

noctalia.state.set(STATE_STATUS, "connecting")
snapshot()

local started = noctalia.runStream("niri msg --json event-stream", publishEvent)

if not started then
	noctalia.state.set(STATE_STATUS, "unavailable")
	noctalia.log("Could not start the Niri event stream")
end

noctalia.setUpdateInterval(RESYNC_MS)

function update()
	snapshot()
end
