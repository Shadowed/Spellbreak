Spellbreak = LibStub("AceAddon-3.0"):NewAddon("Spellbreak", "AceEvent-3.0")

local L = SpellbreakLocals

local SML, instanceType, GTBLib, GTBGroup

local lockoutTrack = {}
local lockoutQuickMap = {}
local cooldownList = {}

function Spellbreak:OnInitialize()
	self.defaults = {
		profile = {
			showAnchor = false,
			growUp = false,
			interruptCD = true,
			
			scale = 1.0,
			width = 180,
			maxRows = 30,
			fontSize = 12,
			fadeTime = 0.5,
			
			inside = {["arena"] = true, ["pvp"] = true},

			redirectTo = "",
			icon = "LEFT",
			fontName = "Friz Quadrata TT",
			texture = "BantoBar",

			announce = false,
			announceDest = "1",
			announceColor = { r = 1, g = 1, b = 1 },
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("SpellbreakDB", self.defaults)
	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)

	self.interrupts = SpellbreakInterrupts
	self.silences = SpellbreakSilences
	self.schools = SpellbreakSchools
	self.cooldowns = SpellbreakCD

	SML = LibStub:GetLibrary("LibSharedMedia-3.0")
	SML.RegisterCallback(self, "LibSharedMedia_Registered", "MediaRegistered")
	
	self:Reload()

	self.SML = SML
	self.GTBGroup = GTBGroup
	self.GTBLib = GTBLib
	
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
	self:OnEnable()

	-- Load GTB
	if( not GTBLib and not GTBGroup ) then
		GTBLib = LibStub:GetLibrary("GTB-1.0")
		GTBGroup = GTBLib:RegisterGroup("Spellbreak", SML:Fetch(SML.MediaType.STATUSBAR, self.db.profile.texture))
		GTBGroup:RegisterOnMove(self, "OnBarMove")
		GTBGroup:RegisterOnFade(self, "OnBarFade")
	end
	
	GTBGroup:SetScale(self.db.profile.scale)
	GTBGroup:SetWidth(self.db.profile.width)
	GTBGroup:SetDisplayGroup(self.db.profile.redirectTo ~= "" and self.db.profile.redirectTo or nil)
	GTBGroup:SetAnchorVisible(self.db.profile.showAnchor)
	GTBGroup:SetBarGrowth(self.db.profile.growUp and "UP" or "DOWN")
	GTBGroup:SetMaxBars(self.db.profile.maxRows)
	GTBGroup:SetFont(SML:Fetch(SML.MediaType.FONT, self.db.profile.fontName), self.db.profile.fontSize)
	GTBGroup:SetTexture(SML:Fetch(SML.MediaType.STATUSBAR, self.db.profile.texture))
	GTBGroup:SetFadeTime(self.db.profile.fadeTime)
	GTBGroup:SetIconPosition(self.db.profile.icon)
	
	if( self.db.profile.position ) then
		GTBGroup:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.position.x, self.db.profile.position.y)
	end
end

local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_REACTION_HOSTILE	= COMBATLOG_OBJECT_REACTION_HOSTILE
local GROUP_AFFILIATION = bit.bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_AFFILIATION_MINE)

