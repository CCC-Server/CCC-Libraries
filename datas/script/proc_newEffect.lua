--Check name clash
if newEffect then return end
--Constants
local EFFECT_START  = 0xFFF << 0xF
local newCodes      = {}
--Declare newEffect
newEffect           = (function(class)
	local proxy={}
	local mt={
		__index     = function(t,k)
			--getter
			return class[k]
		end,
		__newindex  = function(t,k,v)
			--setter (read only)
			if class[k] then error("attempt to assign to const variable 'newEffect."..k.."'",2) end
			class[k]=v
		end
	}
	setmetatable(proxy,mt)
	return proxy
end)({
newCode             = function()
	local newId=EFFECT_START+#(newCodes)
	table.insert(newCodes,newId)
	return newId
end
})
--[[
How to use

newEffect.newCode()
	Returns a new constant for Effect.SetCode
	Usage :
		EFFECT_SPIRIT_ELIMINATION = newEffect.newCode()
		
newEffect[i]
	Returns corresponding table for a specific effect code
	Its fields are considered as constant, meaning they cannot be overwritten
	Usage :
		newEffect[i].AffectCard = function(c,ct) ......... end
		
--]]