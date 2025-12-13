--Declare Archetype
if Archetype then return end
Archetype = {}
--Custom Archetype table
local archtable = {}
local codetable = {} --for faster search
local checkmax = function(t,limit)
	if not t or not limit then return true end
	if type(t)~="table" then return false end
	for _,v in pairs(t) do
		--unsigned integer v
		if v > limit then return false end
	end
	return true
end
local codes_merge = function(base_table,new_table)
	if not new_table or not checkmax(new_table,0x7fffffff) then return base_table,false end
	if not base_table and new_table then return new_table,true end
	local ct = {}
	local result = false
	for _,v in pairs(base_table) do
		ct[v] = true
	end
	for _,v in pairs(new_table) do
		if not ct[v] then
			ct[v]=true
			result=true
		end
	end
	if not result then return base_table,false end
	local res_table = {}
	for v,_ in pairs(ct) do
		table.insert(res_table,v)
	end
	return res_table,result
end
local setcodes_merge = function(base_table,new_table)
	if not new_table or not checkmax(new_table,0xffff) then return base_table,false end
	if not base_table and new_table then return new_table,true end
	local st = {}
	local result = false
	for _,v in pairs(base_table) do
		st[v] = true
	end
	for _,v in pairs(new_table) do
		if not st[v] then
			local lowbit = v & 0xfff
			local highbit = v >> 12
			local yet = false
			--최상위 비트가 낮은 쪽으로 합침
			for i = 0,highbit do
				if i & highbit == i and st[(i << 12) | lowbit] then
					yet = true
					break
				end
			end
			if not yet then
				st[v] = true
				result = true
				for i = highbit+1,15 do
					if i | highbit == i and st[(i << 12) | lowbit] then
						st[(i << 12) | lowbit] = nil
					end
				end
			end
		end
	end
	if not result then return base_table,false end
	local res_table = {}
	for v,_ in pairs(st) do
		table.insert(res_table,v)
	end
	return res_table,result
end
local getSetcodesFromArchetype = function(archetype)
	--setcodes 카드군에 속하는 카드는 archetype 카드군에도 속한다.
	local chkt = {} --to avoid loop
	local rest = {}
	local newt = {archetype}
	while #newt > 0 do
		local gott = {} --next newt
		for _,v in pairs(newt) do
			if not chkt[v] then
				chkt[v] = true
				local lowbit = v & 0xfff
				local highbit = v >> 12
				for i = 0,highbit do
					local tempnum = (i << 12) | lowbit
					if i & highbit == i and archtable[tempnum] then
						local tempt = archtable[tempnum].setcodes
						if tempt and #tempt>0 then
							for k2,v2 in pairs(tempt) do
								table.insert(gott,v2)
							end
						end
					end
				end
			end
		end
		rest = setcodes_merge(rest,newt)
		newt = gott
	end
	return rest
end
local getCodesFromArchetype = function(archetype)
	--codes 카드는 archetype 카드군에 속한다. 
	local setcodes = getSetcodesFromArchetype(archetype)
	local rest = {}
	for _,v in pairs(setcodes) do
		local lowbit = v & 0xfff
		local highbit = v >> 12
		for i = highbit,15 do
			local tempnum = (i << 12) | lowbit
			if i | highbit == i and archtable[tempnum] then
				rest = codes_merge(rest,archtable[tempnum].codes)
			end
		end
	end
	return rest
end
local getArchetypesFromCode = function(code) --for faster search
	return codetable[code]
end
--Replace functions
--setcodes 카드군에 속하는 카드는 archetype 카드군에도 속한다.
--[[
[01] int, int,...  | Duel.GetCardSetcodeFromCode(int code)
----
[01] int ... | Card.GetOriginalSetCard(Card c)
[02] int ... | Card.GetPreviousSetCard(Card c)
[03] int ... | Card.GetSetCard(Card c[, Card|nil scard, int sumtype=0, int playerid=PLAYER_NONE])
[04]    bool | Card.IsOriginalSetCard(Card c, int setname)
[05]    bool | Card.IsPreviousSetCard(Card c, int setname)
[06]    bool | Card.IsSetCard(Card c, int|table setname[, Card scard|nil, int sumtype = 0, int playerid = PLAYER_NONE])
----
[01] int[, int] | Card.GetCode(Card c)
[02]        int | Card.GetOriginalCode(Card c)
[03]   int, int | Card.GetOriginalCodeRule(Card c)
[04]   int, int | Card.GetPreviousCodeOnField(Card c)
[05]       bool | Card.IsCode(Card c, int ...)
[06]       bool | Card.IsOriginalCode(Card c, int cd)
[07]       bool | Card.IsOriginalCodeRule(Card c, int cd)
[08]       bool | Card.IsPreviousCodeOnField(Card c, int ...)
[09]       bool | Card.IsSummonCode(Card c, Card sc|nil, int sumtype, int playerid, int ...)
--]]
local du={}
du.gcsfc=Duel.GetCardSetcodeFromCode
local ca={}
ca.gosc=Card.GetOriginalSetCard
ca.gpsc=Card.GetPreviousSetCard
ca.gsc=Card.GetSetCard
ca.iosc=Card.IsOriginalSetCard
ca.ipsc=Card.IsPreviousSetCard
ca.isc=Card.IsSetCard
Duel.GetCardSetcodeFromCode=function(code)
	local t1={du.gcsfc(code)}
	local t2={}
	if #t1>0 then
		for _,sc in pairs(t1) do
			t2 = setcodes_merge(t2, getSetcodesFromArchetype(sc))
		end
	end
	t2 = setcodes_merge(t2, getArchetypesFromCode(code))
	return table.unpack(t2)
