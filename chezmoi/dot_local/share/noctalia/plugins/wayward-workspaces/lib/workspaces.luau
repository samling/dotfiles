local M = {}

local function workspaceTitle(workspace)
	if type(workspace.name) == "string" and workspace.name ~= "" then
		return workspace.name
	end

	return ""
end

function M.formatLabel(workspace, format)
	local index = tostring(workspace.idx or "")
	local title = workspaceTitle(workspace)
	local label = title ~= "" and title or index
	local output = {}
	local cursor = 1

	while cursor <= #format do
		local current = string.sub(format, cursor, cursor)
		if current ~= "%" or cursor == #format then
			table.insert(output, current)
			cursor = cursor + 1
		else
			local token = string.sub(format, cursor + 1, cursor + 1)
			if token == "I" then
				table.insert(output, index)
			elseif token == "T" then
				table.insert(output, title)
			elseif token == "L" then
				table.insert(output, label)
			elseif token == "%" then
				table.insert(output, "%")
			else
				table.insert(output, "%" .. token)
			end
			cursor = cursor + 2
		end
	end

	return table.concat(output)
end

function M.isEmpty(workspace)
	return workspace.active_window_id == nil and workspace.is_active ~= true and workspace.is_urgent ~= true
end

function M.visible(workspaces, outputName, showAllOutputs, hideEmpty)
	local visible = {}
	if type(workspaces) ~= "table" then
		return visible
	end

	for _, workspace in ipairs(workspaces) do
		local onOutput = showAllOutputs or outputName == nil or workspace.output == outputName
		if onOutput and (not hideEmpty or not M.isEmpty(workspace)) then
			table.insert(visible, workspace)
		end
	end

	return visible
end

function M.reference(workspace)
	local title = workspaceTitle(workspace)
	if title ~= "" then
		return title
	end

	if workspace.idx ~= nil then
		return tostring(workspace.idx)
	end

	return nil
end

return M
