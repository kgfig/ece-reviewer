--[[
	Random id selector from a set of ids
--]]

local function randomSelect( startId, lastId, setCount )
	local idTable = {}
	local idCounter = 0
	local minSize = math.min( setCount, lastId - startId + 1)
	local idSet = {}
	
	repeat
		local selectedId = math.random( startId, lastId )
		
		if idTable[selectedId] == nil then
			idCounter = idCounter + 1
			idTable[selectedId] = 1
			table.insert( idSet, selectedId )
		end
		
	until idCounter == minSize
	
	return idSet
end

return randomSelect