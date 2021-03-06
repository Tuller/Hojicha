-- a pool of action buttons
local AddonName, Addon = ...
local ActionButton, ActionButton_MT = Addon:CreateWidgetClass("CheckButton", Addon.BindableButton)
local HiddenFrame = Addon:CreateHiddenFrame("Frame")

local unused = {}
local active = {}

local function createActionButton(id)
	local name = ("%sActionButton%d"):format(AddonName, id)

	return CreateFrame("CheckButton", name, nil, "ActionBarButtonTemplate")
end

local function getOrCreateActionButton(id)
	if id <= 12 then
		local b = _G[("ActionButton%d"):format(id)]

		-- luacheck: push ignore 122
		b.buttonType = "ACTIONBUTTON"
		-- luacheck: pop
		return b
	elseif id <= 24 then
		return createActionButton(id - 12)
	elseif id <= 36 then
		return _G[("MultiBarRightButton%d"):format(id - 24)]
	elseif id <= 48 then
		return _G[("MultiBarLeftButton%d"):format(id - 36)]
	elseif id <= 60 then
		return _G[("MultiBarBottomRightButton%d"):format(id - 48)]
	elseif id <= 72 then
		return _G[("MultiBarBottomLeftButton%d"):format(id - 60)]
	else
		return createActionButton(id - 60)
	end
end

-- constructor
function ActionButton:Acquire(id)
	local button = self:Restore(id) or self:Create(id)

	if button then
		button:SetAttribute("showgrid", 0)
		-- button:SetAttribute("action--index", id)

		-- Addon.BindingsController:Register(button, button:GetName():match(AddonName .. 'ActionButton%d'))
		-- Addon:GetModule('Tooltips'):Register(button)

		-- get rid of range indicator text
		-- local hotkey = button.HotKey
		-- if hotkey:GetText() == RANGE_INDICATOR then
		-- 	hotkey:SetText("")
		-- end

		-- button:UpdateMacro()
		-- button:UpdateCount()
		-- button:UpdateShowEquippedItemBorders()

		active[id] = button
	end

	return button
end

function ActionButton:Create(id)
	local button = getOrCreateActionButton(id)

	if button then
		button = setmetatable(button, ActionButton_MT)

		-- this is used to preserve the button's old id
		-- we cannot simply keep a button's id at > 0 or blizzard code will
		-- take control of paging but we need the button's id for the old
		-- bindings system
		button:SetAttribute("bindingid", button:GetID())
		button:SetID(0)

		button:SetAttribute("_childupdate-offset", [[
			local action = self:GetAttribute("action--base") + message

			if self:GetAttribute("action") ~= action then
				self:SetAttribute("action", action)
				self:CallMethod("UpdateState")
			end
		]])

		button:SetAttribute("statehidden", nil)
		button:SetAttribute("useparent-actionpage", nil)

		button:EnableMouseWheel(true)
		button:HookScript("OnEnter", self.OnEnter)

	-- Addon:GetModule('ButtonThemer'):Register(button, 'Action Bar')
	end

	return button
end

function ActionButton:Restore(id)
	local button = unused[id]

	if button then
		unused[id] = nil

		button:SetAttribute("statehidden", nil)

		active[id] = button
		return button
	end
end

function ActionButton:Release()
	local id = self:GetAttribute("action--base")

	active[id] = nil

	-- Addon:GetModule('Tooltips'):Unregister(self)
	-- Addon.BindingsController:Unregister(self)

	self:SetAttribute("statehidden", true)
	self:SetParent(HiddenFrame)
	self:Hide()

	unused[id] = self
end

-- override the old update hotkeys function
hooksecurefunc("ActionButton_UpdateHotkeys", ActionButton.UpdateHotkey)

-- add inventory counts in classic
-- if Addon:IsBuild("classic") then
-- 	local GetActionReagentUses = Addon.GetActionReagentUses

