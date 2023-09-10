--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        PriorityQeue.lua             
*
* DESCRIPTION :
*       File that implements a priority queue data structure in lua. 
* 		used for pathfinding in teardown 
*		
*
* NOTES :
*       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
* 							 Release Date :    29 Nov 2021 
*
]]


PriorityQueue = {
	queuelength = 0,
	currentIndex = 0,
	queueSize = 0,
	elements = {

	},
}


function PriorityQueue:init(x,y) 
	local maxElements = (x)*(y)
	for i=1, maxElements do
		self.elements[i] = {x = 0, y = 0, priority = 0, cost = 0, visited = true,}
	end
	self.queueSize = maxElements

end

function PriorityQueue:size()
	return self.queueSize
end

function PriorityQueue:empty() 
	for key,val in ipairs(self.elements) do
		if(not val.visited) then
			return false
		end

	end
	return true

end


function PriorityQueue:put(node,cost) 
	
	for key,val in ipairs(self.elements) do
		if(val.visited) then

			--- increase search index if visited
			if(tonumber(key)>self.currentIndex ) then
				self.currentIndex = self.currentIndex+1

			end
			self.elements[key] = {
					node = node,
					cost = cost,
					visited =  false
				}
				break
		end

	end

end

function PriorityQueue:get() 
	priority = 100000000
	lowest_key = 0

	for key,val in ipairs(self.elements) do
		if( not val.visited) then
			if(val.cost) < priority then
				priority =  val.cost
				lowest_key = key
			end
		end
		if(tonumber(key)>self.currentIndex ) then
			break
		end

	end
	if(lowest_key >0) then
		self.elements[lowest_key].visited = true 
		return self.elements[lowest_key].node,priority
	else
		return false
	end

end