end
Card.GetOriginalSetCard=function(c)
	local t1={ca.gosc(c)}
	local t2={}
	for _,cd in pairs(c:GetOriginalCodeRule()) do
		t2 = setcodes_merge(t2, getArchetypesFromCode(cd))
	end
	if #t1>0 then
		for _,sc in pairs(t1) do
			t2 = setcodes_merge(t2, getSetcodesFromArchetype(sc))
		end
	end
	if #t2==0 then return table.unpack(t1) end
	return table.unpack(t2)
end
Card.GetPreviousSetCard=function(c)
	local t1={ca.gpsc(c)}
	local t2={}
	for _,cd in pairs(c:GetPreviousCodeOnField()) do
		t2 = setcodes_merge(t2, getArchetypesFromCode(cd))
	end
	if #t1>0 then
		for _,sc in pairs(t1) do
			t2 = setcodes_merge(t2, getSetcodesFromArchetype(sc))
		end
	end
	if #t2==0 then return table.unpack(t1) end
	return table.unpack(t2)
end
Card.GetSetCard=function(c,scard,sumtype,playerid)
	local t1={ca.gsc(c,scard,sumtype,playerid)}
	local t2={}
	--(codes 카드에 대해서는, 함수 미비 문제로 여기에서는 처리할 수 없다.)
	if #t1>0 then
		for _,sc in pairs(t1) do
			t2 = setcodes_merge(t2, getSetcodesFromArchetype(sc))
		end
	end
	if #t2==0 then return 0 end
	return table.unpack(t2)
end
Card.IsOriginalSetCard=function(c,setname)
	local t2=getSetcodesFromArchetype(setname)
	for _,cd in pairs(c:GetOriginalCodeRule()) do
		t2 = setcodes_merge(t2, getArchetypesFromCode(cd))
	end
	for _,sc in pairs(t2) do
		if ca.iosc(sc) then return true end
	end
	return false
end
Card.IsPreviousSetCard=function(c,setname)
	local t2=getSetcodesFromArchetype(setname)
	for _,cd in pairs(c:GetPreviousCodeOnField()) do
		t2 = setcodes_merge(t2, getArchetypesFromCode(cd))
	end
	for _,sc in pairs(t2) do
		if ca.ipsc(sc) then return true end
	end
	return false
end
Card.IsSetCard=function(c,setname,scard,sumtype,playerid)
	local t2={}
	--(codes 카드에 대해서는, 함수 미비 문제로 여기에서는 처리할 수 없다.)
	if type(setname)=="number" then
		t2 = getSetcodesFromArchetype(setname)
	else
		for _,sc in pairs(setname) do
			t2 = setcodes_merge(t2, getSetcodesFromArchetype(sc))
		end
	end
	return ca.isc(c,t2,scard,sumtype,playerid)
end
--A function like those in c420.lua, localized
--codes 카드는 archetype 카드군에 속한다.
local sccon=function(e)
	local c,sc=e:GetHandler(),e:GetValue()
	e:SetOperation(function(sumcard,sumtype,playerid)
		--(setcodes 카드군에 속하는 카드에 대해서는, 무한 루프 문제로 여기에서는 처리할 수 없다.)
		for _,cd in pairs(getCodesFromArchetype(sc)) do
			if c:IsSummonCode(sumcard,sumtype,playerid,cd) then return true end
		end
		return false
	end)
	return true
end
--Register Archetype
Archetype.MakeCheck = function(archetype,codes,setcodes)
	if not archetype or archetype & 0xfff == 0 then return false end
	if not checkmax(codes,0x7fffffff) or not checkmax(setcodes,0xffff) then return false end
	local result=false
	if not archtable[archetype] then
		archtable[archetype] = {
			["codes"] = codes,
			["setcodes"] = setcodes
		}
		result=true
		--Treat "Codes" names as "Archetype" cards
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_SINGLE)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
		ge1:SetCode(EFFECT_ADD_SETCODE)
		ge1:SetValue(archetype)
		ge1:SetCondition(sccon)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ge2:SetValue(archetype)
		ge2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
		ge2:SetLabelObject(ge1)
		Duel.RegisterEffect(ge2,0)
	else
		if codes then
			local newt1, res1 = codes_merge(archtable[archetype].codes,codes)
			if res1 then
				result = true
				archtable[archetype].codes = newt1
			end
		end
		if setcodes then
			local newt2, res2 = setcodes_merge(archtable[archetype].setcodes,setcodes)
			if res2 then
				result = true
				archtable[archetype].setcodes = newt2
			end
		end
	end
	if archtable[archetype].codes then --for faster search
		for _,cd in pairs(archtable[archetype].codes) do
			codetable[cd] = setcodes_merge(codetable[cd], getSetcodesFromArchetype(archetype))
		end
	end
	return result
end
