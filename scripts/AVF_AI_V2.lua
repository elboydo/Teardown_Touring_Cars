#include "node.lua"


RACESTARTED  = false

aiVehicles = {



	}

ai = {
	active = true,
	goalPos= Vec(0,0,0),

	controller = {

		accelerationValue = 0,
		steeringValue = 0,
		handbrake = false,
	},


	detectRange = 3,
	commands = {
	[1] = Vec(0,0,-1),
	[2] = Vec(1*0.8,0,-1*1.5),
	[3] = Vec(-1*0.8,0,-1*1.5),
	[4] = Vec(-1,0,0),
	[5] = Vec(1,0,0),
	[6] = Vec(0,0,1),

	},

	weights = {

	[1] = 0.870,
	[2] = 0.86,
	[3] = 0.86,
	[4] = 0.84,
	[5] = 0.84,
	[6] = 0.80,

			} ,

	targetMoves = {
		list        = {},
		target      = Vec(0,0,0),
		targetIndex = 1
	},


	directions = {
		forward = Vec(0,0,1),

		back = Vec(0,0,-1),

		left = Vec(1,0,0),

		right = Vec(-1,0,0),
	},

	maxVelocity = 0,

	cornerCoef = 6,

	accelerationCoef = 5.75,
	steeringCoef = 1.55,

	pidState = {

			--- pid gain params
		pGain = 2.165,
		iGain = 0.3,
		dGain = -2.3,

		intergralTime = 5,

		integralIndex = 1,
		integralSum = 0,
		integralData = {

		},
		lastCrossTrackError = 0,
		lastPnt = Vec(0,0,0),

			-- pid output value 
		controllerValue = 0,


			--- pid update and training params
			training = false,
		inputrate=0.0665,
		learningrateweights=0.009,
		learningrateThres = 0.02,
	    bestrate=0.05,
	    secondbestrate=0.01,
	    gammasyn=0.9,
	    gammaref=0.7,
	    gammapsp=0.9,
	},

	clustering = {
		pass = 1,
		maxPass = 10,
		centroids = 2,
		iterations = 5,
		prior = 1,
		dataSize = 100,
		mode = -1,
		previousOutput = -1,
		output = nil,
		clusters = {
			centroids = {
				pass = 1,
				index = 1,
				data = {},
			},
			current = {
				pass = 1,
				index = 1,
				data = {},


			},
			prior = {
				pass = 1,
				index = 1,
				data = {},


			},
		},

	},

	scanning = {
		numScans = 2,
		scanThreshold = 0.5,
		maxScanLength = 5,
		scanLength = 50,
		scanDepths = 2,
		vehicleHeight = 2,
		cones = {
			left   = {
				startVec = Vec(1,0,-0.1),
				size = 110,
				scanColour = {
					r = 1,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
			centre = {
				startVec = Vec(0,0,-1),
				size = 0.5,
				scanColour = {
					r = 0,
					g = 0, 
					b = 1,
				},
				weight = 0.6

			},
			right  = {
				size = 110,
				startVec = Vec(-1,0,-0.1),
				scanColour = {
					r = 0,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
		},
	},



	--altChecks = Vec(0.25,0.4,-0.6),
	altChecks = {
				[1] = -2,
				[2] =0.2,
				[3] = 0.4
			},
	altWeight ={
			[1] = 1,
			[2] =1,
			[3] = -1,
			[4] = -1,
	},


	validSurfaceColours ={ 
			[1] = {
				r = 0.20,
				g = 0.20,
				b = 0.20,
				range = 0.02
			},
		},
	hitColour = Vec(1,0,0),
	detectColour = Vec(1,1,0),
	clearColour = Vec(0,1,0),
}



function init()



	-- for i = 1,#ai.commands*1 do 
	-- 	detectPoints[i] = deepcopy(ai.commands[(i%#ai.commands)+1])
	-- 	if(i> #ai.commands) then
	-- 		detectPoints[i] = VecScale(detectPoints[i],0.5)
	-- 		detectPoints[i][2] = ai.altChecks[2]


	-- 	else 
	-- 		detectPoints[i][2] = ai.altChecks[1]
	-- 	end
	-- 	weights[i] = ai.weights[(i%#ai.commands)+1]--*ai.altWeight[math.floor(i/#ai.commands)+1]

	-- end

	checkpoints = FindTriggers("checkpoint",true)

	vehicles = FindVehicles("cfg",true)

	for key,vehicle in pairs(vehicles) do 
		local value = GetTagValue(vehicle, "cfg")
		if(value == "ai") then
			local index = #aiVehicles+1
			aiVehicles[index] = deepcopy(ai)
			aiVehicles[index]:initVehicle(vehicle) 


		end
	end




end

function tick(dt)

	hit, point, normal, shape = QueryClosestPoint(GetCameraTransform().pos, 10)
	if hit then
	--local hitPoint = VecAdd(pos, VecScale(dir, dist))
		local mat,r,g,b = GetShapeMaterialAtPosition(shape, point)
		-- DebugWatch("Raycast hit voxel made out of ", mat.." | r:"..r.."g:"..g.."b:"..b)
	end
	for key,vehicle in pairs(aiVehicles) do 
		vehicle:tick(dt)
	end	


	

end

function update(dt )
	for key,vehicle in pairs(aiVehicles) do 
		vehicle:update(dt)
	end	


	
end


function ai:initVehicle(vehicle) 

	self.id = vehicle
	self.body = GetVehicleBody(self.id)
	self.transform =  GetBodyTransform(self.body)
	self.shapes = GetBodyShapes(self.body)

	
	for i=1,3 do 
		self.targetMoves.list[i] = Vec(0,0,0)
	end

	self.raceCheckpoint = 1
	self.currentCheckpoint = nil

	for key,value in ipairs(checkpoints) do
		if(tonumber(GetTagValue(value, "checkpoint"))==self.raceCheckpoint) then 
			self.currentCheckpoint = value
		end
	end	

	for i = 1, self.pidState.intergralTime do
		self.pidState.integralData[i] = 0

	end

	self:initClusters()



end


function ai:initClusters()
	for cluster= 1,self.clustering.centroids do 
		self.clustering.clusters.centroids.data[cluster] = deepcopy(node)

		 self.clustering.clusters.centroids.data[cluster]:loadSprite()
	end
	for i = 1,self.clustering.dataSize do 
		--clustering.clusters.current.data
		self.clustering.clusters.current.data[i] = deepcopy(node)
		self.clustering.clusters.prior.data[i] = deepcopy(node)
		self.clustering.clusters.current.data[i]:loadSprite()
	end

	self:scanPos()
	self:clusteringCentroids()

end

function ai:tick(dt)
		-- DebugWatch("datasize = ",#self.clustering.clusters.centroids.data)

		self:markLoc()
		self:controlActions()
		DebugWatch("velocity:", VecLength(GetBodyVelocity(GetVehicleBody(self.id))))

	
end

function ai:update(dt)
	if(RACESTARTED) then

		self:vehicleController()
	end
	
end


function ai:markLoc()
	
	if InputPressed("g") and not RACESTARTED  then

		RACESTARTED = true
		DebugPrint("race Started")
		self.currentCheckpoint = self.currentCheckpoint+1
		self.goalOrigPos = GetTriggerTransform(self.currentCheckpoint).pos

		self.goalPos = TransformToParentPoint(GetTriggerTransform(self.currentCheckpoint),Vec(math.random(-7,7),0,math.random(5,10)))

		-- local camera = GetCameraTransform()
		-- local aimpos = TransformToParentPoint(camera, Vec(0, 0, -300))
		-- local hit, dist,normal = QueryRaycast(camera.pos,  VecNormalize(VecSub(aimpos, camera.pos)), 200,0)
		-- if hit then
			
		-- 	self.goalPos = TransformToParentPoint(camera, Vec(0, 0, -dist))

		-- end 	

		-- DebugPrint("hitspot"..VecStr(goalPos).." | "..dist.." | "..VecLength(
		-- 							VecSub(GetVehicleTransform(vehicle.id).pos,goalPos)))
	end

	if(RACESTARTED) then 
		if(IsVehicleInTrigger(self.currentCheckpoint,self.id)) then
			self.raceCheckpoint = (self.raceCheckpoint%#checkpoints)+1
			for key,value in ipairs(checkpoints) do 
				
				if(tonumber(GetTagValue(value, "checkpoint"))==self.raceCheckpoint) then 
					self.currentCheckpoint = value
					self.goalOrigPos = GetTriggerTransform(self.currentCheckpoint).pos

					self.goalPos =TransformToParentPoint(GetTriggerTransform(self.currentCheckpoint),Vec(math.random(-7,7),0,math.random(5,10)))
				end
			end

			end

		-- DebugWatch("checkpoint: ",raceCheckpoint)
		-- DebugWatch("goalpos",VecLength(goalPos))
		SpawnParticle("fire", self.goalPos, Vec(0,5,0), 0.5, 1)
	end


end


function ai:controlActions()
	self:scanPos()
	local steeringValue = -self:pid()
	local accelerationValue = self:accelerationError()
	

	self.controller.steeringValue = steeringValue * self.steeringCoef
	self.controller.accelerationValue = accelerationValue*self.accelerationCoef

	self:controllerAugmentation()
end


function ai:controllerAugmentation()
	local velocity =  VecLength(GetBodyVelocity(GetVehicleBody(self.id)))
	if(velocity>self.cornerCoef) then
		self.controller.accelerationValue = (self.controller.accelerationValue*0.5-0.5) - self.controller.steeringValue
	end
	
	
end


function ai:scanPos()

	self.scanning.scanLength = self.scanning.maxScanLength+(VecLength(GetBodyVelocity(GetVehicleBody(self.id))))

	local vehicleTransform = GetVehicleTransform(self.id)
	local min, max = GetBodyBounds(self.body)
	local boundsSize = VecSub(max, min)
	local center = VecLerp(min, max, 0.5)


	-- DebugWatch("boundsize",boundsSize)
	-- DebugWatch("center",center)

	vehicleTransform.pos = TransformToParentPoint(vehicleTransform,Vec(0,1.2	,0))

	for key,scan in pairs(self.scanning.cones) do 

		for i=1,ai.scanning.scanDepths do 
			local scanLength = self.scanning.scanLength * i



			local projectionAngle =  (math.sin(math.rad(scan.size)) * ((scanLength)))
			if(scan.startVec[1]>0) then
				projectionAngle = -projectionAngle	
			end
			local scanStartPos = TransformToParentPoint(vehicleTransform,scan.startVec)
			if(scan.startVec[1]==0) then
				scanStartPos = TransformToParentPoint(vehicleTransform, Vec(-projectionAngle/2,0,-1))
			end 
			
			local scanStartRot = QuatLookAt(vehicleTransform.pos,scanStartPos)
			local scanEndPos = TransformToParentPoint(Transform(vehicleTransform.pos,scanStartRot), Vec(projectionAngle,0,-1))
			if(scan.startVec[1]==0) then
				scanEndPos = TransformToParentPoint(vehicleTransform, Vec(projectionAngle/2,0,-1))
			end 
			local scanEndRot = QuatLookAt(vehicleTransform.pos,scanEndPos)
			for i=1,self.scanning.numScans do 
				QueryRejectVehicle(self.id)
				local testScanRot = QuatSlerp(scanStartRot,scanEndRot,i/self.scanning.numScans)
				local fwdPos = TransformToParentPoint(Transform(vehicleTransform.pos,testScanRot),  
						Vec(0,-self.scanning.vehicleHeight*2,-scanLength))
				local direction = VecSub(fwdPos,vehicleTransform.pos)
				direction = VecNormalize(direction)
			    QueryRejectVehicle(self.id)
			    QueryRequire("physical static large")

			    local hit,dist,normal, shape = QueryRaycast(vehicleTransform.pos, direction, scanLength)

			     -- DebugWatch("hitpos",(VecAdd(vehicleTransform.pos, VecScale(direction, dist))))

			    self:pushData(hit,dist,normal,shape,VecAdd(vehicleTransform.pos, VecScale(direction, dist)))

				 -- DebugLine(vehicleTransform.pos, VecAdd(vehicleTransform.pos, VecScale(direction, dist)), scan.scanColour.r, scan.scanColour.g, scan.scanColour.b)

				 -- DebugWatch("transform pos",(vehicleTransform.pos))

				 -- DebugWatch("forward pos",(fwdPos))
			end
		end	

	end


	self:clusteringOperations()


	self.clustering.clusters.current.pass = (self.clustering.clusters.current.pass%self.clustering.dataSize )+1 
	self.clustering.clusters.current.index = 1

end


--init clusters 
function ai:clusteringCentroids()
	local valRange = { min = { 100000, 100000, 100000},
						max = {-100000 , -100000 , -100000 } 
					}
	local pos = Vec(0,0,0)
	for index = 1,self.clustering.clusters.current.index do 

		pos = self.clustering.clusters.current.data[index]:getPos()
		for i = 1,3 do
			if(pos[i] ~= 0 and pos[i] < valRange.min[i]) then

				valRange.min[i] = pos[i]
			end
			if(pos[i] ~= 0 and pos[i] > valRange.max[i]) then
				valRange.max[i] = pos[i]
			end
		end
	end

	for i = 1,self.clustering.centroids do
		if(self.clustering.clusters.centroids.data[i].GNnumber==0 ) then 
			self.clustering.clusters.centroids.data[i]:push(
													math.random(valRange.min[1],valRange.max[1]),
													math.random(valRange.min[2],valRange.max[2]),
													math.random(valRange.min[3],valRange.max[3]),
													0)
		end

	end

	--DebugPrint("min:"..valRange.min[1]..","..valRange.min[2]..","..valRange.min[2].."\nMax: "..valRange.max[1]..","..valRange.max[2]..","..valRange.max[3])
end

--init clusters 
function ai:clusteringUpdateCentroids()
	local pos = Vec(0,0,0)
	local inputData = nil
	for index = 1,self.clustering.clusters.current.index do 

		inputData = self.clustering.clusters.current.data[index] 
		if inputData.value >=0 then
		pos = inputData:getPos()
		self.clustering.clusters.centroids.data[inputData:getMinID()]:growCluster(pos)
		end
	end
	self:clusteringCentroids()
	for i = 1,self.clustering.centroids do
		self.clustering.clusters.centroids.data[i]:updateCluster()
	end
end


-- find euclidian distance of data to clusters and update centroid locations
function ai:clusteringCalculateClusters()
	local pos = Vec(0,0,0)
	local center = Vec(0,0,0)
	local dist = 0

	for i = 1,self.clustering.iterations do 
		for index = 1,self.clustering.clusters.current.index do 
			self.clustering.clusters.current.data[index]:resetMins()
			
			pos = self.clustering.clusters.current.data[index]:getPos()

			for i = 1,self.clustering.centroids do
				 self.clustering.clusters.current.data[index]:computeNodeDistance(i,self.clustering.clusters.centroids.data[i])
			end
		end
		self:clusteringUpdateCentroids()
	end

end

--- perform operations on clusters to extract target
function ai:clusteringOperations()
	
	self:clusteringCalculateClusters()


	self:pseudoSNN()

	for i = 1,self.clustering.centroids do
		 self.clustering.clusters.centroids.data[i]:showSprite()
		 -- DebugWatch("cluster - "..i,VecSub(self.clustering.clusters.centroids.data[i]:getPos(),
		 -- 	 GetVehicleTransform(self.id).pos))
		 --DebugWatch("cluster - "..i,self.clustering.clusters.centroids.data[i]:getPos())
	-- VecLength(self.clustering.clusters.centroids.data[i]:getPos(),Vec(0,0,0)))
	end

end


--- simulate an snn network slightly to get best node

-- if(SNNpspprev[j]<SNNpsp[i])
--  {
--      SNNweights[j][i]=tanh(gammaweights*SNNweights[j][i]+learningrateweights*SNNpspprev[j]*SNNpsp[i]);
--  }

function ai:pseudoSNN()
	local bestpsp = 100000000
	local mode = -1
	local inputData = nil
	local pos = Vec(0,0,0)
	local value = 0
	for index = 1,self.clustering.clusters.current.index do 
		inputData = self.clustering.clusters.current.data[index] 
		self.clustering.clusters.centroids.data[inputData:getMinID()]:growPulse(inputData.value)
	end
	local psp = 100000000
	local dist = 0
	for i = 1,self.clustering.centroids do
		if(VecLength(self.clustering.clusters.centroids.data[i]:getPos())>0) then
			self.clustering.clusters.centroids.data[i]:firePulse()
			psp =self.clustering.clusters.centroids.data[i].SNNstate 
			if(psp>self.clustering.clusters.centroids.data[i].outputthreshold) then 
				dist = self.clustering.clusters.centroids.data[i]:getDistance(self.goalpos)
				psp = dist * (1-psp)
				if(psp<bestpsp) then 
					bestpsp = psp
					mode = i
				end 
			end
		end
	--		if(self.clustering.clusters.centroids.data[i].SNNstate > self.clustering.clusters.centroids.data[i].threshold) then
	end
	if(mode == -1) then
		mode = self.clustering.previousOutput 
	else
		self.clustering.previousOutput = mode

	end
	self.clustering.mode = mode
	-- DebugPrint(mode)
	if(self.clustering.mode ~=-1) then
		self.clustering.clusters.centroids.data[self.clustering.mode].spriteColour={0,0,1}
	end
end

function ai:pushData(hit,dist,normal,shape,hitPos)
	local index = self.clustering.clusters.current.index 
	local hitValue = 0
	if(hit) then 
		local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPos)
		if(mat =="masonry") then
			for colKey, validSurfaceColours in ipairs(self.validSurfaceColours) do 
				
				local validRange = validSurfaceColours.range
				if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
				 and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
				 and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b)) then 
					hitValue = 1
				end
			end
		else

			hitValue = -1
		end
	end
	--DebugPrint((#self.clustering.clusters.current.data))
	
	--DebugPrint("values: index: "..index.."\nhitpos:"..VecStr(hitPos).."\nhitval: "..hitValue.."\nClusterPos = "..VecStr(self.clustering.clusters.current.data[index]:getPos()))
	self.clustering.clusters.current.data[index]:push(hitPos[1],hitPos[2],hitPos[3],hitValue) 


	self.clustering.clusters.current.index = (self.clustering.clusters.current.index%self.clustering.dataSize )+1
end

function ai:pid()
	
	--- perform computations
	local targetNode, crossTrackErrorValue = self:currentCrossTrackError()
	-- DebugWatch("cross track error: ",crossTrackErrorValue)
	local crossTrackErrorRate = self:calculateCrossTrackErrorRate(crossTrackErrorValue)
	-- DebugWatch("cross track error rate: ",(crossTrackErrorRate))
	local integralErrorValue = self:calculateSteadyStateError(crossTrackErrorValue)
	-- DebugWatch("cross track error rate: ",(crossTrackErrorRate))
	-- update values 
	self.pidState.lastCrossTrackError = crossTrackErrorValue
	self.pidState.lastPnt = targetNode:getPos()
	-- calculate state 
	local output = (crossTrackErrorValue * self.pidState.pGain) + 
					(integralErrorValue * self.pidState.iGain) + 
					(crossTrackErrorRate * self.pidState.dGain)
	self.pidState.controllerValue = output
	DebugWatch("pid output: ",output)


	if(RACESTARTED and  self.pidState.training) then
		if math.abs(crossTrackErrorRate) > self.pidState.learningrateThres then 
			if(crossTrackErrorRate>0) then 
				self.accelerationCoef = self.accelerationCoef - self.pidState.learningrateweights
				self.steeringCoef = self.steeringCoef + self.pidState.learningrateweights

			else
				self.accelerationCoef = self.accelerationCoef + self.pidState.learningrateweights
				self.steeringCoef = self.steeringCoef - self.pidState.learningrateweights

			end

		end

	end

	return output
end


function ai:currentCrossTrackError()
	local crossTrackErrorValue = 0
	local vehicleTransform = GetVehicleTransform(self.id)
	local targetNode = self.clustering.clusters.centroids.data[self.clustering.mode]
	if(targetNode) then
		local pnt = targetNode:getPos()
		crossTrackErrorValue,sign = self:crossTrackError(pnt,vehicleTransform)
	end	
	return targetNode, crossTrackErrorValue,sign
end

--- calculate distance to target direction and apply steering by force
--- fill in the gap here related to the distance ebtween the aprrelel lines of target nod3e to vehicle pos to solve it all
function ai:crossTrackError(pnt,vehicleTransform)


		
		vehicleTransform.pos[2] = pnt[2]
		
		local linePnt = vehicleTransform.pos
		local fwd = TransformToParentPoint(vehicleTransform, Vec(0,0,-100))
		local d = VecLength(VecScale( VecCross(
							VecSub(fwd,linePnt),VecSub(pnt,linePnt)),
										VecLength(VecNormalize(VecSub(fwd,linePnt)))))/1000
		pnt = VecSub(pnt,linePnt)
		fwd = VecSub(fwd,linePnt)
		linePnt = VecSub(linePnt,linePnt)
		local sign = (fwd[1]-linePnt[1])*(pnt[3]-linePnt[3])-(fwd[3]-linePnt[3])*(pnt[1]-linePnt[1])
		if(sign<0) then
			sign = -1
		elseif(sign>0) then
			sign = 1
		else
			sign = 0
		end


		return d*sign,sign

		-- Use the sign of the determinant of vectors (AB,AM), where M(X,Y) is the query point:	
		---position = sign((Bx - Ax) * (Y - Ay) - (By - Ay) * (X - Ax))

		---d=np.cross(p2-p1,p3-p1)/norm(p2-p1)

		-- local linePnt = vehizcleTransform.pos
		-- local lineDir = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- lineDir = VecNormalize(VecSub(vehicleTransform.pos,fwd1	))

		-- local v = (VecSub(pnt,linePnt))
		-- local d = VecDot(v,lineDir)
		-- local out = VecAdd(linePnt,VecScale(lineDir,d))
		-- DebugWatch("point pos : ",pnt)
		-- DebugWatch("output pos : ",out)

		-- DebugWatch("output value: ",VecSub(out,pnt))







		-- local vehicleTransform = GetVehicleTransform(self.id)
		-- vehicleTransform.pos[2] = targetNode:getPos()[2]
		-- local fwd1 = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- local norm = VecNormalize(VecSub(vehicleTransform.pos,fwd1	))
		-- local vBase =  VecSub(targetNode:getPos(),vehicleTransform.pos)
		-- local lineDir = VecSub(targetNode:getPos(),vehicleTransform.pos)
		-- local v1 = VecDot(vBase,norm)
		-- local pntDist = VecAdd(,VecScale(norm,v1))
		-- DebugWatch("distance to point: ",VecLength(pntDist))
		-- DebugWatch("V1 VAL: ",v1)
		-- local v = VecLength(VecSub(vehicleTransform.pos,fwd1))
		-- local d = VecLength(VecScale(VecSub(targetNode:getPos(),vehicleTransform.pos),v))
		-- -- DebugWatch("vector : ",v)
		-- DebugWatch("delta : ", d/10)
		-- DebugWatch("value from origin",VecSub(vehicleTransform.pos,fwd1))

end

function ai:calculateCrossTrackErrorRate(crossTrackErrorValue)
	local verifyCrossCheckErrorVal = 0
	local vehicleTransform = GetVehicleTransform(self.id)
	
	local pnt = self.pidState.lastPnt
	if(pnt) then
		
		verifyCrossCheckErrorVal = self:crossTrackError(pnt,vehicleTransform)
		verifyCrossCheckErrorVal = self.pidState.lastCrossTrackError - verifyCrossCheckErrorVal

	end	

	return verifyCrossCheckErrorVal
end


function ai:calculateSteadyStateError(crossTrackErrorValue)
	local index = self.pidState.integralIndex

	self.pidState.integralSum = self.pidState.integralSum - self.pidState.integralData[index]
	self.pidState.integralSum = self.pidState.integralSum + crossTrackErrorValue
	self.pidState.integralData[index] = crossTrackErrorValue

	self.pidState.integralIndex = (self.pidState.integralIndex%#self.pidState.integralData) +1

	return self.pidState.integralSum	
end

function ai:accelerationError()
	local accelerationErrorValue = 0
	local vehicleTransform = GetVehicleTransform(self.id)
	local targetNode = self.clustering.clusters.centroids.data[self.clustering.mode]
	if(targetNode) then
		local pnt = targetNode:getPos()
		vehicleTransform.pos[2] = pnt[2]
		local linePnt = vehicleTransform.pos
		local lineDir = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		lineDir = VecNormalize(lineDir)
		local v = (VecSub(pnt,linePnt))
		local d = VecDot(v,lineDir)
		local out = VecAdd(linePnt,VecScale(lineDir,d))
		-- DebugWatch("line distance: ",VecLength(VecSub(vehicleTransform.pos,out))/self.scanning.scanLength*self.scanning.scanDepths)

		return VecLength(VecSub(vehicleTransform.pos,out))
	end	

		-- Use the sign of the determinant of vectors (AB,AM), where M(X,Y) is the query point:	
		---position = sign((Bx - Ax) * (Y - Ay) - (By - Ay) * (X - Ax))

		---d=np.cross(p2-p1,p3-p1)/norm(p2-p1)

		-- local linePnt = vehizcleTransform.pos
		-- local lineDir = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- lineDir = VecNormalize(VecSub(vehicleTransform.pos,fwd1	))

		-- local v = (VecSub(pnt,linePnt))
		-- local d = VecDot(v,lineDir)
		-- local out = VecAdd(linePnt,VecScale(lineDir,d))
		-- DebugWatch("point pos : ",pnt)
		-- DebugWatch("output pos : ",out)


	-- //linePnt - point the line passes through
	-- //lineDir - unit vector in direction of line, either direction works
	-- //pnt - the point to find nearest on line for
	-- public static Vector3 NearestPointOnLine(Vector3 linePnt, Vector3 lineDir, Vector3 pnt)
	-- {
	--     lineDir.Normalize();//this needs to be a unit vector
	--     var v = pnt - linePnt;
	--     var d = Vector3.Dot(v, lineDir);
	--     return linePnt + lineDir * d;
	-- }
end
 

function ai:vehicleController()
	DriveVehicle(self.id, 0.05+self.controller.accelerationValue,
							self.controller.steeringValue,
							 self.controller.handbrake)
end

function ai:MAV(targetCost)
	self.targetMoves.targetIndex = (self.targetMoves.targetIndex%#self.targetMoves.list)+1 
	self.targetMoves.target = VecSub(self.targetMoves.target,self.targetMoves.list[self.targetMoves.targetIndex])
	self.targetMoves.target = VecAdd(self.targetMoves.target,targetCost)
	self.targetMoves.list[self.targetMoves.targetIndex] = targetCost
	return VecScale(self.targetMoves.target,(#self.targetMoves.list/100))

end



function ai:costFunc(testPos,hit,dist,shape,key)



	local cost = 10000 
	if(not hit) then
		cost = VecLength(VecSub(testPos,self.goalPos))*(1-self.weights[key])
	end
	return cost
end



function ai:controlVehicle( targetCost)
	local hBrake = false
	if(VecLength(self.goalPos)> 0.5) then
		local targetMove = VecNormalize(targetCost.target)

		if(VecLength(
										VecSub(GetVehicleTransform(self.id).pos,self.goalPos))>2) then
			DebugWatch("pre updated",VecStr(targetMove))
			if(targetMove[1] ~= 0 and targetMove[3] ==0) then 
				targetMove[3] = -1
				
					targetMove[1] = -targetMove[1] * 3
				

			end
			if(targetMove[1]~= 0) then
				targetMove[3] = targetMove[3]*	cornerDrivePower 
				targetMove[1] = targetMove[1] * steerPower

			end 
			if(targetMove[1]==0 and targetMove[3]~=0) then

				targetMove[3] = targetMove[3] *3
			elseif(inRange(-0.1,0.1,targetMove[1]) and targetMove[3]~=0) then

				targetMove[3] = targetMove[3] *2
			end


			DriveVehicle(self.id, -targetMove[3]*drivePower,-targetMove[1], hBrake)
			DebugWatch("post updated",VecStr(targetMove))
			DebugWatch("motion2",VecStr(detectPoints[targetCost.key]))
		else 
			DriveVehicle(vehicle.id, 0,0, true)
		end
	end
end





function clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end





function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



function inRange(min,max,value)
		if(min < value and value<=max) then 
			return true

		else
			return false
		end

end