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

SpellbreakLockouts = {
	-- Garrote
	[1330] = {removal = true, lockOut = 3, school = 0},
	
	-- Arcane Torrent (Energy version)
	[25046] = {removal = true, lockOut = 2, school = 0},
	
	-- Arcane Torrent (Mana version)
	[28730] = {removal = true, lockOut = 2, school = 0},
	
	-- Deadly Throw (Rogue Arena/Honor Gloves)

	--[26679] = 3,
	

	-- Maim (Vengeful Gladiator's Wyrmhide Gloves)
	--[22570] = 3,
	
	-- Silence
	[15487] = {removal = true, lockOut = 5, school = 0},

	-- Silencing Shot
	[34490] = {removal = true, lockOut = 3, school = 0},
	
	-- Spell Lock
	[19244] = 5,
	[19647] = 6,
	
	-- Feral Charge
	[19675] = 4,
	

	-- Kick
	[1766] = 5,
	[1767] = 5,
	[1768] = 5,
	[1769] = 5,
	[36768] = 5,

	-- Improved Kick
	[18425] = {removal = true, lockOut = 2, school = 0},
	
	-- Pumeml
	[6552] = 4,
	[6554] = 4,
	
	-- Shield Bash
	[72] = 6,
	[1671] = 6,
	[1672] = 6,
	[29704] = 6,
	
	-- Improved Shield Bash
	[18498] = {removal = true, lockOut = 3, school = 0},
	
	-- Earthshock
	[8042] = 2,
	[8044] = 2,
	[8045] = 2,
	[10412] = 2,
	[10413] = 2,
	[10414] = 2,
	[25454] = 2,
	

	-- Counterspell
	[2139] = 8,

	-- Improved Counterspell
	[18469] = {removal = true, lockOut = 4, school = 0},
}