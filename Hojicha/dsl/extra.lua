local _, Addon = ...

-- if we don't have an extra action bar in this client, then quit
local ExtraActionBarFrame = _G.ExtraActionBarFrame
if not ExtraActionBarFrame then
	Addon.Layout.extra = Addon.layout.noop
	Addon.Layout.extraBar = Addon.layout.noop
	return
end

--------------------------------------------------------------------------------
-- Blizzard Workarounds
--------------------------------------------------------------------------------

-- tell the UIManager that we're handling the extra action bar frame
ExtraActionBarFrame.ignoreFramePositionManager = true

-- we don't need to tell the UI when the bar is hidden
ExtraActionBarFrame:SetScript("OnHide", nil)

--------------------------------------------------------------------------------
-- Layout Action
--------------------------------------------------------------------------------

local DEFAULTS = {
	id = "extra",
	showBackground = true,
	point = "BOTTOM",
	y = 160
}

local function addExtraActionBarFrame(bar)
	bar:SetSize(ExtraActionBarFrame:GetSize())
	bar:SetFrameStrata(ExtraActionBarFrame:GetFrameStrata())

	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetParent(bar)
	ExtraActionBarFrame:SetPoint("CENTER")
end

local function styleExtraActionButton(bar)
	local button = ExtraActionBarFrame.button

	if bar.state.showBackground then
		button.style:Show()
	else
		button.style:Hide()
	end
end

Addon.Layout.extra = function(options)
	options = Addon:CopyDefaults(options, DEFAULTS)

    local bar = Addon:CreateBar(options)

    addExtraActionBarFrame(bar)
	styleExtraActionButton(bar)

    return bar
end

Addon.Layout.extraBar = Addon.Layout.extra
