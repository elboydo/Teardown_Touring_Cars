--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        node.lua             
*
* DESCRIPTION :
*       File that implements a node type structure for use in GNG/SNN networks 
*		

*
* NOTES :
* 
* This was a rough implementation, I wouldn't put too much stock in it.  
* makes for a cool experiment though.      
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
* 							 Release Date :    29 Nov 2021 
*
]]

node = {
	minID = -1,
	secondMinID = -1,
	MinDistance = 1000,
	secondMinDistance = 999,
	x = 0,
	y = 0,
	z = 0,
	value = 0,
	spriteColour = {1,1,0},
	GNconnect = Vec(0,0,0),
	GNnumber = 0,
	SNNpulse = 0,
	SNNstate = 0,
	SNNSum = 0,
	SNNNum = 0,
	threshold = 0.6,
	outputthreshold=0.2,
	SNNpsp    = 0 

}

function node:push(x,y,z,value)
	self.x, self.y, self.z, self.value = x,y,z,value
end

function node:growCluster(data)
	self.GNconnect = VecAdd(self.GNconnect,data)
	self.GNnumber = self.GNnumber +1
end

function node:updateCluster()
	
	if(self.GNnumber > 0 and VecLength(VecSub(self:getPos(),self.GNconnect))>0) then

		self.GNconnect = VecScale(self.GNconnect,(1/self.GNnumber))
	else
		self.GNconnect = VecCopy(self:getPos())
	end
	self:setPos(VecCopy(self.GNconnect))

	-- self.GNconnect = self:getPos()

	self.GNnumber = 0
	self.GNconnect = Vec(0,0,0)
end

function node:growPulse(inputData)
	self.SNNpulse = self.SNNpulse + inputData
	self.SNNSum = self.SNNSum + math.abs(inputData)
	self.SNNNum = self.SNNNum +1
end

function node:firePulse()
	if(self.SNNSum>0) then
		self.SNNstate = self.SNNpulse*(1/self.SNNSum) 
	else
		self.SNNstate = 0
	end
	-- if not self.SNNstate then 
	-- 	self.SNNstate = 0
	-- end
	-- local r = 1
	-- local g = 1
	-- local green = Vec(0,1,0)
	-- local red   = Vec(1,0,0)
	-- local output = VecLerp(green,red,self.SNNstate)
	DebugWatch("output",self.SNNstate)
	self.spriteColour =  {self:clamp(1-self.SNNstate,0,1), self:clamp(1*self.SNNstate,0,1),0}---{output[1],output[2],output[3]}
	-- if(self.SNNstate > self.threshold) then
	-- 	self.spriteColour  = {0,1,0}
	-- elseif(self.SNNstate > self.outputthreshold) then
	-- 	self.spriteColour  = {1,1,0}
	-- else
	-- 	self.spriteColour  = {1,0,0}
	-- end
	if(VecLength(self:getPos())==0) then
		self.spriteColour  = {1,0,0}
	end

	self.SNNpulse = 0
	self.SNNSum = 0
	self.SNNNum = 0
end


function node:computeNodeDistance(CentroidId,centroid)
	local dist = self:getDistance(centroid:getPos())
	if(dist<self.MinDistance) then
		self:setMinID(CentroidId)
		self:setMinDistance(dist)
	elseif(dist<self.secondMinDistance) then
		self:setSecondMinID(CentroidId)
		self:setSecondMinDistance(dist)
	end
end

function node:resetMins()
	self:setMinDistance(10000)
	self:setSecondMinDistance(10000)

	self:setMinID(-1)
	self:setSecondMinID(-1)
end

function node:getPos()
	return Vec(self.x,self.y,self.z)
end

function node:getDistance(altPos)
	return VecLength(VecSub(self:getPos(),altPos))
end

function node:loadSprite()
	self.sprite = LoadSprite("MOD/images/dot.png")
end
function node:showSprite()
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


function node:getMinDistance()
	return self.MinDistance 
end

function node:getSecondMinDistance()
	return self.secondMinDistance
end


function node:getMinID()
	return self.minID 
end
function node:getSecondMinID()
	return self.secondMinID 
end


--- 

 --- setters

---

function node:setPos(pos)
	self.x,self.y,self.z = pos[1],pos[2],pos[3]
end


function node:setMinDistance(dist)
	self:setSecondMinDistance(self.MinDistance)
	self.MinDistance = dist
end

function node:setSecondMinDistance(dist)
	self.secondMinDistance = dist
end

function node:setMinID(id)
	self:setSecondMinID(self.minID)
	self.minID = id
end
function node:setSecondMinID(id)
	self.secondMinID = id
end




---

  --- helpers

----


function node:clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end