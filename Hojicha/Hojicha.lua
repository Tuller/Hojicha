-- the main driver for the addon
local AddonName, Addon = ...

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

function Addon:OnEnable()
	self:Layout([[
		ab {
			id = 1,
			point = "BOTTOM",
			page = "[$cat]7;[$tree]8;[$bear]9;[$moonkin]10;1"
		},
		ab {
			id = 2,
			point = "BOTTOM",
			y = 38,
			visible = "[mod][combat]true;false"
		},
		ab { id = 3, columns = 1, point = "RIGHT" },
		ab { id = 4, columns = 1, point = "RIGHT", x = -38 },
		bags { point = "BOTTOMRIGHT", y = 40 },
		menu { point = "BOTTOMRIGHT" },
		stance { point = "BOTTOM", x = 38 * -5, y = 40 * 2 },
		pet { point = "BOTTOM", y = 40 * 2 },
		extra {},
		zone {},
		vehicle {}
	]])
end

--------------------------------------------------------------------------------
-- Utility Methods
--------------------------------------------------------------------------------

-- wow classic vs retail tests
function Addon:GetBuild()
	local project = WOW_PROJECT_ID

	if project == WOW_PROJECT_CLASSIC then
		return "classic"
	elseif project == WOW_PROJECT_MAINLINE then
		return "retail"
	else
		return "unknown"
	end
end

function Addon:IsBuild(...)
	local build = self:GetBuild()

	for i = 1, select("#", ...) do
		if build == select(i, ...):lower() then
			return true
		end
	end

	return false
end

-- returns a function that generates unique names for frames
-- in the format <AddonName>_<Prefix>[1, 2, ...]
function Addon:CreateNameGenerator(prefix, delimiter)
	delimiter = delimiter or "."

	local id = 0
	return function()
		id = id + 1
		return strjoin(delimiter, AddonName, prefix, id)
	end
end

function Addon:CreateHiddenFrame(frameType, ...)
	local frame = CreateFrame(frameType, ...)

	frame:Hide()

	return frame
end

function Addon:CreateWidgetClass(frameType, ...)
	local frameClass = self:CreateHiddenFrame(frameType)

	if select("#", ...) > 0 then
		Mixin(frameClass, ...)
	end

	return frameClass, { __index = frameClass }
end

function Addon:CopyDefaults(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table' then
			tbl[k] = self:CopyDefaults(tbl[k] or {}, v)
		elseif tbl[k] == nil then
			tbl[k] = v
		end
	end

	return tbl
end

-- somewhere between a debounce and a throttle
function Addon:Defer(func, delay, ...)
	delay = delay or 0

	local waiting = false

	local function callback(...)
		func(...)
		waiting = false
	end

	return function()
		if not waiting then
			waiting = true
			_G.C_Timer.After(delay or 0, callback)
		end
	end
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

-- make this an ace addon
LibStub("AceAddon-3.0"):NewAddon(Addon, AddonName, "AceEvent-3.0", "AceConsole-3.0")

-- give ourselves a global
_G[AddonName] = Addon
