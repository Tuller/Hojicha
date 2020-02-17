local _, Addon = ...
local ActionButton = Addon.ActionButton

local NUM_ACTION_BARS = 10
local NUM_ACTION_BUTTONS_PER_BAR = 120 / NUM_ACTION_BARS

local DEFAULTS = {
    size = NUM_ACTION_BUTTONS_PER_BAR
}

local function addActionButtons(bar)
    for i = 1, bar.state.size do
        local id = i + (NUM_ACTION_BARS * (bar.state.id - 1))

        local button = ActionButton:Acquire(id)
        button:SetAttribute("action--base", i)

        tinsert(bar.state.buttons, button)
    end
end

local function addActionPages(bar)
    bar:SetAttribute("_onstate-page", [[
        control:ChildUpdate("offset", 12 * (newstate - 1))
    ]])

    if bar.state.page then
        Addon:ApplyStateDriver(bar, "page", bar.state.page)
    else
        Addon:RemoveStateDriver(bar, "page", bar.state.id)
    end
end

Addon.Layout.actionBar = function(options)
    options = Addon:CopyDefaults(options, DEFAULTS)

    local bar = Addon:CreateButtonBar(options)

    addActionButtons(bar)
    addActionPages(bar)

    Addon:ApplyGridLayout(bar)

    return bar
end

Addon.Layout.ab = Addon.Layout.actionBar