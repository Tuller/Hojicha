-- Hojicha.lua - the main driver for the addon

local AddonName, AddonTable = ...
local Addon = LibStub("AceAddon-3.0"):NewAddon(AddonTable, AddonName, "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

local ADDON_VERSION = GetAddOnMetadata(AddonName, "Version")
-- local CONFIG_ADDON_NAME = AddonName .. "_Config"
local CONFIG_VERSION = 1

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- AceAddon Lifecycle
function Addon:OnInitialize()
	-- setup db
	self:CreateDatabase()
	self:UpgradeDatabase()

	-- create a loader for the options menu
	-- local f = CreateFrame("Frame", nil, InterfaceOptionsFrame)
	-- f:SetScript(
	-- 	"OnShow",
	-- 	function()
	-- 		f:SetScript("OnShow", nil)
	-- 		LoadAddOn(CONFIG_ADDON_NAME)
	-- 	end
	-- )
end

function Addon:OnEnable()
	self:LoadModules(true)
end

-- AceDB Profiles
-- Fires when a new profile is created, usually used to apply custom defaults that cannot be handled through AceDB.
function Addon:OnNewProfile(msg, db, name)
	self:Print(msg, db, name)
end

-- Fires after changing the profile.
function Addon:OnProfileChanged(msg, db, name)
	self:Print(msg, db, name)
end

-- Fires after a profile has been deleted.
function Addon:OnProfileDeleted(msg, db, name)
	self:Print(msg, db, name)
end

-- Fires after a profile has been copied into the current active profile.
function Addon:OnProfileCopied(msg, db, name)
	self:Print(msg, db, name)
end

-- Fires after the current profile has been reset.
function Addon:OnProfileReset(msg, db, name)
	self:Print(msg, db, name)
end

-- Fires after the whole database has been reset. (Note: OnProfileReset will fire as well)
function Addon:OnDatabaseReset(msg, db, name)
	self:Print(msg, db, name)
end

-- Fires before changing the profile.
function Addon:OnProfileShutdown(msg, db, name)
	self:Print(msg, db, name)
end

-- Fires when logging out, just before the database is about to be cleaned of all AceDB metadata.
function Addon:OnDatabaseShutdown(msg, db, name)
	self:Print(msg, db, name)
end

-- Configuration
function Addon:OnUpgradeAddon(oldVersion, newVersion)
	self:Printf(L.AddonUpgradedToVersion, ADDON_VERSION, self:GetBuild())
end

function Addon:OnUpgradeDatabase(oldVersion, newVersion)
end

--------------------------------------------------------------------------------
-- Module Actions
--------------------------------------------------------------------------------

-- LoadModules is called after switching profiles, and on PLAYER_LOGIN
function Addon:LoadModules(firstLoad)
	local function module_load(module, id)
		if not self.db.profile.modules[id] then
			return
		end

		local f = module.OnLoadModule
		if type(f) == "function" then
			f(module, firstLoad)
		end
	end

	for id, module in self:IterateModules() do
		local success, msg = pcall(module_load, module, id)
		if not success then
			self:Printf("Failed to load %s\n%s", module:GetName(), msg)
		end
	end

	self.Frame:ForAll("Reanchor")
	self:GetModule("ButtonThemer"):Reskin()
end

-- UnloadModules is called before switching profiles
function Addon:UnloadModules()
	local function module_unload(module, id)
		if not self.db.profile.modules[id] then
			return
		end

		local f = module.OnUnloadModule
		if type(f) == "function" then
			f(module)
		end
	end

	-- unload any module stuff
	for id, module in self:IterateModules() do
		local success, msg = pcall(module_unload, module, id)
		if not success then
			self:Printf("Failed to unload %s\n%s", module:GetName(), msg)
		end
	end
end

--------------------------------------------------------------------------------
-- DB Actions
--------------------------------------------------------------------------------

-- Create a new database and follow events
function Addon:CreateDatabase()
	local defaults = self:GetDatabaseDefaults()
	local profileID = self:GetDefaultProfileID()

	local db = LibStub("AceDB-3.0"):New(AddonName .. "DB", defaults, profileID)

	db.RegisterCallback(self, "OnNewProfile")
	db.RegisterCallback(self, "OnProfileChanged")
	db.RegisterCallback(self, "OnProfileDeleted")
	db.RegisterCallback(self, "OnProfileCopied")
	db.RegisterCallback(self, "OnProfileReset")
	db.RegisterCallback(self, "OnDatabaseReset")
	db.RegisterCallback(self, "OnProfileShutdown")
	db.RegisterCallback(self, "OnDatabaseShutdown")

	self.db = db
end

function Addon:GetDatabaseDefaults()
	return {
		global = {},
		profile = {
			-- what template this profile inherits
			template = "default",
			minimap = {
				hide = false
			},
			-- what modules are enabled
			modules = {
				["**"] = true
			}
		}
	}
end

function Addon:GetDefaultProfileID()
	return DEFAULT
end

function Addon:UpgradeDatabase()
	local configVerison = self.db.global.configVersion
	if configVerison ~= CONFIG_VERSION then
		self:OnUpgradeDatabase(configVerison, CONFIG_VERSION)
		self.db.global.configVersion = CONFIG_VERSION
	end

	local addonVersion = self.db.global.addonVersion
	if addonVersion ~= ADDON_VERSION then
		self:OnUpgradeAddon(addonVersion, ADDON_VERSION)
		self.db.global.addonVersion = ADDON_VERSION
	end
end

--------------------------------------------------------------------------------
-- Utility Methods
--------------------------------------------------------------------------------

-- wow classic vs retail tests
function Addon:GetBuild()
	local project = WOW_PROJECT_ID

	if project == WOW_PROJECT_CLASSIC then
		return "classic"
	elseif project == WOW_PROJECT_MAINLINE then
		return "retail"
	else
		return "unknown"
	end
end

function Addon:IsBuild(...)
	local build = self:GetBuild()

	for i = 1, select("#", ...) do
		if build == select(i, ...):lower() then
			return true
		end
	end

	return false
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

-- make this an ace addon
LibStub("AceAddon-3.0"):NewAddon(Addon, AddonName, "AceEvent-3.0", "AceConsole-3.0")

-- give ourselves a global
_G[AddonName] = Addon
