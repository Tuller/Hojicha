local _, Addon = ...

local MainMenuBarVehicleLeaveButton = _G.MainMenuBarVehicleLeaveButton
if not MainMenuBarVehicleLeaveButton then
	Addon.Layout.vehicle = Addon.Layout.noop
	Addon.Layout.vehicleBar = Addon.Layout.noop
	return
end

--------------------------------------------------------------------------------
-- Global State
--------------------------------------------------------------------------------

-- a reference to the current vehicle bar
local VehicleBar = nil

--------------------------------------------------------------------------------
-- Blizzard Workarounds
--------------------------------------------------------------------------------

-- MainMenuBarVehicleLeaveButton_Update can alter the position of the leave
-- button, so put it back on the vehicle bar whenever it is called
hooksecurefunc(
	"MainMenuBarVehicleLeaveButton_Update",
	Addon:Defer(function()
		if VehicleBar then
			MainMenuBarVehicleLeaveButton:ClearAllPoints()
			MainMenuBarVehicleLeaveButton:SetPoint("CENTER", VehicleBar)
		end
	end, 0.1)
)

--------------------------------------------------------------------------------
-- Layout Action
--------------------------------------------------------------------------------

local DEFAULTS = {
	id = "vehicle",
	point = "BOTTOM",
	y = 160,
	x = 40 * 5.5
}

local function addMainMenuBarVehicleLeaveButton(bar)
	bar:SetSize(MainMenuBarVehicleLeaveButton:GetSize())
	bar:SetFrameStrata(MainMenuBarVehicleLeaveButton:GetFrameStrata())

	MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetParent(bar)
	MainMenuBarVehicleLeaveButton:SetPoint("CENTER")
end

Addon.Layout.zone = function(options)
	options = Addon:CopyDefaults(options, DEFAULTS)

    VehicleBar = Addon:CreateBar(options)

    addMainMenuBarVehicleLeaveButton(VehicleBar)

    return VehicleBar
end

Addon.Layout.zoneBar = Addon.Layout.zone