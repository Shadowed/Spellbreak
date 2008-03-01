if( GetLocale() ~= "frFR" ) then
	return
end

SpellbreakLocals = setmetatable({

}, {__index = SpellbreakLocals})