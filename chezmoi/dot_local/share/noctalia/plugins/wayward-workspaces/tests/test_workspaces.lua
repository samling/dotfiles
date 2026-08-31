local Workspaces = dofile("lib/workspaces.luau")

local sample = {
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
		name = nil,
		output = "eDP-1",
		is_active = true,
		is_urgent = false,
		active_window_id = nil,
	},
	{
		id = 3,
		idx = 1,
		name = "Chat",
		output = "DP-1",
		is_active = false,
		is_urgent = true,
		active_window_id = nil,
	},
	{
		id = 4,
		idx = 2,
		name = nil,
		output = "DP-1",
		is_active = false,
		is_urgent = false,
		active_window_id = nil,
	},
}

assert(Workspaces.formatLabel(sample[1], "%L") == "Web")
assert(Workspaces.formatLabel(sample[2], "%L") == "2")
assert(Workspaces.formatLabel(sample[1], "%I:%T") == "1:Web")
assert(Workspaces.formatLabel(sample[1], "%% %Q %") == "% %Q %")
assert(Workspaces.reference(sample[1]) == "Web")
assert(Workspaces.reference(sample[2]) == "2")
assert(Workspaces.isEmpty(sample[2]) == false)

local localWorkspaces = Workspaces.visible(sample, "eDP-1", false, false)
assert(#localWorkspaces == 2)
assert(localWorkspaces[1].id == 1)
assert(localWorkspaces[2].id == 2)

local nonEmpty = Workspaces.visible(sample, nil, true, true)
assert(#nonEmpty == 3)

print("workspace tests passed")
