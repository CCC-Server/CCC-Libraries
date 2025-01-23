--Add Deck/ExtraDeck recursively and reversewise
function Debug.AddDeck(tp,...)
	local t={...}
	local endnum=1
	local loc=LOCATION_DECK
	if type(t[1])=="boolean" then
		endnum=2
		if t[1] then loc=LOCATION_EXTRA end
	end
	if type(t[endnum])=="table" then
		t={table.unpack(t[endnum])}
		endnum=1
	end
	for i=#t,endnum,-1 do
		Debug.AddCard(t[i],tp,tp,loc,0,POS_FACEDOWN)
	end
end
--Load Deck from "(Deckname).ydk" file
function Debug.LoadDeck(tp,filename,isdeck_fromreplay)
	if string.sub(filename,-4)~=".ydk" then return end
	local deckfile=io.open("puzzles/"..filename,"r")
	if not deckfile then deckfile=io.open("deck/"..filename,"r")
    if not deckfile then return end
	local deck_table={["nil"]={}}
	local phase="nil"
	for line in deckfile:lines() do
		local firstletter=string.byte(string.sub(line,1,1))
		if firstletter>48 and firstletter<58 then
			table.insert(deck_table[phase],math.tointeger(line))
		else
			phase=string.sub(line,2)
			deck_table[phase]={}
		end
	end
	deckfile:close()
	if isdeck_fromreplay then
		for key,tbl in pairs(deck_table) do
			local t={}
			for i,_ in ipairs(tbl) do
				t[i]=tbl[#tbl+1-i]
			end
			for i,_ in ipairs(tbl) do
				tbl[i]=t[i]
			end
		end
	end
	if deck_table["main"] then Debug.AddDeck(tp,false,deck_table["main"]) end
	if deck_table["extra"] then Debug.AddDeck(tp,true,deck_table["extra"]) end
end
--Force AI Selection from Deck to Deck Top (incomplete)
function Auxiliary.ForceTop(...)
	local params={...}
	local checkf=function(tp)
		for k,v in ipairs(params) do
			if tp==v then return true end
		end
		return false
	end
	local card_iscontained=function(g)
		return function(c)
			return g:IsContains(c)
		end
	end
	local group_select=Group.Select
	Group.Select=function(g,tp,min,max,...)
		if not checkf(tp) then return group_select(g,tp,min,max,...) end
		local dg,tg=g:Split(Card.IsLocation,nil,LOCATION_DECK)
		if not tg then tg=Group.CreateGroup() end
		for i=1,max do
			if dg and #dg>0 then
				local dtg=dg:GetMaxGroup(Card.GetSequence)
				tg:Merge(dtg)
				dg:Sub(dtg)
			end
		end
		return group_select(tg,tp,min,max,...)
	end
	local duel_selectmatchingcard=Duel.SelectMatchingCard
	Duel.SelectMatchingCard=function(tp,f,p,s,o,min,max,cancel,...)
		if not checkf(tp) then return duel_selectmatchingcard(tp,f,p,s,o,min,max,cancel,...) end
		local params
		if type(cancel)=="boolean" then params={...} else params={cancel,...} end
		local dg,tg=Duel.GetMatchingGroup(f,p,s,o,table.unpack(params)):Split(Card.IsLocation,nil,LOCATION_DECK)
		if not tg then tg=Group.CreateGroup() end
		for i=1,max do
			if dg and #dg>0 then
				local dtg=dg:GetMaxGroup(Card.GetSequence)
				tg:Merge(dtg)
				dg:Sub(dtg)
			end
		end
		local tf=card_iscontained(tg)
		return duel_selectmatchingcard(tp,tf,p,s,o,min,max,...)
	end
end
