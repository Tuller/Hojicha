local AddonName, Addon = ...

local BAG_DEFAULTS = {
    id = "bags",
    point = "BOTTOMRIGHT",
    oneBag = false,
    keyRing = true,
    spacing = 2,
    buttons = {}
}

local function showKeyRing(state)
    return state.keyRing and Addon:IsBuild("classic")
end

local function showEquippableBagSlots(state)
    return not state.oneBag
end

local function getOrCreateKeyRingButton()
    if not Addon:IsBuild("Classic") then return end

    local keyring = CreateFrame('CheckButton', AddonName .. 'KeyRingButton', UIParent, 'ItemButtonTemplate')
    keyring:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    keyring:SetID(KEYRING_CONTAINER)

    keyring:SetScript('OnClick', function(_, button)
        if CursorHasItem() then
            PutKeyInKeyRing()
        else
            ToggleBag(KEYRING_CONTAINER)
        end
    end)

    keyring:SetScript('OnReceiveDrag', function(_)
        if CursorHasItem() then
            PutKeyInKeyRing()
        end
    end)

    keyring:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

        local color = HIGHLIGHT_FONT_COLOR
        GameTooltip:SetText(KEYRING, color.r, color.g, color.b)
        GameTooltip:AddLine()
    end)

    keyring:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)

    keyring.icon:SetTexture([[Interface\Icons\INV_Misc_Bag_16]])

    MainMenuBarBackpackButton:HookScript("OnClick", function(_, button)
        if IsControlKeyDown() then
            ToggleBag(KEYRING_CONTAINER)
        end
    end)

    return keyring
end

local function getBagButton(state, index)
	local keyRingIndex = showKeyRing(state) and 1 or 0

	local backpackIndex
	if showEquippableBagSlots(state) then
		backpackIndex = keyRingIndex + NUM_BAG_SLOTS + 1
	else
		backpackIndex = keyRingIndex + 1
	end

	if index == keyRingIndex then
		return getOrCreateKeyRingButton()
	elseif index == backpackIndex then
		return MainMenuBarBackpackButton
	elseif index > keyRingIndex and index < backpackIndex then
		return _G[('CharacterBag%dSlot'):format(NUM_BAG_SLOTS - (index - keyRingIndex))]
	end
end

local function getBagCount(state)
	local count = 1

	if showKeyRing(state) then
		count = count + 1
	end

	if showEquippableBagSlots(state) then
		count = count + NUM_BAG_SLOTS
	end

	return count
end

local function addBagButtons(bar)
    for i = 1, getBagCount(bar.state) do
        tinsert(bar.state.buttons, getBagButton(bar.state, i))
    end
end

Addon.Layout.bags = function(options)
    options = Addon:CopyDefaults(options, BAG_DEFAULTS)

    local bar = Addon:CreateButtonBar(options)

    addBagButtons(bar)

    Addon:ApplyGridLayout(bar)

    return bar
end