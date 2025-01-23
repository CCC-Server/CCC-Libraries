--Declare Bitwise
if Bitwise then return end
Bitwise = {}
--Bitwise Functions
--Split each bit and return them as a table
function Bitwise.GetBitSplit(v,return_as_iterator)
	local res = {}
	local i = 1
	while i <= v do
		if i & v ~= 0 then
			table.insert(res, i)
		end
		i = i << 1
	end
	if return_as_iterator then
		return pairs(res)
	end
	return res
end
--Split each bit and return their positions (starting from 0)
function Bitwise.GetBitSplitPos(v,return_as_iterator,start_pos,end_pos)
	if not start_pos then
		start_pos = 0
	end
	if not end_pos then
		end_pos = math.ceil(math.log(math.abs(v)) / math.log(2))
	end
	local res = {}
	local ct = start_pos
	while ct <= end_pos do
		if (1 << ct) & v ~= 0 then
			table.insert(res, ct)
		end
		ct = ct + 1
	end
	if return_as_iterator then
		return pairs(res)
	end
	return res
end
--Count bits with value 1 (ignores bits with value 0)
function Bitwise.GetBitSplitCount(v)
	--return #(Bitwise.GetBitSplit(v, false))
	local num=v
	local ct=0
	while num~=0 do
		if (num&0x1)~=0 then ct=ct+1 end
		num=(num>>1)
	end
	return ct
end
