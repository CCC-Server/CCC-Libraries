Duel.LoadScript("skills_archive.lua")
--LP増強α
local s,id=GetID()
function s.initial_effect(c)
	aux.addStartingLPCheck()
	aux.AddSkillProcedure(c,SKILL_COVER_ARCHIVE_START,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SKILL)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--activate
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.GetFlagEffect(tp,id)==0 then
		--add LP
		Duel.SetLP(tp,Duel.GetLP(tp)+(Duel.GetStartingLP(tp)/4))
	end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
