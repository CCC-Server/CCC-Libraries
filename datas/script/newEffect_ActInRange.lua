Duel.LoadScript("proc_newEffect.lua")

--Declaration
if newEffect.ActInRange then return end
newEffect.ActInRange = {}
--Constant(s)
EFFECT_ACT_IN_RANGE  = newEffect.newCode()
local CheckEnabled   = false

--Global Effects
local ge1=nil
local ge2=nil
local ge3=nil
local ge4=nil

--local function(s)
--ge4 : Local cost
local actg=function(e,te,tp)
	return te:GetLabelObject()==e
end
local acop_create=function(ge,te,tep,...)
	local eff_t={...}
	--Check local cost
	local sel_t,res_t={},{}
	for key,eff in ipairs(eff_t) do
		local con=eff:GetCondition() or aux.TRUE
		local desc=eff:GetDescription()
		if desc==0 then desc=99 end --"Activate using a generic effect"
		if con(eff) then
			table.insert(sel_t,{true,desc})
			table.insert(res_t,eff)
		end
	end
	return function(e,tp,eg,ep,ev,re,r,rp)
		if not te then return end
		--Check local cost
		local sel=Duel.SelectEffect(tp,table.unpack(sel_t))
		local re=res_t[sel]
		local op=re and re:GetValue()
		if op and type(op)=="function" then op(re,te,tep) end
	end
end
--ge1 : Cannot cost itself
local vctg=function(e,tc)
	return e:GetLabelObject()==tc
end
--ge2 : Activate from LOCATION_ALL
local cpcon=function(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local te=c:GetActivateEffect()
	if not te then return false end
	local eff_t={te:GetHandler():IsHasEffect(EFFECT_ACT_IN_RANGE)}
	local result=(#eff_t>0)
	if not result then return false end
	--Copy effect parameters
	e:SetDescription(te:GetDescription())
	e:SetCategory(te:GetCategory())
	local prop1,prop2=te:GetProperty()
	if te:IsActiveType(TYPE_FIELD) then
		e:SetProperty(prop1,prop2|EFFECT_FLAG2_FORCE_ACTIVATE_LOCATION)
		e:SetValue(LOCATION_FZONE)
	elseif te:IsActiveType(TYPE_PENDULUM) then
		e:SetProperty(prop1,prop2|EFFECT_FLAG2_FORCE_ACTIVATE_LOCATION)
		e:SetValue(LOCATION_PZONE)
	else
		e:SetProperty(prop1,prop2)
		e:SetValue(te:GetValue())
	end
	local remain,count,code,flag,hopt_index=te:GetCountLimit()
	if count>0 then
		e:SetCountLimit(count,{code,hopt_index},flag)
		result=result and (te:CheckCountLimit(tp))
	end
	--Copy condition function
	local con=te:GetCondition()
	if con then
		local lo=e:GetLabelObject()
		e:SetLabelObject(te:GetLabelObject())
		result=result and con(e,tp,eg,ep,ev,re,r,rp)
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(lo)
	end
	--Create local cost operation
	if result then
		e:SetLabelObject(ge4)
		ge4:SetOperation(acop_create(e,te,tp,table.unpack(eff_t)))
	else
		e:SetLabelObject(nil)
		ge4:SetOperation(nil)
	end
	return result
end
local cpcost=function(e,tp,eg,ep,ev,re,r,rp,chk)
	local te=e:GetHandler():GetActivateEffect()
	local cost=te:GetCost()
	local result=true
	--Copy cost function
	if cost then
		local lo=e:GetLabelObject()
		e:SetLabelObject(te:GetLabelObject())
		ge1:SetLabelObject(e:GetHandler())
		result=cost(e,tp,eg,ep,ev,re,r,rp,chk)
		ge1:SetLabelObject(nil)
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(lo)
	end
	return result
end
local cptg=function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetHandler():GetActivateEffect()
	local tg=te:GetTarget()
	local result=true
	--Copy target
	if tg then
		local lo=e:GetLabelObject()
		e:SetLabelObject(te:GetLabelObject())
		ge1:SetLabelObject(e:GetHandler())
		result=tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		ge1:SetLabelObject(nil)
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(lo)
	end
	return result
end
local cpop=function(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetHandler():GetActivateEffect()
	local op=te:GetOperation()
	local result=nil
	--Copy operation
	if op then
		local lo=e:GetLabelObject()
		e:SetLabelObject(te:GetLabelObject())
		result=op(e,tp,eg,ep,ev,re,r,rp)
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(lo)
	end
	return result
end
--ge3 : Grant effect
local grtg=function(e,tc)
	return tc:GetEffectCount(EFFECT_ACT_IN_RANGE)>0
		and not (tc:IsLocation(LOCATION_HAND) or (tc:IsLocation(LOCATION_SZONE) and tc:IsFaceup()))
end

--public functions
function newEffect.ActInRange.EnableCheck()
	if CheckEnabled then return end
	CheckEnabled=true
	--Declarations
	ge1=Effect.GlobalEffect()
	ge2=Effect.GlobalEffect()
	ge3=Effect.GlobalEffect()
	ge4=Effect.GlobalEffect()
	--Cannot cost itself
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_CANNOT_USE_AS_COST)
	ge1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	ge1:SetTarget(vctg)
	ge1:SetLabelObject(nil)
	Duel.RegisterEffect(ge1,0)
	--Activate from LOCATION_ALL
	ge2:SetType(EFFECT_TYPE_ACTIVATE)
	ge2:SetCode(EVENT_FREE_CHAIN)
	ge2:SetRange(LOCATION_ALL)
	ge2:SetCondition(cpcon)
	ge2:SetCost(cpcost)
	ge2:SetTarget(cptg)
	ge2:SetOperation(cpop)
	--Grant effect
	ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ge3:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	ge3:SetTarget(grtg)
	ge3:SetLabelObject(ge2)
	Duel.RegisterEffect(ge3,0)
	--Local cost
	ge4:SetType(EFFECT_TYPE_FIELD)
	ge4:SetCode(EFFECT_ACTIVATE_COST)
	ge4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge4:SetTargetRange(1,1)
	ge4:SetTarget(actg)
	ge4:SetLabelObject(nil)
	Duel.RegisterEffect(ge4,0)
end
function newEffect.ActInRange.LimitCon()
	return function(e)
		return e:CheckCountLimit(e:GetHandlerPlayer())
	end
end
function newEffect.ActInRange.LimitOp()
	return function(e,te,tp)
		Duel.Hint(HINT_CARD,0,e:GetOwner():GetOriginalCode())
		--Duel.HintSelection(e:GetHandler(),true)

		e:UseCountLimit(e:GetHandlerPlayer(),1)
	end
end
