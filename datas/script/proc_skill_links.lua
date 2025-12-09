-- constants
LOCATION_SKILL = LOCATION_DECK|LOCATION_HAND|LOCATION_MZONE|LOCATION_SZONE|LOCATION_GRAVE|LOCATION_EXTRA --0x5f

-- coverNum fix
local aux_setskillop = Auxiliary.SetSkillOp
Auxiliary.SetSkillOp = function(coverNum,skillcon,skillop,countlimit,efftype)
	local skillop = aux_setskillop(coverNum,skillcon,skillop,countlimit,efftype)
	if coverNum<1000 then return skillop end
	return function(e,tp,eg,ep,ev,re,r,rp,...)
		--override Duel.Hint
		local duel_hint=Duel.Hint
		Duel.Hint=function(hint_type,player,desc)
			if not hint_type==HINT_SKILL_COVER then
				duel_hint(hint_type,player,desc)
				return
			end
			duel_hint(HINT_SKILL_COVER,player,coverNum)
		end
		--operate given operation
		skillop(e,tp,eg,ep,ev,re,r,rp,...)
		--revert Duel.Hint
		Duel.Hint=duel_hint
	end
end

-- replace starting hand
local StartingHandCondition={
	[0]=aux.FALSE,
	[1]=aux.FALSE
}
function Auxiliary.AddStartingHandCondition(tp,f)
end
-- To do...
