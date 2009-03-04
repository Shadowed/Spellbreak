if( not Spellbreak ) then return end

local Config = Spellbreak:NewModule("Config")
local L = SpellbreakLocals

local SML, registered, options, config, dialog

function Config:OnInitialize()
	config = LibStub("AceConfig-3.0")
	dialog = LibStub("AceConfigDialog-3.0")
	
	-- Register bar textures
	SML = LibStub:GetLibrary("LibSharedMedia-3.0")
	SML:Register(SML.MediaType.STATUSBAR, "BantoBar",   "Interface\\Addons\\Spellbreak\\images\\banto")
	SML:Register(SML.MediaType.STATUSBAR, "Smooth",     "Interface\\Addons\\Spellbreak\\images\\smooth")
	SML:Register(SML.MediaType.STATUSBAR, "Perl",       "Interface\\Addons\\Spellbreak\\images\\perl")
	SML:Register(SML.MediaType.STATUSBAR, "Glaze",      "Interface\\Addons\\Spellbreak\\images\\glaze")
	SML:Register(SML.MediaType.STATUSBAR, "Charcoal",   "Interface\\Addons\\Spellbreak\\images\\Charcoal")
	SML:Register(SML.MediaType.STATUSBAR, "Otravi",     "Interface\\Addons\\Spellbreak\\images\\otravi")
	SML:Register(SML.MediaType.STATUSBAR, "Striped",    "Interface\\Addons\\Spellbreak\\images\\striped")
	SML:Register(SML.MediaType.STATUSBAR, "LiteStep",   "Interface\\Addons\\Spellbreak\\images\\LiteStep")
	SML:Register(SML.MediaType.STATUSBAR, "Minimalist", "Interface\\Addons\\Spellbreak\\images\\Minimalist")
end

