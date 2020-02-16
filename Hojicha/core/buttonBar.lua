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

function Addon:CreatButtonBar(options)
    options = self:CopyDefaults(options, BUTTON_BAR_DEFAULTS)

	return self:CreateBar(options)
end

function Addon:GetButtonInsets(bar)
	local l, r, t, b
	if #bar.state.buttons >= 1 then
		l, r, t, b = bar.state.buttons[1]:GetHitRectInsets()
	else
		l, r, t, b = 0, 0, 0, 0
	end

	-- grab offsets from state
	local lOff, rOff, tOff, bOff = unpack(bar.state.insets)

	return l + lOff, r + rOff, t + tOff, b + bOff
end

function Addon:ApplyGridLayout(bar)
	local state = bar.state
    local numButtons = #state.buttons

	local cols
	if state.columns > 0 then
		cols = min(state.columns, numButtons)
	else
		cols = numButtons
	end

	local rows = ceil(numButtons / cols)

	local isLeftToRight = state.leftToRight
	local isTopToBottom = state.topToBottom

	-- grab base button sizes
	local l, _, t, _ = self:GetButtonInsets(state)
	local bW, bH = unpack(state.buttonSize)
	local pW, pH = unpack(state.padding)
	local spacing = state.spacing

	local buttonWidth = bW + spacing
	local buttonHeight = bH + spacing

	local xOff = pW - l
	local yOff = pH - t

	-- place buttons
    for i = 1, numButtons do
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