local _, Addon = ...

local PetButton, PetButton_MT = Addon:CreateWidgetClass('CheckButton', Addon.BindableButton)

do
    PetButton.buttonType = "BONUSACTIONBUTTON"

    local unused = {}

    function PetButton:Acquire(id)
        local button = self:Restore(id) or self:Create(id)

        -- Addon.BindingsController:Register(button)
        -- Addon:GetModule('Tooltips'):Register(button)

        return button
    end

    function PetButton:Create(id)
        local button = _G[('PetActionButton%d'):format(id)]

        if button then
            setmetatable(button, PetButton_MT)
            -- button:HookScript('OnEnter', self.OnEnter)
            -- Addon:GetModule('ButtonThemer'):Register(button, 'Pet Bar')
        end

        return button
    end

    function PetButton:Restore(id)
        local button = unused[id]

        if button then
            unused[id] = nil
            button:Show()

            return button
        end
    end

    -- saving them thar memories
    function PetButton:Release()
        unused[self:GetID()] = self

        -- Addon.BindingsController:Unregister(self)
        -- Addon:GetModule('Tooltips'):Unregister(self)

        self:SetParent(nil)
        self:Hide()
    end

    -- override keybinding display
    hooksecurefunc('PetActionButton_SetHotkeys', PetButton.UpdateHotkey)
end

local DEFAULTS = {
    id = "pet"
}

local function addPetActionButtons(bar)
    for i = 1, NUM_PET_ACTION_SLOTS do
        tinsert(bar.state.buttons, PetButton:Acquire(i))
    end
end

Addon.Layout.pet = function(options)
    options = Addon:CopyDefaults(options, DEFAULTS)

    local bar = Addon:CreateButtonBar(options)

    addPetActionButtons(bar)
    Addon:ApplyGridLayout(bar)

    return bar
end

Addon.Layout.petBar = Addon.Layout.pet