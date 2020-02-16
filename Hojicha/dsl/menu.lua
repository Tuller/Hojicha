local _, Addon = ...

--------------------------------------------------------------------------------
-- Global State
--------------------------------------------------------------------------------

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

local MenuBar = nil
local isPetBattleUIShown = false
local isOverrideUIShown = false

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

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
	if isPetBattleUIShown or isOverrideUIShown then
		updateOverrideUIButtons(menuBar)
		applyOverrideUILayout(menuBar)
	else
		updateStandardButtons(menuBar)
		applyStandardLayout(menuBar)
	end
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

-- watch a few events and update the menu bar layout as necessary
do
	local function getOrHook(frame, script, action)
		if frame:GetScript(script) then
			frame:HookScript(script, action)
		else
			frame:SetScript(script, action)
		end
	end

	local layoutMenuBar = Addon:Defer(function()
		if MenuBar then
			updateLayout(MenuBar)
		end
	end, 0.1)

	if PetBattleFrame and PetBattleFrame.BottomFrame and PetBattleFrame.BottomFrame.MicroButtonFrame then
		local petMicroButtons = PetBattleFrame.BottomFrame.MicroButtonFrame

		getOrHook(petMicroButtons, 'OnShow', function()
			isPetBattleUIShown = true
			layoutMenuBar()
		end)

		getOrHook(petMicroButtons, 'OnHide', function()
			isPetBattleUIShown = nil
			layoutMenuBar()
		end)
	end

	if OverrideActionBar then
		getOrHook(OverrideActionBar, 'OnShow', function()
			isOverrideUIShown = true
			layoutMenuBar()
		end)

		getOrHook(OverrideActionBar, 'OnHide', function()
			isOverrideUIShown = nil
			layoutMenuBar()
		end)
	end

	hooksecurefunc('UpdateMicroButtons', layoutMenuBar)
end

--------------------------------------------------------------------------------
-- Layout Function
--------------------------------------------------------------------------------

local DEFAULTS = {
	id = "menu",
	insets = {0, 1, 3, 0},
	disabledButtons = {},
	overrideUIButtons = {}
}

Addon.Layout.menu = function(options)
	options = Addon:CopyDefaults(options, DEFAULTS)

	MenuBar = Addon:CreateButtonBar(options)

	updateLayout(MenuBar)

	return MenuBar
end