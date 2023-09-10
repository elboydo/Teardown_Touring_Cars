--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        mapNode.lua             
*
* DESCRIPTION :
*       File that implements a structure to represent map nodes and scores
*		used for pathfinding 
*		

*
* NOTES :
*       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
* 							 Release Date :    29 Nov 2021 
*
]]

mapNode = {
	minID = -1,
	secondMinID = -1,
	MinDistance = 1000,
	secondMinDistance = 999,
	x = 0,
	y = 0,
	z = 0,
	baseCost = 0,
	validTerrain = false,
	spriteColour = {1,1,0},
	neighbors = {},
	maxVal = {},
	indexX = 0,
	indexY = 0,

}




function mapNode:push(x,y,z,value,t_indexY,t_indexX,validTerrain,maxVal)
	self.x, self.y, self.z, self.baseCost,self.indexX , self.indexY, self.validTerrain,self.maxVal = x,y,z,value,t_indexX,t_indexY,validTerrain,maxVal
	-- local index = 0
	for yVal=-1,1,1 do
		for xVal=-1,1,1 do
			-- index = 
			if(t_indexX + xVal >0 and  t_indexX + xVal < self.maxVal[1] and
				t_indexY + yVal >0 and  t_indexY + yVal < self.maxVal[2] and 
				not (xVal == 0 and yVal==0)) then 
				self.neighbors[#self.neighbors +1] = {
					x = t_indexX + xVal ,
					y = t_indexY + yVal ,

				} 
			end
		end
	end
end

function mapNode:getPos()
	return Vec(self.x,self.y,self.z)
end

function mapNode:getIndex()
	return  {self.indexX, self.indexY}
end


function mapNode:Equals(node)
	local nodeIndex = node:getIndex()
	if(self.indexX==nodeIndex[1] and self.indexY==nodeIndex[2])  then 

		return true
	else
		return false
	end
end


function mapNode:indexEquals(nodeIndex)
	if(self.indexX==nodeIndex[1] and self.indexY==nodeIndex[2])  then 

		return true
	else
		return false
	end
end

function mapNode:getDistance(altPos)
	return VecLength(VecSub(self:getPos(),altPos))
end


function mapNode:computeNodeDistance(CentroidId,centroid)
	local dist = self:getDistance(centroid:getPos())
	if(dist<self.MinDistance) then
		self:setMinID(CentroidId)
		self:setMinDistance(dist)
	elseif(dist<self.secondMinDistance) then
		self:setSecondMinID(CentroidId)
		self:setSecondMinDistance(dist)
	end
end

function mapNode:resetMins()
	self:setMinDistance(10000)
	self:setSecondMinDistance(10000)

	self:setMinID(-1)
	self:setSecondMinID(-1)
end


function mapNode:loadSprite()
	self.sprite = LoadSprite("MOD/images/dot.png")
end
function mapNode:showSprite()
	if(not IsHandleValid(self.sprite)) then
		DebugPrint("NO SPRITE FOUND")
	end
	spriteColour = {1,1,1}

	local t = Transform(self:getPos(), QuatEuler(0, GetTime(), 0))
	DrawSprite(self.sprite, t, 1, 1, self.spriteColour[1], self.spriteColour[2], self.spriteColour[3], 1)
	DebugWatch("spritePos",t)
	DebugWatch("clusterPos",self:getPos())
end



-----

 ---- getters

-----


function mapNode:getMinDistance()
	return self.MinDistance 
end

function mapNode:getSecondMinDistance()
	return self.secondMinDistance
end


function mapNode:getMinID()
	return self.minID 
end
function mapNode:getSecondMinID()
	return self.secondMinID 
end


function mapNode:getCost()
	return self.baseCost 
end

function mapNode:getNeighbors()
	return self.neighbors
end

--- 

 --- setters

---

function mapNode:setPos(pos)
	self.x,self.y,self.z = pos[1],pos[2],pos[3]
end


function mapNode:setMinDistance(dist)
	self:setSecondMinDistance(self.MinDistance)
	self.MinDistance = dist
end

function mapNode:setSecondMinDistance(dist)
	self.secondMinDistance = dist
end

function mapNode:setMinID(id)
	self:setSecondMinID(self.minID)
	self.minID = id
end
function mapNode:setSecondMinID(id)
	self.secondMinID = id
end




---

  --- helpers

----


function mapNode:clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end