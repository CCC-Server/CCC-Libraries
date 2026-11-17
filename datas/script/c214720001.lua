Duel.LoadScript("skills_archive.lua")
--Dreamy Dream Dreamers
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,SKILL_COVER_ARCHIVE_START,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SKILL)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EFFECT_TOSS_DICE_CHOOSE)
		ge1:SetCondition(function(e,tp,eg,ep) return Duel.HasFlagEffect(ep,id) end)
		ge1:SetOperation(s.repop(true,Duel.SetDiceResult,function(tp)
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(300102004,3))
			return Duel.AnnounceNumberRange(tp,1,6)
		end))
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_TOSS_COIN_CHOOSE)
		ge2:SetOperation(s.repop(false,Duel.SetCoinResult,function(tp)
			return Duel.AnnounceCoin(tp,aux.Stringid(300102004,4))
		end))
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.GetFlagEffect(tp,id)==0 then
		--predraw
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.prdcon)
		e1:SetOperation(s.prdop)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end
--replace draw
function s.prdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp
		and Duel.GetDrawCount(tp)>0 and (Duel.GetTurnCount()>1 or Duel.IsDuelType(DUEL_1ST_TURN_DRAW))
end
function s.prdop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	local ct=Duel.GetDrawCount(tp)
	if Duel.IsDuelType(DUEL_DRAW_UNTIL_5) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_DRAW_COUNT) then ct=math.max(ct,5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)) end
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
	if ct>#dg or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sg=dg:Select(tp,ct,ct,false,nil)
	if sg and #sg>0 then
		Duel.DisableShuffleCheck()
		Duel.MoveToDeckTop(sg)
		if #sg>1 then Duel.SortDecktop(tp,tp,#sg) end
	end
end
--replace coin and dice
function s.repop(isdice,func2,func3)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local total=(ev&0xff)+(ev>>16)
		local res={}
		--ask if you want to activate the skill or not
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			--replace
			for i=1,total do
				table.insert(res,func3(ep))
			end
		else
			for i=1,total do
				if isdice then
					table.insert(res,Duel.GetRandomNumber(1,6))
				else
					table.insert(res,Duel.GetRandomNumber(0,1)==0 and COIN_TAILS or COIN_HEADS)
				end
			end
		end
		func2(table.unpack(res))
	end
end
