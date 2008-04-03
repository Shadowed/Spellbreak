if( not Spellbreak ) then
	return
end

local Config = Spellbreak:NewModule("Config")
local L = SpellbreakLocals

local OptionHouse
local HouseAuthority
local OHObj
local SML

function Config:OnInitialize()
	-- Open the OH UI
	SLASH_SPELLBREAK1 = "/spellbreak"
	SLASH_SPELLBREAK2 = "/spellbreaker"
	SlashCmdList["SPELLBREAK"] = function(msg)
		if( msg == "test" ) then
			Spellbreak.GTBGroup:RegisterBar("test1", 5, string.format("%s - %s", Spellbreak.schools[2].text, UnitName("player")), Spellbreak.schools[2].icon)
			Spellbreak.GTBGroup:RegisterBar("test2", 10, string.format("%s - %s", Spellbreak.schools[4].text, UnitName("player")), Spellbreak.schools[4].icon)
			Spellbreak.GTBGroup:RegisterBar("test3", 15, string.format("%s - %s", Spellbreak.schools[8].text, UnitName("player")), Spellbreak.schools[8].icon)
		elseif( msg == "ui" ) then
			OptionHouse:Open("Spellbreak")
		else
			DEFAULT_CHAT_FRAME:AddMessage(L["Spellbreak Slash Commands"])
			DEFAULT_CHAT_FRAME:AddMessage(L["/spellbreak test - Shows 3 test bars."])
			DEFAULT_CHAT_FRAME:AddMessage(L["/spellbreak ui - Opens the Spellbreak OptionHouse configuration."])
		end
	end
		
	-- Register with OptionHouse
	OptionHouse = LibStub("OptionHouse-1.1")
	HouseAuthority = LibStub("HousingAuthority-1.2")
	
	OHObj = OptionHouse:RegisterAddOn("Spellbreak", nil, "Mayen", "r" .. max(tonumber(string.match("$Revision: 599 $", "(%d+)") or 1), Spellbreak.revision))
	OHObj:RegisterCategory(L["General"], self, "CreateUI", nil, 1)

	-- Register our default list of textures with SML
	SML = Spellbreak.SML
	SML:Register(SML.MediaType.STATUSBAR, "BantoBar", "Interface\\Addons\\Spellbreak\\images\\banto")
	SML:Register(SML.MediaType.STATUSBAR, "Smooth",   "Interface\\Addons\\Spellbreak\\images\\smooth")
	SML:Register(SML.MediaType.STATUSBAR, "Perl",     "Interface\\Addons\\Spellbreak\\images\\perl")
	SML:Register(SML.MediaType.STATUSBAR, "Glaze",    "Interface\\Addons\\Spellbreak\\images\\glaze")
	SML:Register(SML.MediaType.STATUSBAR, "Charcoal", "Interface\\Addons\\Spellbreak\\images\\Charcoal")
	SML:Register(SML.MediaType.STATUSBAR, "Otravi",   "Interface\\Addons\\Spellbreak\\images\\otravi")
	SML:Register(SML.MediaType.STATUSBAR, "Striped",  "Interface\\Addons\\Spellbreak\\images\\striped")
	SML:Register(SML.MediaType.STATUSBAR, "LiteStep", "Interface\\Addons\\Spellbreak\\images\\LiteStep")
end

-- GUI
function Config:Set(var, value)
	Spellbreak.db.profile[var] = value
end

function Config:Get(var)
	return Spellbreak.db.profile[var]
end

function Config:Reload()
	Spellbreak:Reload()
end

function Config:CreateUI()
	local textures = {}
	for _, name in pairs(SML:List(SML.MediaType.STATUSBAR)) do
		table.insert(textures, {name, name})
	end

	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Only enable inside"], help = L["Only enable Spellbreak inside the specified areas."], type = "dropdown", list = {{"none", L["Everywhere else"]}, {"pvp", L["Battlegrounds"]}, {"arena", L["Arenas"]}, {"raid", L["Raid Instances"]}, {"party", L["Party Instances"]}}, multi = true, var = "inside"},
		{ order = 2, group = L["General"], text = L["Show friendly interrupt cooldowns"], help = L["Shows how many second friendly players have on their interrupts."], type = "check", var = "interruptCD"},
		{ order = 2, group = L["General"], text = L["Lock anchor"], help = L["Locks the anchor for moving the timer bar."], type = "check", var = "locked"},
		{ order = 3, group = L["General"], format = L["Scale: %d%%"], min = 0.0, max = 2.0, default = 1.0, type = "slider", var = "scale"},
		{ order = 4, group = L["General"], format = L["Bar size"], min = 10, max = 300, maxText = "300", minText = "10", default = 120, type = "slider", var = "width"},
		{ order = 5, group = L["General"], text = L["Bar texture"], help = L["Texture to be used for the timer bars."], type = "dropdown", list = textures, var = "texture"},

		{ group = L["Alerts"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Alerts"], text = L["Enable alerts"], help = L["Enables sending of lockout alerts to a set location."], type = "check", var = "announce"},
		{ order = 2, group = L["Alerts"], text = L["Announce channel"], help = L["Channel to send school lockouts to."], type = "dropdown", list = {{"none", L["None"]}, {"ct", L["Combat Text"]}, {"rw", L["Raid Warning"]}, {"party", L["Party"]}, {1, string.format(L["Chat frame #%d"], 1)}, {2, string.format(L["Chat frame #%d"], 2)}, {3, string.format(L["Chat frame #%d"], 3)}, {4, string.format(L["Chat frame #%d"], 4)}, {5, string.format(L["Chat frame #%d"], 5)}, {6, string.format(L["Chat frame #%d"], 6)}, {7, string.format(L["Chat frame #%d"], 7)}}, var = "announceDest"},
		{ order = 3, group = L["Alerts"], text = L["Announce color"], help = L["Color the text should be shown in if you're outputting using \"Combat text\"."], type = "color", var = "announceColor"},
	}

	local displayAnchors = {}
	table.insert(displayAnchors, {"", L["None"]})
	for name, data in pairs(Spellbreak.GTBLib:GetGroups()) do
		table.insert(displayAnchors, {name, name})
	end

	table.insert(config, { group = L["Redirection"], type = "groupOrder", order = 2 })
	table.insert(config, { order = 1, group = L["Redirection"], text = L["Redirect bar timers to"], help = L["Allows you to set another bar group to send these timers to, only supports GTB based timers."], type = "dropdown", list = displayAnchors, var = "redirectTo"})

	return HouseAuthority:CreateConfiguration(config, {set = "Set", get = "Get", onSet = "Reload", handler = self})	
end
