--Declare Archetype
if Archetype then return end
Archetype = {}
--Custom Archetype table
local archtable = {}
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
			local lowbit = v % 0x1000
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
	local chkt = {} --to avoid loop
	local rest = {}
	local newt = {archetype}
	while #newt > 0 do
		local gott = {} --next newt
		for _,v in pairs(newt) do
			if not chkt[v] then
				chkt[v] = true
				local lowbit = v % 0x1000
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
	local setcodes = getSetcodesFromArchetype(archetype)
	local rest = {}
	for _,v in pairs(setcodes) do
		local lowbit = v % 0x1000
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
--A function like those in c420.lua, localized
local IsArchetype=function(c,archetype,sumcard,sumtype,playerid)
	sumtype=sumtype or 0
	playerid=playerid or PLAYER_NONE
	for _,sc in pairs(getSetcodesFromArchetype(archetype)) do
		if sc & archetype ~= archetype or sc % 0x1000 ~= archetype % 0x1000 then --avoid loop self
			if c:IsSetCard(sc,sumcard,sumtype,playerid) then return true end
		end
	end
	for _,cd in pairs(getCodesFromArchetype(archetype)) do
		if c:IsSummonCode(sumcard,sumtype,playerid,cd) then return true end
	end
	return false
end
--Register Archetype
local sccon=function(sumcard,sumtype,playerid)
	return IsArchetype(tc,e:GetValue(),sumcard,sumtype,playerid)
end
Archetype.MakeCheck = function(archetype,codes,setcodes)
	if not archetype or archetype % 0x1000 == 0 then return false end
	if not checkmax(codes,0x7fffffff) or not checkmax(setcodes,0xffff) then return false end
	local result=false
	if not archtable[archetype] then
		archtable[archetype] = {
			["codes"] = codes,
			["setcodes"] = setcodes
		}
		result=true
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetProperty(EFFECT_FLAG_IGNORE_RANGE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
		ge:SetCode(EFFECT_ADD_SETCODE)
		ge:SetValue(archetype)
		ge:SetOperation(sccon)
		Duel.RegisterEffect(ge,0)
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
	return result
end
