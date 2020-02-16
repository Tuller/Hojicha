local _, Addon = ...
local Layout = Addon.Layout
local ActionButton = Addon.ActionButton

local ACTION_BAR_DEFAULTS = {
    size = 12,
    point = "BOTTOM"
}

local function addActionButtons(bar)
    for i = 1, bar.state.size do
        local id = i + 12 * (bar.state.id - 1)
        local button = ActionButton:Acquire(id)

        tinsert(bar.state.buttons, button)
    end
end

Layout.actionBar = function(options)
    local bar = Addon:CreateButtonBar(options, ACTION_BAR_DEFAULTS)

    addActionButtons(bar)

    Addon:ApplyGridLayout(bar)

    return bar
end