local function set(info, value)
	Spellbreak.db.profile[info[(#info)]] = value
	Spellbreak:Reload()
end

local function get(info)
	return Spellbreak.db.profile[info[(#info)]]
end

local function setNumber(info, value)
	set(info, tonumber(value))
end

local function setMulti(info, state, value)
	Spellbreak.db.profile[info[(#info)]][state] = value
	Spellbreak:Reload()
end

local function getMulti(info, state)
	return Spellbreak.db.profile[info[(#info)]][state]
end

-- Set/Get colors
local function setColor(info, r, g, b)
	set(info, {r = r, g = g, b = b})
end

local function getColor(info)
	local value = get(info)
	if( type(value) == "table" ) then
		return value.r, value.g, value.b
	end
	
	return value
end

-- Grab textures/font
local textures = {}
function Config:GetTextures()
	for k in pairs(textures) do textures[k] = nil end

	for _, name in pairs(SML:List(SML.MediaType.STATUSBAR)) do
		textures[name] = name
	end
	
	return textures
end

local fonts = {}
function Config:GetFonts()
	for k in pairs(fonts) do fonts[k] = nil end

	for _, name in pairs(SML:List(SML.MediaType.FONT)) do
		fonts[name] = name
	end
	
	return fonts
end

local groups = {}
local GTB
function Config:GetGroups()
	for k in pairs(groups) do groups[k] = nil end
	
	if( not GTB ) then
		GTB = LibStub("GTB-1.0")
	end
	
	groups[""] = L["None"]
	for name, data in pairs(GTB:GetGroups()) do
		groups[name] = name
	end
	
	return groups
end

local function loadOptions()
	options = {}
	options.type = "group"
	options.name = "Spellbreak"
	
	options.args = {}
	options.args.general = {
		type = "group",
		order = 1,
		name = L["General"],
		get = get,
		set = set,
		handler = Config,
		args = {
			general = {
				order = 1,
				type = "group",
				inline = true,
				name = L["General"],
				args = {
					showAnchor = {
						order = 0,
						type = "toggle",
						name = L["Show anchor"],
						desc = L["Instead of adding everything from top to bottom, timers will be shown from bottom to top."],
					},
					growUp = {
						order = 1,
						type = "toggle",
						name = L["Grow display up"],
						desc = L["Instead of adding everything from top to bottom, timers will be shown from bottom to top."],
					},
					sep = {
						order = 3,
						name = "",
						type = "description",
					},
					redirectTo = {
						order = 4,
						type = "select",
						name = L["Redirect bars to group"],
						values = "GetGroups",
					},
					icon = {
						order = 5,
						type = "select",
						name = L["Icon position"],
						values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
					},
					sep = {
						order = 6,
						name = "",
						type = "description",
					},
					fadeTime = {
						order = 7,
						type = "range",
						name = L["Fade time"],
						min = 0, max = 2, step = 0.1,
					},
					sep = {
						order = 8,
						name = "",
						type = "description",
					},
					scale = {
						order = 9,
						type = "range",
						name = L["Display scale"],
						min = 0, max = 2, step = 0.01,
					},
					maxRows = {
						order = 10,
						type = "range",
						name = L["Max timers"],
						min = 1, max = 100, step = 1,
					},
					sep = {
						order = 11,
						name = "",
						type = "description",
					},
					inside = {
						order = 12,
						type = "multiselect",
						name = L["Enable Spellbreak inside"],
						desc = L["Allows you to choose which scenarios this mod should be enabled in."],
						values = {["none"] = L["Everywhere else"], ["pvp"] = L["Battlegrounds"], ["arena"] = L["Arenas"], ["raid"] = L["Raid instances"], ["party"] = L["Party instances"]},
						set = setMulti,
						get = getMulti,
					},
				}
			},
			bar = {
				order = 2,
				type = "group",
				inline = true,
				name = L["Bar display"],
				args = {
					width = {
						order = 3,
						type = "range",
						name = L["Width"],
						min = 50, max = 300, step = 1,
						set = setNumber,
					},
					texture = {
						order = 5,
						type = "select",
						name = L["Texture"],
						dialogControl = "LSM30_Statusbar",
						values = "GetTextures",
					},
				},
			},
			text = {
				order = 3,
				type = "group",
				inline = true,
				name = L["Text"],
				args = {
					fontSize = {
						order = 1,
						type = "range",
						name = L["Size"],
						min = 1, max = 20, step = 1,
						set = setNumber,
					},
					fontName = {
						order = 2,
						type = "select",
						name = L["Font"],
						dialogControl = "LSM30_Font",
						values = "GetFonts",
					},
				},
			},
		}
	}

	-- DB Profiles
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Spellbreak.db)
	options.args.profile.order = 5
end

-- Slash commands
SLASH_SPELLBREAK1 = "/spellbreak"
SLASH_SPELLBREAK2 = "/spellbreaker"
SlashCmdList["SPELLBREAK"] = function(msg)
	if( msg == "test" ) then
		Spellbreak.GTBGroup:RegisterBar("test1", string.format("%s - %s", Spellbreak.schools[2].text, UnitName("player")), 5, nil, Spellbreak.schools[2].icon)
		Spellbreak.GTBGroup:RegisterBar("test2", string.format("%s - %s", Spellbreak.schools[4].text, UnitName("player")), 10, nil, Spellbreak.schools[4].icon)
		Spellbreak.GTBGroup:RegisterBar("test3", string.format("%s - %s", Spellbreak.schools[8].text, UnitName("player")), 15, nil, Spellbreak.schools[8].icon)
	elseif( msg == "ui" ) then
		if( not registered ) then
			if( not options ) then
				loadOptions()
			end

			config:RegisterOptionsTable("Spellbreak", options)
			dialog:SetDefaultSize("Spellbreak", 650, 525)
			registered = true
		end

		dialog:Open("Spellbreak")
	else
		DEFAULT_CHAT_FRAME:AddMessage(L["Spellbreak Slash Commands"])
		DEFAULT_CHAT_FRAME:AddMessage(L["/spellbreak test - Shows 3 test bars."])
		DEFAULT_CHAT_FRAME:AddMessage(L["/spellbreak ui - Opens the Spellbreak configuration."])
	end
end

-- Toss this into the Blizzard UI thing too
local register = CreateFrame("Frame", nil, InterfaceOptionsFrame)
register:SetScript("OnShow", function(self)
	self:SetScript("OnShow", nil)
	loadOptions()

	config:RegisterOptionsTable("Spellbreak-Bliz", {
		name = "Spellbreak",
		type = "group",
		args = {
			help = {
				type = "description",
				name = string.format("Spellbreak r%d is an interrupt and lockout mod for PvP.", Spellbreak.revision or 0),
			},
		},
	})
	
	dialog:SetDefaultSize("Spellbreak-Bliz", 600, 400)
	dialog:AddToBlizOptions("Spellbreak-Bliz", "Spellbreak")
	
	config:RegisterOptionsTable("Spellbreak-General", options.args.general)
	dialog:AddToBlizOptions("Spellbreak-General", options.args.general.name, "Spellbreak")

	config:RegisterOptionsTable("Spellbreak-Profile", options.args.profile)
	dialog:AddToBlizOptions("Spellbreak-Profile", options.args.profile.name, "Spellbreak")
end)