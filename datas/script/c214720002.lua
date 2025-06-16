Duel.LoadScript("skills_archive.lua")
--Hyperspeed Rush Road!!
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,id+1,1,nil,nil)
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
	if Duel.GetFlagEffect(tp,id)==0 then
		local valid=not Duel.IsExistingMatchingCard(function(c)
			local code=c:GetOriginalCode()
			return (code<160000000 or code>160999999) and not c:IsOriginalType(TYPE_SKILL)
		end,tp,LOCATION_ALL,0,1,nil)
		if valid then
			Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
			Duel.Hint(HINT_CARD,tp,id)
			--predraw
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PREDRAW)
			e1:SetCondition(s.prdcon)
			e1:SetOperation(s.prdop)
			Duel.RegisterEffect(e1,tp)
			--normal summon/set count
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetTargetRange(1,0)
			e2:SetValue(1000)
			Duel.RegisterEffect(e2,tp)
			--Disable zones
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_FORCE_MZONE)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e3:SetTargetRange(1,0)
			e3:SetValue(function() return 0xe end)
			Duel.RegisterEffect(e3,tp)
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_DISABLE_FIELD)
			e4:SetCondition(function(e) return not Duel.IsDuelType(DUEL_3_COLUMNS_FIELD) end)
			e4:SetOperation(function(e,tp) return 0x1111 end)
			Duel.RegisterEffect(e4,tp)
			--skip
			local e5=Effect.CreateEffect(e:GetHandler())
			e5:SetType(EFFECT_TYPE_FIELD)
			e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e5:SetTargetRange(1,0)
			e5:SetCode(EFFECT_SKIP_M2)
			Duel.RegisterEffect(e5,tp)
		else
			--Invalid Skill
			local e6=Effect.CreateEffect(e:GetHandler())
			e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e6:SetDescription(aux.Stringid(id+1,0))
			e6:SetCode(0)
			e6:SetTargetRange(1,0)
			Duel.RegisterEffect(e6,tp)
		end
	end
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end
--predraw
function s.prdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetDrawCount(tp)>0
end
function s.prdop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetDrawCount(tp)
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_DRAW_COUNT) then ct=math.max(ct,5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)) end
	if Duel.GetTurnCount()>1 or Duel.IsDuelType(DUEL_1ST_TURN_DRAW) then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_DRAW)
		e1:SetValue(ct)
		Duel.RegisterEffect(e1,tp)
	else
		Duel.Draw(tp,ct,REASON_RULE)
	end
end
