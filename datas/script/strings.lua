--Declaration
if not Unimplemented then
	Unimplemented = {}
end
--constants
CARD_UNIMPLEMENTED          = 0x7580910
HINTMSG_UNIMPLEMENTED       = aux.Stringid(0x7580910,0)
HINTMSG_UNIMPLEMENTED_PART  = aux.Stringid(0x7580910,1)
local for_global_check = {
	[0] = {},
	[1] = {}
}
--unimplemented card proc
Card.Unimplemented = function(c)
	if not c then
		Debug.PrintStacktrace()
		Debug.Message("Error: Unimplemented.Card should be used with Card parameter")
		Debug.Message("(카드 변수와 함께 사용되어야 합니다)")
		return
	end
	if not c:IsStatus(STATUS_INITIALIZING) then
		Debug.PrintStacktrace()
		Debug.Message("Error: Unimplemented.Card should be used on initializing")
		Debug.Message("(카드 초기화 단계에서 사용되어야 합니다)")
		return
	end
	c:RegisterFlagEffect(CARD_UNIMPLEMENTED,0,0,0,0x1)
	aux.GlobalCheck(for_global_check[0],function()
		local e1=Effect.GlobalEffect()
		e1:SetDescription(HINTMSG_UNIMPLEMENTED_PART)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ge1:SetLabelObject(e1)
		ge1:SetTarget(function(e,c)
			local t={c:GetFlagEffectLabel(CARD_UNIMPLEMENTED)}
			for k,v in pairs(t) do
				if v==0x1 then return true end
			end
			return false
		end)
		ge1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
		Duel.RegisterEffect(ge1,0)
	end)
end
--partially unimplemented card proc
Card.UnimplementedPartially = function(c)
	if not c then
		Debug.PrintStacktrace()
		Debug.Message("Error: Unimplemented.Card should be used with Card parameter")
		Debug.Message("(카드 변수와 함께 사용되어야 합니다)")
		return
	end
	if not c:IsStatus(STATUS_INITIALIZING) then
		Debug.PrintStacktrace()
		Debug.Message("Error: Unimplemented.Card should be used on initializing")
		Debug.Message("(카드 초기화 단계에서 사용되어야 합니다)")
		return
	end
	c:RegisterFlagEffect(CARD_UNIMPLEMENTED,0,0,0,0x2)
	aux.GlobalCheck(for_global_check[1],function()
		local e1=Effect.GlobalEffect()
		e1:SetDescription(HINTMSG_UNIMPLEMENTED_PART)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ge1:SetLabelObject(e1)
		ge1:SetTarget(function(e,c)
			local t={c:GetFlagEffectLabel(CARD_UNIMPLEMENTED)}
			for k,v in pairs(t) do
				if v==0x2 then return true end
			end
			return false
		end)
		ge1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
		Duel.RegisterEffect(ge1,0)
	end)
end