local eventsRegistered = {["SPELL_CAST_SUCCESS"] = true, ["SPELL_AURA_APPLIED"] = true, ["SPELL_AURA_DISPELLED"] = true, ["SPELL_AURA_REMOVED"] = true, ["SPELL_INTERRUPT"] = true, ["SPELL_MISSED"] = true, ["SPELL_DAMAGE"] = true}
function Spellbreak:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)			
	if( not eventsRegistered[eventType] ) then return end
	
	-- Check if an enemy gained a silence
	if( eventType == "SPELL_AURA_APPLIED" and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, auraType = ...
		if( auraType == "DEBUFF" ) then
			self:ProcessLockout(eventType, spellID, spellName, extraSpellSchool, sourceName, sourceGUID, destName, destGUID)
		end
	
	-- Check if a friendly player used an interrupt
	elseif( eventType == "SPELL_CAST_SUCCESS" and bit.band(sourceFlags, GROUP_AFFILIATION) > 0 ) then
		local spellID, spellName, spellSchool = ...
		self:StartCooldown(spellID, spellName, sourceName, sourceGUID)
	
	-- Check if someone locked out a tree
	elseif( eventType == "SPELL_INTERRUPT" and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE and bit.band(sourceFlags, GROUP_AFFILIATION) > 0 ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool = ...
		self:ProcessLockout(eventType, spellID, spellName, extraSpellSchool, sourceName, sourceGUID, destName, destGUID)
	
	-- Check if a silence faded
	elseif( eventType == "SPELL_AURA_REMOVED" and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, auraType = ...
		if( auraType == "DEBUFF" ) then
			self:LockoutFaded(eventType, spellID, spellName, destGUID, destName)
		end
		
	elseif( eventType == "SPELL_MISSED" or eventType == "SPELL_DAMAGE" ) then
		if( bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE and bit.band(sourceFlags, GROUP_AFFILIATION) > 0 ) then
			local spellID, spellName, spellSchool = ...
			self:StartCooldown(spellID, spellName, sourceName, sourceGUID)
		end

	-- Check if a silence was dispelled
	elseif( eventType == "SPELL_AURA_DISPELLED" and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = ...
		if( auraType == "DEBUFF" ) then
			self:LockoutFaded(eventType, extraSpellID, extraSpellName, destGUID, destName)
		end
	end
end


function Spellbreak:StartCooldown(spellID, spellName, sourceName, sourceGUID)
	local cooldown = self.cooldowns[spellID]
	if( not self.db.profile.interruptCD or not cooldown or ( cooldownList[spellID .. sourceGUID] and cooldownList[spellID .. sourceGUID] > GetTime() ) ) then
		return
	end
	
	local seconds = 0
	local icon = "Interface\\Icons\\Ability_Stealth"
	if( type(cooldown) == "table" ) then
		seconds = self.cooldowns[cooldown.linked]
		icon = cooldown.icon
		spellName = cooldown.name
	else
		seconds = cooldown
		icon = select(3, GetSpellInfo(spellID))
	end
	
	cooldownList[spellID .. sourceGUID] = GetTime() + seconds
	
	local text
	if( sourceName ) then
		text = string.format("[CD] %s - %s", sourceName, spellName)
	else
		text = string.format("[CD] %s", spellName)
	end
	
	GTBGroup:RegisterBar(spellID .. sourceGUID, text, seconds, nil, icon)
end

function Spellbreak:ProcessLockout(eventType, spellID, spellName, lockedSchool, sourceName, sourceGUID, destName, destGUID)
	local seconds = self.interrupts[spellID]
	
	if( not seconds and not self.silences[spellID] ) then
		return
		
	-- Silence, so it locks all trees
	elseif( self.silences[spellID] ) then
		seconds = self.silences[spellID]
		lockedSchool = 0
	end
	
	lockedSchool = lockedSchool or 0
	
	-- First figure out the seconds in the lockout, along with the icon to use for the school locked
	local school = self.schools[lockedSchool]
	endTime = GetTime() + seconds
	
	local id = destGUID .. lockedSchool
	if( not lockoutTrack[id] ) then
		lockoutTrack[id] = {endTime = 0}
	end
	
	-- If we already have a lockout for this school, and the time left is longer then this request, then reject it
	local currentLock = lockoutTrack[id]
	if( currentLock and currentLock.endTime > endTime ) then
		return
	end
	
	lockoutTrack[id].endTime = endTime
	lockoutTrack[id].spellID = spellID
	lockoutTrack[id].spellName = spellName
	lockoutTrack[id].lockedSchool = lockedSchool
	lockoutTrack[id].destName = destName
	
	lockoutQuickMap[destGUID .. spellID] = id
	
	GTBGroup:RegisterBar(id, string.format("%s - %s", school.text, destName), seconds, nil, school.icon)
	
	if( self.db.profile.announce ) then
		self:SendMessage(string.format(L["LOCKED %s %s (%d seconds)"], destName, school.text, seconds), self.db.profile.announceDest, self.db.profile.announceColor)
	end
end

function Spellbreak:LockoutFaded(eventType, spellID, spellName, destGUID, destName)
	local id = lockoutQuickMap[destGUID .. spellID]
	if( ( not self.interrupts[spellID] and not self.silences[spellID] ) or not id ) then
		return
	end
	
	local currentLock = lockoutTrack[id]
	if( not currentLock ) then
		return
	end
	
	GTBGroup:UnregisterBar(id)
	if( self.db.profile.announce ) then
		self:SendMessage(string.format(L["UNLOCKED %s %s"], destName, self.schools[currentLock.lockedSchool].text), self.db.profile.announceDest, self.db.profile.announceColor)
	end
end

function Spellbreak:OnBarFade(barID)
	if( not barID ) then
		return
	end

	local currentLock = lockoutTrack[barID]
	if( currentLock and self.db.profile.announce ) then
		self:SendMessage(string.format(L["UNLOCKED %s %s"], currentLock.destName, self.schools[currentLock.lockedSchool].text), self.db.profile.announceDest, self.db.profile.announceColor)
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
			GTBGroup:UnregisterAllBars()
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

function Spellbreak:SendMessage(msg, dest, color)
	if( dest == "none" ) then
		return
	end

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
		frame:AddMessage("|cff33ff99Spellbreak|r|cffffffff:|r " .. msg, color.r, color.g, color.b)
	-- Raid warning announcement to raid/party
	elseif( dest == "rw" ) then
		SendChatMessage(msg, "RAID_WARNING")
	-- Raid warning frame, will not send it out to the party
	elseif( dest == "rwframe" ) then
		self.alertFrame:AddMessage(msg, color.r, color.g, color.b)
	-- Party chat
	elseif( dest == "party" ) then
		SendChatMessage(msg, "PARTY")
	-- Combat text
	elseif( dest == "ct" ) then
		self:CombatText(msg, color)
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

function Spellbreak:OnBarMove(parent, x, y)
	if( not Spellbreak.db.profile.position ) then
		Spellbreak.db.profile.position = {}
	end

	Spellbreak.db.profile.position.x = x
	Spellbreak.db.profile.position.y = y
end

function Spellbreak:MediaRegistered(event, mediaType, key)
	if( mediaType == SML.MediaType.STATUSBAR and self.db.profile.texture == key ) then
		GTBGroup:SetTexture(SML:Fetch(SML.MediaType.STATUSBAR, self.db.profile.texture))
	elseif( mediaType == SML.MediaType.FONT and self.db.profile.fontName ) then
		GTBGroup:SetFont(SML:Fetch(SML.MediaType.FONT, self.db.profile.fontName), self.db.profile.fontSize)
	end
end
