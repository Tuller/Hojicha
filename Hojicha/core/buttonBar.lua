local _, Addon = ...

local BUTTON_BAR_DEFAULTS = {
    leftToRight = true,
	topToBottom = true,
	columns = 0,
    padding = {2, 2},
    spacing = 2,
    insets = {0, 0, 0, 0},
	buttonSize = {36, 36},
	buttons = {}
}

function Addon:CreateButtonBar(options)
    options = self:CopyDefaults(options, BUTTON_BAR_DEFAULTS)

	return self:CreateBar(options)
end

function Addon:GetButtonSize(bar)
	local _, button = next(bar.state.buttons)

	if button then
		local w, h = button:GetSize()
		local l, r, t, b = self:GetButtonInsets(bar)

		return w - (l + r), h - (t + b)
	end

	return 0, 0
end

function Addon:GetButtonInsets(bar)
	local _, button = next(bar.state.buttons)

	local l, r, t, b
	if button then
		l, r, t, b = button:GetHitRectInsets()
	else
		l, r, t, b = 0, 0, 0, 0
	end

	-- grab offsets from state
	local lOff, rOff, tOff, bOff = unpack(bar.state.insets)

	return l + lOff, r + rOff, t + tOff, b + bOff
end

function Addon:ApplyGridLayout(bar)
	local state = bar.state
    local length = #state.buttons

	local cols
	if state.columns > 0 then
		cols = min(state.columns, length)
	else
		cols = length
	end

	local rows = ceil(length / cols)

	local isLeftToRight = state.leftToRight
	local isTopToBottom = state.topToBottom

	-- grab base button sizes
	local l, r, t, b = self:GetButtonInsets(bar)
	local bW, bH = self:GetButtonSize(bar)
	local pW, pH = unpack(state.padding)
	local spacing = state.spacing

	local buttonWidth = bW + spacing
	local buttonHeight = bH + spacing

	local xOff = pW - l
	local yOff = pH - t

	-- place buttons
    for i = 1, length do
        local button = state.buttons[i]

		local row = floor((i - 1) / cols)
		if not isTopToBottom then
			row = rows - (row + 1)
		end

		local col = (i - 1) % cols
		if not isLeftToRight then
			col = cols - (col + 1)
		end

		local x = xOff + buttonWidth * col
		local y = yOff + buttonHeight * row

		button:ClearAllPoints()
		button:SetParent(bar)
		button:SetPoint("TOPLEFT", x, -y)
	end

	local width = (buttonWidth * cols) + (pW * 2) - spacing
	local height = (buttonHeight * rows) + (pH * 2) - spacing

	bar:SetSize(width, height)
end