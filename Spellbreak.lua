Spellbreak = LibStub("AceAddon-3.0"):NewAddon("Spellbreak", "AceEvent-3.0")

local L = Spellbreak

local instanceType
local spellSchools = {[1] = L["Physical"], [2] = L["Holy"], [4] = L["Fire"], [8] = L["Nature"], [16] = L["Frost"], [32] = L["Shadow"], [64] = L["Arcane"]}

function Spellbreak:OnInitialize()
	self.defaults = {
		profile = {
			inside = {["arena"] = true, ["pvp"] = true},
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("SpellbreakDB", self.defaults)
	self.revision = tonumber(string.match("$Revision: 599 $", "(%d+)") or 1)

	-- Monitor for zone change
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
	
	-- Quick check
	self:ZONE_CHANGED_NEW_AREA()
end

function Spellbreak:OnEnable()
	local type = select(2, IsInInstance())
	if( not self.db.profile.inside[type] ) then
		return
	end
		
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Spellbreak:OnDisable()
	self:UnregisterAllEvents()
	
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
end

function Spellbreak:Reload()
	self:OnDisable()

	-- Check to see if we should enable it
	local type = select(2, IsInInstance())
	if( self.db.profile.inside[type] ) then
		self:OnEnable()
	end
end

local GROUP_AFFILIATION = bit.bor(COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID)

-- Need to clean this up a bit
function Spellbreak:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)			
	local isDestEnemy = (bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE)
	local isDestGroup = (bit.band(destFlags, GROUP_AFFILIATION) > 0)
	local isSourceEnemy = (bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE)
	local isSourceGroup = (bit.band(sourceFlags, GROUP_AFFILIATION) > 0)
		
	-- Enemy gained a debuff
	if( eventType == "SPELL_AURA_APPLIED" and auraType == "DEBUFF" and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, auraType = ...
	
	-- We interrupted someone, or someone in our group did
	elseif( eventType == "SPELL_INTERRUPT" and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE and it.band(sourceFlags, GROUP_AFFILIATION) > 0 ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool = ...
	end
end

-- See if we should enable Afflicted in this zone
function Spellbreak:ZONE_CHANGED_NEW_AREA()
	local type = select(2, IsInInstance())

	if( type ~= instanceType ) then
		-- Check if it's supposed to be enabled in this zone
		if( self.db.profile.inside[type] ) then
			self:OnEnable()
		else
			self:OnDisable()
		end
	end
		
	instanceType = type
end

-- Strips server name
function Spellbreak:StripServer(text)
	local name, server = string.match(text, "(.-)%-(.*)$")
	if( not name and not server ) then
		return text
	end
	
	return name
end

-- See if we should wrap an icon stuff around this
function Spellbreak:WrapIcon(msg, dest, spellID)
	if( not self.db.profile.showIcons or not spellID ) then
		return msg
	end
	
	-- Make sure we have a valid icon
	local icon = select(3, GetSpellInfo(spellID))
	if( not icon ) then
		return msg
	end
	
	-- CT or RWFrame can be bigger due to more room
	local size = 12
	if( dest == "ct" ) then
		size = 18	
	elseif( dest == "rwframe" ) then
		size = select(2, self.alertFrame:GetFont())
	end

	return string.format("|T%s:%d:%d:0:-1|t %s", icon, size, size, msg)
end

function Spellbreak:SendMessage(msg, dest, color, spellID)
	-- We're ungrouped, so redirect it to RWFrame
	if( dest == "rw" and GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 ) then
		dest = "1"
	-- We're grouped, in a raid and not leader or assist
	elseif( dest == "rw" and not IsRaidLeader() and not IsRaidOfficer() and GetNumRaidMembers() > 0 ) then
		dest = "party"
	end
	
	-- Strip out any () leftover from no name being given
	msg = string.trim(string.gsub(msg, "%(%)", ""))
		
	-- Chat frame
	if( tonumber(dest) ) then
		local frame = getglobal("ChatFrame" .. dest) or DEFAULT_CHAT_FRAME
		frame:AddMessage("|cff33ff99Spellbreak|r|cffffffff:|r " .. self:WrapIcon(msg, dest, spellID), color.r, color.g, color.b)
	-- Raid warning announcement to raid/party
	elseif( dest == "rw" ) then
		SendChatMessage(msg, "RAID_WARNING")
	-- Raid warning frame, will not send it out to the party
	elseif( dest == "rwframe" ) then
		self.alertFrame:AddMessage(self:WrapIcon(msg, dest, spellID), color.r, color.g, color.b)
	-- Party chat
	elseif( dest == "party" ) then
		SendChatMessage(msg, "PARTY")
	-- Combat text
	elseif( dest == "ct" ) then
		self:CombatText(self:WrapIcon(msg, dest, spellID), color)
	end
end

function Spellbreak:CombatText(text, color, spellID)	
	-- SCT
	if( IsAddOnLoaded("sct") ) then
		SCT:DisplayText(text, color, nil, "event", 1)
	-- MSBT
	elseif( IsAddOnLoaded("MikScrollingBattleText") ) then
		MikSBT.DisplayMessage(text, MikSBT.DISPLAYTYPE_NOTIFICATION, false, color.r * 255, color.g * 255, color.b * 255)		
	-- Parrot
	elseif( IsAddOnLoaded("Parrot") ) then
		Parrot:ShowMessage(text, nil, nil, color.r, color.g, color.b)
	-- Blizzard Combat Text
	elseif( IsAddOnLoaded("Blizzard_CombatText") ) then
		-- Haven't cached the movement function yet
		if( not COMBAT_TEXT_SCROLL_FUNCTION ) then
			CombatText_UpdateDisplayedMessages()
		end
		
		CombatText_AddMessage(text, COMBAT_TEXT_SCROLL_FUNCTION, color.r, color.g, color.b)
	end
end

function Spellbreak:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Spellbreak|r: " .. msg)
end