-- RewriteConditional allows for parsing and rewriting macro conditionals so
-- that we can map things like [$cat] to [bonusbar:1]. The main utility of this
-- is so that we can provide a consistent syntax for certain conditions (like
-- several druid forms) that can vary

local _, Addon = ...--

local STATE_MAP = {}

local function getFormMacro(spellID)
	for i = 1, GetNumShapeshiftForms() do
		local _, _, _, formSpellID = GetShapeshiftFormInfo(i)

		if spellID == formSpellID then
			return ("[form:%d]"):format(i)
		end
	end

	return false
end

local function define(condition, state)
	if type(state) == "number" then
		STATE_MAP[condition] = function()
			return getFormMacro(state)
		end
	else
		STATE_MAP[condition] = state
	end
end

local function getStateReplacement(match, condition, state, terminator)
	local replacement = STATE_MAP[condition]
	if not replacement then
		return ""
	end

	if type(replacement) == "function" then
		replacement = replacement()
		if not replacement then
			return ""
		end
	end

	return ("[%s]%s%s"):format(replacement, state, terminator)
end

-- druid
define("bear", "bonusbar:3")
define("prowl", "bonusbar:1,stealth")
define("cat", "bonusbar:1")

if Addon:IsBuild("classic") then
	define("moonkin", 24858)
	define("travel", 783)
	define("aquatic", 1066)
else
	define("moonkin", "bonusbar:4")
	define("tree", 114282)
	define("travel", 783)
	define("stag", 210053)
end

-- rogue
define("shadowdance", "form:2")
define("stealth", "bonusbar:2")

-- warrior
if Addon:IsBuild("classic") then
	define("battle", "bonusbar:1")
	define("defensive", "bonusbar:2")
	define("berserker", "bonusbar:3")
end

-- priest
if Addon:IsBuild("classic") then
	define("shadowform", "form:1")
end

function Addon:RewriteConditionalExpression(expr)
	if type(expr) ~= "string" then
		error(("Usage: %s:RewriteConditionalExpression(\"expr\")"):format(Addon:GetName()), 2)
	end

	return expr:gsub("(%[%$(%a+)%]([^;]+)(;*))", getStateReplacement)
end


function Addon:ApplyStateDriver(frame, state, expr)
	expr = tostring(expr)
	expr = self:RewriteConditionalExpression(expr)

	RegisterStateDriver(frame, state, expr)
	frame:SetAttribute("state-" .. state, SecureCmdOptionParse(expr))
end