-- 	hooksecurefunc("ActionButton_UpdateCount", function(self)
-- 		local action = self.action

-- 		-- check reagent counts
-- 		local requiresReagents, usesRemaining = GetActionReagentUses(action)
-- 		if requiresReagents then
-- 			self.Count:SetText(usesRemaining)
-- 			return
-- 		end

-- 		-- standard inventory counts
-- 		if IsConsumableAction(action) or IsStackableAction(action)  then
-- 			local count = GetActionCount(action)
-- 			if count > (self.maxDisplayCount or 9999) then
-- 				self.Count:SetText("*")
-- 			elseif count > 0 then
-- 				self.Count:SetText(count)
-- 			else
-- 				self.Count:SetText("")
-- 			end
-- 		end
-- 	end)
-- end

function ActionButton:ShowingCounts()
	return true
end

function ActionButton:UpdateCount()
	if self:ShowingCounts() then
		self.Count:Show()
	else
		self.Count:Hide()
	end
end

-- button visibility
if Addon:IsBuild("classic") then
	function ActionButton:ShowGrid()
		if InCombatLockdown() then
			return
		end

		self:SetAttribute("showgrid", (self:GetAttribute("showgrid") or 0) + 1)

		if not self:GetAttribute("statehidden") then
			self:Show()
		end
	end

	function ActionButton:HideGrid()
		if InCombatLockdown() then
			return
		end

		local showgrid = (self:GetAttribute("showgrid") or 0)
		if showgrid > 0 then
			self:SetAttribute("showgrid", showgrid - 1)
		end

		if self:GetAttribute("showgrid") == 0 and not HasAction(self.action) then
			self:Hide()
		end
	end
else
	function ActionButton:ShowGrid(reason)
		if InCombatLockdown() then
			return
		end

		self:SetAttribute("showgrid", bit.bor(self:GetAttribute("showgrid"), reason))

		if self:GetAttribute("showgrid") > 0 and not self:GetAttribute("statehidden") then
			self:Show()
		end
	end

	function ActionButton:HideGrid(reason)
		if InCombatLockdown() then
			return
		end

		local showgrid = self:GetAttribute("showgrid")
		if showgrid > 0 then
			self:SetAttribute("showgrid", bit.band(showgrid, bit.bnot(reason)))
		end

		if self:GetAttribute("showgrid") == 0 and not HasAction(self.action) then
			self:Hide()
		end
	end
end

function ActionButton:UpdateGrid()
	if InCombatLockdown() then
		return
	end

	local showgrid = (self:GetAttribute("showgrid") or 0)
	if showgrid > 0 and not self:GetAttribute("statehidden") then
		self:Show()
	end

	if showgrid == 0 and not HasAction(self.action) then
		self:Hide()
	end
end

-- macro text
function ActionButton:ShowingMacroText()
	return false
end

function ActionButton:UpdateMacro()
	if self:ShowingMacroText() then
		self.Name:Show()
	else
		self.Name:Hide()
	end
end

function ActionButton:SetFlyoutDirection(direction)
	if InCombatLockdown() then return end

	self:SetAttribute("flyoutDirection", direction)
	ActionButton_UpdateFlyout(self)
end

ActionButton.UpdateState = _G.ActionButton_UpdateState

function ActionButton:ShowingEquippedItemBorders()
	return true
end

function ActionButton:UpdateShowEquippedItemBorders()
	self.Border:SetParent(self:ShowingEquippedItemBorders() and self or HiddenFrame)
end

-- utility function, resyncs the button's current action, modified by state
-- function ActionButton:LoadAction()
-- 	local state = self:GetParent():GetAttribute("state-page")

-- 	local id = state and self:GetAttribute("action--" .. state) or self:GetAttribute("action--base")

-- 	self:SetAttribute("action", id)
-- end

function ActionButton:ForAll(method, ...)
	if type(method) ~= "string" then
		error("Usage: ActionButton:ForAll(\"method\", ...args)", 2)
	end

	for _, button in pairs(active) do
		local func = button[method]
		if type(func) == "function" then
			func(button, ...)
		end
	end
end

-- exports
Addon.ActionButton = ActionButton
