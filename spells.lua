local L = SpellbreakLocals

SpellbreakSchools = {
	[0] = {text = L["All"], id = "ALL", icon = "Interface\\Icons\\Spell_Magic_LesserInvisibilty"},
	[1] = {text = L["Physical"], id = "PHYSICAL", icon = "Interface\\Icons\\Ability_Warrior_EndlessRage"},
	[2] = {text = L["Holy"], id = "HOLY", icon = "Interface\\Icons\\Spell_Holy_HealingAura"},
	[4] = {text = L["Fire"], id = "FIRE", icon = "Interface\\Icons\\Spell_Fire_Burnout"},
	[8] = {text = L["Nature"], id = "NATURE", icon = "Interface\\Icons\\Spell_Nature_Rejuvenation"},
	[16] = {text = L["Frost"], id = "FROST", icon = "Interface\\Icons\\Spell_Frost_ArcticWinds"},
	[32] = {text = L["Shadow"], id = "SHADOW", icon = "Interface\\Icons\\Spell_Shadow_ConeOfSilence"},
	[64] = {text = L["Arcane"], id = "ARCANE", icon = "Interface\\Icons\\Spell_Arcane_ArcaneTorrent"},
}

SpellbreakInterrupts = {
	-- Deadly Throw/Maim interrupt (Druid/Rogue Arena/Honor Gloves)
	[32747] = 3,
	
	-- Spell Lock
	[19244] = 5,
	[19647] = 6,
	
	-- Feral Charge - Bear
	[19675] = 4,
	
	-- Hammer of Justice
	[853] = 3,
	[5588] = 3,
	[5589] = 3,
	[10308] = 3,

	-- Bash
	[5211] = 3,
	[6798] = 3,
	[8983] = 3,
	
	-- Kick
	[1766] = 5,
	[1767] = 5,
	[1768] = 5,
	[1769] = 5,
	[38768] = 5,
	
	-- Pumeml
	[6552] = 4,
	[6554] = 4,
	
	-- Shield Bash
	[72] = 6,
	[1671] = 6,
	[1672] = 6,
	[29704] = 6,
		
	-- Earthshock
	[8042] = 2,
	[8044] = 2,
	[8045] = 2,
	[10412] = 2,
	[10413] = 2,
	[10414] = 2,
	[25454] = 2,
	[49230] = 2,
	[49231] = 2,
	
	-- Wind Shock
	[57994] = 2,

	-- Counterspell
	[2139] = 8,
	
	-- Mind Freeze
	[47528] = 4,
	
	-- Throwing Specialization
	[51680] = 3,
}

SpellbreakSilences = {
	-- Garrote
	[1330] = 3,
	
	-- Arcane Torrent (Energy version)
	[25046] = 2,
	
	-- Arcane Torrent (Mana version)
	[28730] = 2,
	
	-- Arcane Torrent (Runic power version)
	[50613] = 2,
	
	-- Silence
	[15487] = 5,

	-- Silencing Shot
	[34490] = 3,

	-- Improved Kick
	[18425] = 2,

	-- Improved Shield Bash
	[18498] = 3,

	-- Improved Counterspell
	[18469] = 4,
	
	-- Strangulate
	[47476] = 5,
	[49913] = 5,
	[49914] = 5,
	[49915] = 5,
	[49916] = 5,
	
	-- Gag Order (talent)
	[18498] = 3,
}

local ESLink = {linked = 25454, icon = "Interface\\Icons\\Spell_Nature_EarthShock", name = L["Earth Shock"]}
SpellbreakCD = {
	-- Bash
	[5211] = 60,
	[6798] = 60,
	[8983] = 60,

	-- Hammer of Justice
	[853] = 60,
	[5588] = 60,
	[5589] = 60,
	[10308] = 60,

	-- Mind Freeze
	[47528] = 10,
	
	-- Arcane Torrent (Energy version)
	[25046] = 120,
	
	-- Arcane Torrent (Mana version)
	[28730] = 120,

	-- Silence
	[15487] = 45,

	-- Silencing Shot
	[34490] = 20,
	
	-- Spell Lock
	[19244] = 24,
	[19647] = 24,
	
	-- Feral Charge
	[19675] = 15,

	-- Kick
	[1766] = 10,
	[1767] = 10,
	[1768] = 10,
	[1769] = 10,
	[38768] = 10,
	
	-- Pumeml
	[6552] = 10,
	[6554] = 10,
	
	-- Shield Bash
	[72] = 12,
	[1671] = 12,
	[1672] = 12,
	[29704] = 12,
		
	-- Earth shock
	[8042] = 6,
	[8044] = 6,
	[8045] = 6,
	[10412] = 6,
	[10413] = 6,
	[10414] = 6,
	[25454] = 6,
	
	-- Flame shock
	[8050] = ESLink,
	[8052] = ESLink,
	[8053] = ESLink,
	[10447] = ESLink,
	[10448] = ESLink,
	[10448] = ESLink,
	[25457] = ESLink,
	[29228] = ESLink,
	[49232] = ESLink,
	[49233] = ESLink,

	-- Frost shock
	[8056] = ESLink,
	[8058] = ESLink,
	[10472] = ESLink,
	[10473] = ESLink,
	[25464] = ESLink,
	[49235] = ESLink,
	[49236] = ESLink,
	
	-- Wind Shock
	[57994] = ESLink,

	-- Counterspell
	[2139] = 24,

	-- Improved Counterspell
	[18469] = 24,
}