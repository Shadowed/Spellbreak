-- Translated by wowui.cn

if( GetLocale() ~= "zhCN" ) then
	return
end

SpellbreakLocals = setmetatable({
	["LOCKED %s %s (%d seconds)"] = "锁定 %s %s (%d 秒)",
	["UNLOCKED %s %s"] = "解锁 %s %s",
	
	["ALT + Drag to move the frame anchor."] = "ALT + 鼠标拖动移动框体.",
	
	["All"] = "全部",
	["Physical"] = "物理",
	["Holy"] = "神圣",
	["Fire"] = "火焰",
	["Nature"] = "自然",
	["Frost"] = "冰霜",
	["Shadow"] = "暗夜",
	["Arcane"] = "奥术",
	
	["Spellbreak"] = "Spellbreak",
	
	["Earth Shock"] = "大地震击",
	
	-- Cmd
	["Spellbreak Slash Commands"] = "Spellbreak命令行(wowui.cn汉化)",
	["/spellbreak test - Shows 3 test bars."] = "/spellbreak test - 显示3个测试条.",
	["/spellbreak ui - Opens the Spellbreak OptionHouse configuration."] = "/spellbreak ui - 打开配置窗口.",
	
	-- GUI
	["General"] = "常规选项",
	["Alerts"] = "警报",
	
	["Show friendly interrupt cooldowns"] = "显示友方打断的冷却时间",
	["Shows how many second friendly players have on their interrupts."] = "显示友方玩家的打断技能的剩余秒数.",

	["Enable alerts"] = "启用警报",
	["Enables sending of lockout alerts to a set location."] = "启用警报.",
	
	["Announce channel"] = "通报到频道",
	["Channel to send school lockouts to."] = "发送法术系被锁定到.",
	["Combat Text"] = "战斗文字",
	["Raid Warning"] = "团队警报",
	["Party"] = "小队",
	["Chat frame #%d"] = "聊天框体 #%d",
	
	["Announce color"] = "通报颜色",
	["Color the text should be shown in if you're outputting using \"Combat text\"."] = "通报颜色，要选择 \"战斗文字\".",
	
	["None"] = "无",

	["Show anchor"] = "显示锚点",
	
	["Grow display up"] = "向上增长",
	["Instead of adding everything from top to bottom, timers will be shown from bottom to top."] = "计时条由下向上增长.",

	["Redirect bars to group"] = "重定向计时条",
	
	["Display scale"] = "显示缩放",
	["Max timers"] = "计时条上限",
	["Icon position"] = "图标位置",
	["Left"] = "左",
	["Right"] = "右",

	["Everywhere else"] = "任何地方",
	["Battlegrounds"] = "战场",
	["Arenas"] = "竞技场",
	["Raid instances"] = "团队副本",
	["Party instances"] = "小队副本",

	["Enable Spellbreak inside"] = "在以下环境下启用",
	["Allows you to choose which scenarios this mod should be enabled in."] = "允许你设置在什么情况下启用DRTracker.",
	
	["Bar display"] = "计时条显示",
	
	["Bar color"] = "计时条颜色",
	
	["Fade time"] = "渐隐时间",
	
	["Texture"] = "材质",
	["Width"] = "宽",
	["Color"] = "颜色",
	
	["None"] = "无",
	["Text"] = "文字",
	["Size"] = "大小",
	["Font"] = "字体",
}, {__index = SpellbreakLocals})