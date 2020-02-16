local _, Addon = ...

local MICRO_BUTTONS
if Addon:IsBuild("classic") then
	MICRO_BUTTONS = {
		"CharacterMicroButton",
		"SpellbookMicroButton",
		"TalentMicroButton",
		"QuestLogMicroButton",
		"SocialsMicroButton",
		"WorldMapMicroButton",
		"MainMenuMicroButton",
		"HelpMicroButton"
	}
else
	MICRO_BUTTONS = {
		"CharacterMicroButton",
		"SpellbookMicroButton",
		"TalentMicroButton",
		"AchievementMicroButton",
		"QuestLogMicroButton",
		"GuildMicroButton",
		"LFDMicroButton",
		"CollectionsMicroButton",
		"EJMicroButton",
		"StoreMicroButton",
		"MainMenuMicroButton"
	}
end

local function getOrHook(frame, script, action)
	if frame:GetScript(script) then
		frame:HookScript(script, action)
	else
		frame:SetScript(script, action)
	end
end

local function defer(func, delay)
	delay = delay or 0

	local waiting = false

	local function callback()
		func()
		waiting = false
	end

	return function()
		if not waiting then
			waiting = true

			C_Timer.After(delay or 0, callback)
		end
	end
end

local function updateOverrideUIButtons(menuBar)
	wipe(menuBar.state.overrideUIButtons)

	local isStoreEnabled = C_StorePublic.IsEnabled()
	local addButton

	for _, buttonName in ipairs(MICRO_BUTTONS) do
		if buttonName == 'HelpMicroButton' then
			addButton = not isStoreEnabled
		elseif buttonName == 'StoreMicroButton' then
			addButton = isStoreEnabled
		else
			addButton = true
		end

		if addButton then
			tinsert(menuBar.state.overrideUIButtons, _G[buttonName])
		end
	end
end

local function applyOverrideUILayout(menuBar)
	local l, r, t, b = Addon:GetButtonInsets(menuBar)
	local buttons = menuBar.state.overrideUIButtons

	for i, button in ipairs(buttons) do
		if i > 1 then
			button:ClearAllPoints()
			if i == 7 then
				button:SetPoint('TOPLEFT', buttons[1], 'BOTTOMLEFT', 0, 4 + (t - b))
			else
				button:SetPoint('BOTTOMLEFT', buttons[i - 1], 'BOTTOMRIGHT', (l - r), 0)
			end
		end

		button:Show()
	end
end

local function updateStandardButtons(menuBar)
	wipe(menuBar.state.buttons)

	for _, name in ipairs(MICRO_BUTTONS) do
		local button = _G[name]

		if button and not menuBar.state.disabledButtons[name] then
			button:Show()
			tinsert(menuBar.state.buttons, button)
		elseif button then
			button:Hide()
		end
	end
end

local function applyStandardLayout(menuBar)
	Addon:ApplyGridLayout(menuBar)
end

local function updateLayout(menuBar)
	if menuBar.isPetBattleUIShown or menuBar.isOverrideUIShown then
		updateOverrideUIButtons(menuBar)
		applyOverrideUILayout(menuBar)
	else
		updateStandardButtons(menuBar)
		applyStandardLayout(menuBar)
	end
end

-- override/pet battle detection
-- when these occur, we need to reapply the layout of the bar
local function watchMicroButtonEvents(menuBar)
	local requestLayout = defer(function() updateLayout(menuBar) end, 0.1)

	if PetBattleFrame and PetBattleFrame.BottomFrame and PetBattleFrame.BottomFrame.MicroButtonFrame then
		local petMicroButtons = PetBattleFrame.BottomFrame.MicroButtonFrame

		getOrHook(petMicroButtons, 'OnShow', function()
			menuBar.state.isPetBattleUIShown = true
			requestLayout()
		end)

		getOrHook(petMicroButtons, 'OnHide', function()
			menuBar.state.isPetBattleUIShown = nil
			requestLayout()
		end)
	end

	if OverrideActionBar then
		getOrHook(OverrideActionBar, 'OnShow', function()
			menuBar.state.isOverrideUIShown = true
			requestLayout()
		end)

		getOrHook(OverrideActionBar, 'OnHide', function()
			menuBar.state.isOverrideUIShown = nil
			requestLayout()
		end)
	end

	hooksecurefunc('UpdateMicroButtons', requestLayout)
end

--------------------------------------------------------------------------------
-- Blizzard Workarounds
--------------------------------------------------------------------------------

-- fix blizzard nil bug
-- luacheck: push ignore 111 113
if not AchievementMicroButton_Update then
	AchievementMicroButton_Update = function() end
end
-- luacheck: pop

-- the performance bar actually appears under the game menu button if you
-- move it somewhere else
local MainMenuBarPerformanceBar  = MainMenuBarPerformanceBar
local MainMenuMicroButton = MainMenuMicroButton
if MainMenuBarPerformanceBar and MainMenuMicroButton then
	MainMenuBarPerformanceBar:ClearAllPoints()
	MainMenuBarPerformanceBar:SetPoint("BOTTOM", MainMenuMicroButton, "BOTTOM")
end

--------------------------------------------------------------------------------
-- Layout Function
--------------------------------------------------------------------------------

local MENU_BAR_DEFAULTS = {
	id = "menu",
	disabledButtons = {},
	overrideUIButtons = {}
}

Addon.Layout.menu = function(options)
	options = Addon:CopyDefaults(options, MENU_BAR_DEFAULTS)

	local bar = Addon:CreateButtonBar(options)

	applyStandardLayout(bar)
	watchMicroButtonEvents(bar)

	return bar
end