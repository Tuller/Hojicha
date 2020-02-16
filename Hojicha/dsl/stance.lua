local _, Addon = ...

local PLAYER_CLASS = select(2, UnitClass('player'))

-- don't bother loading the module if the player is currently playing something without a stance
if not (
	PLAYER_CLASS == 'DRUID'
	or PLAYER_CLASS == 'ROGUE'
	or (not Addon:IsBuild("classic") and PLAYER_CLASS == 'PRIEST')
	or (Addon:IsBuild("classic") and (PLAYER_CLASS == 'WARRIOR' or PLAYER_CLASS == 'PALADIN'))
) then
	local function noop() return end

	Addon.Layout.stance = noop
	Addon.Layout.class = noop
	return
end

local StanceButton, StanceButton_MT = Addon:CreateWidgetClass("CheckButton", Addon.BindableButton)
do
	local unused = {}

	StanceButton.buttonType = 'SHAPESHIFTBUTTON'

	function StanceButton:Acquire(id)
		local button = self:Restore(id) or self:Create(id)

		-- Addon.BindingsController:Register(button)
		-- Addon:GetModule('Tooltips'):Register(button)

		return button
	end

	function StanceButton:Create(id)
		local button = setmetatable(_G[('StanceButton%d'):format(id)], StanceButton_MT)

		if button then
			button:HookScript('OnEnter', self.OnEnter)
			-- Addon:GetModule('ButtonThemer'):Register(button, 'Class Bar')
		end

		return button
	end

	function StanceButton:Restore(id)
		local button = unused[id]

		if button then
			unused[id] = nil
			button:Show()

			return button
		end
	end

	--saving them thar memories
	function StanceButton:Release()
		unused[self:GetID()] = self

		self:SetParent(nil)
		self:Hide()

		-- Addon.BindingsController:Unregister(self)
		-- Addon:GetModule('Tooltips'):Unregister(self)
	end
end

local function updateLayout(bar)
	if InCombatLockdown() then return end

	local buttons = bar.state.buttons
	local oldLength = #buttons
	local newLength = GetNumShapeshiftForms() or 0

	if oldLength == newLength then
		return
	end

	-- remove buttons no longer in use
	for i = oldLength, newLength + 1, -1 do
		buttons[i]:Release()
		tremove(buttons, i)
	end

	-- add new buttons
	for i = oldLength + 1, newLength do
		tinsert(buttons, StanceButton:Acquire(i))
	end

	Addon:ApplyGridLayout(bar)
end

local DEFAULTS = {
	id = "stance"
}

Addon.Layout.stance = function(options)
    options = Addon:CopyDefaults(options, DEFAULTS)

    local bar = Addon:CreateButtonBar(options)

	bar:SetScript("OnEvent", updateLayout)
	bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	bar:RegisterEvent("PLAYER_REGEN_ENABLED")
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")

    return bar
end

Addon.Layout.class = Addon.Layout.stance