Duel.LoadScript("proc_skill_links.lua")

-- constants
SKILL_COVER_ARCHIVE_START    = 301000003
SKILL_COVER_ARCHIVE_ACTIVATE = 302000003

-- specified skills
SKILL_LUCKY_DAY = 300102004

-- proc for memorize starting LP
Duel.GetStartingLP=nil
local startinglp_check=false
Auxiliary.addStartingLPCheck=function()
	if startinglp_check then return end
	startinglp_check=true
	local t={}
	t[0]=Duel.GetLP(0)
	t[1]=Duel.GetLP(1)
	Duel.GetStartingLP=function(tp)
		return t[tp]
	end
end

-- proc for choose dice/coin
local luckyday_check=false
local addLuckyDayCheck_Phase={}
Auxiliary.addLuckyDayCheck=function()
	if luckyday_check then return end
	luckyday_check=true
	Duel.LoadScript("c"..SKILL_LUCKY_DAY..".lua")
	--revert "It's My Lucky Day!" overrides to avoid conflicts
	addLuckyDayCheck_Phase[1]()
	--add new overrides to make multiple choice available
	addLuckyDayCheck_Phase[2]()
	--rework "It's My Lucky Day!"
	addLuckyDayCheck_Phase[3]()
end
addLuckyDayCheck_Phase[1]=function()
	if not _G["c"..SKILL_LUCKY_DAY] then return end
	--revert Duel.TossDice and Duel.TossCoin, negating local function check_and_register_flag
	local getflag=Duel.GetFlagEffect
	local fakeflag=function(tp,id,...)
		if id==SKILL_LUCKY_DAY then return 0 end
		return getflag(tp,id,...)
	end
	local luckydice=Duel.TossDice
	Duel.TossDice=(function()
		return function(tp,count,...)
			Duel.GetFlagEffect=fakeflag
			local result={luckydice(tp,count,...)}
			Duel.GetFlagEffect=getflag
			return table.unpack(result)
		end
	end)()
	local luckycoin=Duel.TossCoin
	Duel.TossCoin=(function()
		return function(tp,count,...)
			Duel.GetFlagEffect=fakeflag
			local result={luckycoin(tp,count,...)}
			Duel.GetFlagEffect=getflag
			return table.unpack(result)
		end
	end)()
end
addLuckyDayCheck_Phase[2]=function()
	--To do...

end
addLuckyDayCheck_Phase[3]=function()
	--To do...

end
