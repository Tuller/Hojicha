local _, Addon = ...
local ActionButton = Addon.ActionButton

local NUM_ACTION_BARS = 12

local DEFAULTS = {
    size = 12,
    point = "BOTTOM"
}

local function addActionButtons(bar)
    for i = 1, bar.state.size do
        local actionId = i + (NUM_ACTION_BARS * (bar.state.id - 1))

        tinsert(bar.state.buttons, ActionButton:Acquire(actionId))
    end
end

Addon.Layout.actionBar = function(options)
    options = Addon:CopyDefaults(options, DEFAULTS)

    local bar = Addon:CreateButtonBar(options)

    addActionButtons(bar)

    Addon:ApplyGridLayout(bar)

    return bar
end

Addon.Layout.ab = Addon.Layout.actionBar