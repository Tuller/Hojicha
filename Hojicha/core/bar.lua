local _, Addon = ...

local DEFAULTS = {
    visible = true,

    scale = 1,

    opacity = 1,

    clickThrough = false,

    showWithOverrideUI = false,

    showWithPetBattleUI = false,

    -- positioning
    point = "CENTER",
    x = 0,
    y = 0

    -- anchor = "barID"
}

local function setVisible(bar, visible)
    bar:SetAttribute("_onstate-visible", [[
        if newstate == "true" then
            self:Show()
        else
            self:Hide()
        end
    ]])

    Addon:ApplyStateDriver(bar, "visible", visible)
end

local function setScale(bar, scale)
    bar:SetAttribute("_onstate-scale", [[
        self:SetScale(newstate)
    ]])

    Addon:ApplyStateDriver(bar, "scale", scale)
end

local function setOpacity(bar, opacity)
    bar:SetAttribute("_onstate-opacity", [[
        self:SetAlpha(newstate)
    ]])

    Addon:ApplyStateDriver(bar, "opacity", opacity)
end

local function setClickThrough(bar, clickThrough)
    bar:SetAttribute("_onstate-clickThrough", [[
        control:ChildUpdate("clickThrough", newstate)
    ]])

    Addon:ApplyStateDriver(bar, "clickThrough", clickThrough)
end

local function setPosition(bar, point, x, y)
    local scale = bar:GetScale()

    bar:ClearAllPoints()
    bar:SetPoint(point, x / scale, y / scale)
end

function Addon:CreateBar(options)
    options = self:CopyDefaults(options, DEFAULTS)

    local bar = CreateFrame(
        "Frame",
        ("%sBar%s"):format(self:GetName(), options.id),
        self.UIParent,
        "SecureHandlerStateTemplate"
    )

    bar.id = options.id
    bar.state = self:CopyDefaults({}, options)

    setVisible(bar, options.visible)
    setScale(bar, options.scale)
    setPosition(bar, options.point, options.x, options.y)
    setOpacity(bar, options.opacity)
    setClickThrough(bar, options.clickThrough)

    -- RGBA(178, 56, 5, 1)
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(178 / 255, 56 / 255, 5 / 255, 0.5)
    bg:SetAllPoints(bar)

    local fs = bar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("CENTER")
    fs:SetText(options.id)

    return bar
end