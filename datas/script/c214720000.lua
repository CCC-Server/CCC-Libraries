Duel.LoadScript("skills_archive.lua")
--Custom Card Creators
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
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.GetFlagEffect(tp,id)==0 then
		--To field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCondition(s.con)
		e1:SetOperation(s.op)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end
function s.mftfilter(c,mft1,mft2,mft3)
	if not c:IsLocation(LOCATION_EXTRA) then
		return mft1>0
	elseif c:IsLinkMonster() or c:IsFaceup() then
		return mft2>0
	end
	return mft3>0
end
function s.filter(c,e,tp,mft,sft)
	if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
	local b1=c:IsMonster() and s.mftfilter(c,table.unpack(mft))
		and ((c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
			or (not c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,true,true)))
	local b2=(c:IsFieldSpell() or (sft>0 and c:IsContinuousSpellTrap()))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
	local b3=(c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and s.mftfilter(c,table.unpack(mft)))
		or ((c:IsFieldSpell() or (sft>0 and c:IsSpellTrap())) and c:IsSSetable())
	return (b1 or b2 or b3)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local mft={Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.GetLocationCountFromEx(tp),Duel.GetUsableMZoneCount(tp)}
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	return Duel.IsExistingMatchingCard(s.filter,tp,0x73,0,1,nil,e,tp,mft,sft)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local mft={Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.GetLocationCountFromEx(tp),Duel.GetUsableMZoneCount(tp)}
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if Duel.IsExistingMatchingCard(s.filter,tp,0x73,0,1,nil,e,tp,mft,sft) then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.filter,tp,0x73,0,1,1,nil,e,tp,mft,sft):GetFirst()
		local b1=tc:IsMonster() and s.mftfilter(tc,table.unpack(mft)) and tc:IsSummonableCard() and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
		local b2=tc:IsMonster() and s.mftfilter(tc,table.unpack(mft)) and not tc:IsSummonableCard() and tc:IsCanBeSpecialSummoned(e,0,tp,true,true)
		local b3=tc:IsFieldSpell() and not tc:IsForbidden() and tc:CheckUniqueOnField(tp)
		local b4=sft>0 and tc:IsContinuousSpellTrap() and not tc:IsForbidden() and tc:CheckUniqueOnField(tp)
		local b5=(tc:IsMonster() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and s.mftfilter(tc,table.unpack(mft)))
			or ((tc:IsFieldSpell() or (sft>0 and tc:IsSpellTrap())) and tc:IsSSetable())
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)},
			{b3,aux.Stringid(id,2)},
			{b4,aux.Stringid(id,3)},
			{b5,aux.Stringid(id,4)})
		if op==1 then
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		elseif op==2 then
			local ct=Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
			if ct>0 then
				tc:CompleteProcedure()
			end
		elseif op==3 then
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		elseif op==4 then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		else
			if tc:IsMonster() then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SSet(tp,tc)
			end
		end
	end
end
