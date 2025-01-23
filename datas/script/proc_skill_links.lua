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

-- Proc for skills that determines starting hand
-- c: the card (card)
-- coverId: the Id of the cover (int)
-- include_filter: card filter that returns true if a card must be included to starting hand (function or nil)
-- exclude_filter: card filter that returns true if a card must be excluded to starting hand (function or nil)
-- skillcon: condition to activate the skill (function or nil)
-- skillop: operation related to the skill activation, mostly oath (function or nil)
Auxiliary.AddStartingHandsSkillProcedure = aux.FunctionWithNamedArgs(
function(c,coverNum,include_filter,exclude_filter,skillcon,skillop)
	--To do...

end,"handler","coverNum","include_filter","exclude_filter","skillcon","skillop")

-- Proc for Deck Recipe condition
-- min1: can be omitted, 1 as default (int)
-- min2: can be omitted, nil as default (int)
-- max1: can be omitted, nil as default (int)
-- max2: can be omitted, 0 as default (int)
-- if min1 is another filter (function), this condition is regarded as function(con,functions...,mins...,maxs...) form, with same amounts of arguments each
Auxiliary.CreateDeckRecipeCondition = aux.FunctionWithNamedArgs(
function(con,fil1,fil2,min1,min2,max1,max2,...)
	--To do...
	
end,"skillcon","include_filter","exclude_filter","include_min","exclude_min","include_max","exclude_max")
