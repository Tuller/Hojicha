local _, Addon = ...

-- if we don't have an extra action bar in this client, then quit
local ZoneAbilityFrame = _G.ZoneAbilityFrame
if not ZoneAbilityFrame then
	Addon.Layout.zone = Addon.Layout.noop
	Addon.Layout.zoneBar = Addon.Layout.noop
	return
end

--------------------------------------------------------------------------------
-- Blizzard Workarounds
--------------------------------------------------------------------------------

-- tell the UIManager that we're handling the frame
ZoneAbilityFrame.ignoreFramePositionManager = true

--------------------------------------------------------------------------------
-- Layout Action
--------------------------------------------------------------------------------

local DEFAULTS = {
	id = "zone",
	point = "BOTTOM",
	y = 160
}

local function addZoneAbilityFrame(bar)
	bar:SetSize(ZoneAbilityFrame:GetSize())
	bar:SetFrameStrata(ZoneAbilityFrame:GetFrameStrata())

	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetParent(bar)
	ZoneAbilityFrame:SetPoint("CENTER")
end

Addon.Layout.zone = function(options)
	options = Addon:CopyDefaults(options, DEFAULTS)

    local bar = Addon:CreateBar(options)

    addZoneAbilityFrame(bar)

    return bar
end

Addon.Layout.zoneBar = Addon.Layout.zone