local _, Addon = ...

local DEFAULTS = {
    show = true,

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

local function setVisible(bar, show)
    if show then
        bar:Show()
    else
        bar:Hide()
    end
end

local function setScale(bar, scale)
    bar:SetScale(scale)
end

local function setOpacity(bar, opacity)
    bar:SetAlpha(opacity)
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
        "SecureHandlerAttributeTemplate"
    )

    bar.id = options.id
    bar.state = self:CopyDefaults({}, options)

    setVisible(bar, options.show)
    setScale(bar, options.scale)
    setPosition(bar, options.point, options.x, options.y)
    setOpacity(bar, options.opacity)

    -- RGBA(178, 56, 5, 1)
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(178 / 255, 56 / 255, 5 / 255, 0.5)
    bg:SetAllPoints(bar)

    local fs = bar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("CENTER")
    fs:SetText(options.id)

    return bar
end