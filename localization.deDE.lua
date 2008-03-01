if( GetLocale() ~= "deDE" ) then
	return
end

SpellbreakLocals = setmetatable({
}, {__index = SpellbreakLocals})