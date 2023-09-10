
detectRange = 5

vehicle = 

			{

			}

maxSpeed = 20


goalPos = Vec(0,0,0)
SPOTMARKED = false

gCost = 1

testHeight = 1
drivePower = 0.5

detectPoints = {
	[1] = Vec(0,-0.2,-detectRange*1.2),
	[2] = Vec(detectRange,-0.2,-detectRange),
	[3] = Vec(-detectRange,-0.2,-detectRange),
	[4] = Vec(-detectRange,-0.2,0),
	[5] = Vec(detectRange,-0.2,0),
	[6] = Vec(0,-0.2,detectRange*.5),

}


targetMoves = {
	list        = {},
	target      = Vec(0,0,0),
	targetIndex = 1
}




hitColour = Vec(1,0,0)
clearColour = Vec(0,1,0)

function init()

	for i=1,10 do 
		targetMoves.list[i] = Vec(0,0,0)

	end

	vehicle.id = FindVehicle("cfg")
	local value = GetTagValue(vehicle.id, "cfg")
	if(value == "ai") then

		-- local status,retVal = pcall(initVehicle)
		-- if status then 
		-- 	DebugPrint("no errors")
		-- else
		-- 	DebugPrint(retVal)
		-- end

	end
				
end


function tick(dt)
	markLoc()

end

function markLoc()
	
	if InputPressed("g") then

		local camera = GetCameraTransform()
		local aimpos = TransformToParentPoint(camera, Vec(0, 0, -300))
		local hit, dist,normal = QueryRaycast(camera.pos,  VecNormalize(VecSub(aimpos, camera.pos)), 200,0)
		if hit then
			
			goalPos = TransformToParentPoint(camera, Vec(0, 0, -dist))

		end 	

		DebugPrint("hitspot"..VecStr(goalPos).." | "..dist.." | "..VecLength(
									VecSub(GetVehicleTransform(vehicle.id).pos,goalPos)))
	end

	if(VecLength(goalPos)~= 0) then 
		DebugWatch("goalpos",VecLength(goalPos))
		SpawnParticle("smoke", goalPos, Vec(0,5,0), 0.5, 1)
	end
end

function update(dt)


	targetCost = vehicleDetection2( )
	DebugWatch("targetCost:",VecStr(targetCost ))

	targetCost.target = MAV(targetCost.target)

	DebugWatch("targetCost 2 :",VecStr(targetCost ))
	controlVehicle(targetCost)

	DebugWatch("Vehicle ",vehicle.id)
	

	DebugWatch("velocity:", VecLength(GetBodyVelocity(GetVehicleBody(vehicle.id))))
end


function vehicleDetection2( )

	local vehicleBody = GetBodyTransform(GetVehicleBody(vehicle.id))
	local vehicleTransform = GetVehicleTransform(vehicle.id)
	local min,max = GetBodyBounds(vehicleBody)
	vehicleTransform.pos = TransformToParentPoint(vehicleTransform,Vec(0,testHeight,0))
	local fwd = 	TransformToParentPoint(vehicleTransform,Vec(0,0,-detectRange*1.5))
	local fwdL = 	TransformToParentPoint(vehicleTransform,Vec(detectRange,0,-detectRange))
	local fwdR = 	TransformToParentPoint(vehicleTransform,Vec(-detectRange,0,-detectRange))

	costs = { }
	bestCost = {key = 0, val = 1000}

	if(VecLength(goalPos)> 0.5 and VecLength(
									VecSub(GetVehicleTransform(vehicle.id).pos,goalPos))>3) then	
		for key,detect in ipairs(detectPoints) do 
			QueryRejectVehicle(vehicle.id)
		    local fwdPos = 
		    						TransformToParentPoint(
		    								vehicleTransform,detect)
		    local direction = VecSub(fwdPos,vehicleTransform.pos)
		    hit, dist = QueryRaycast(vehicleTransform.pos, direction, VecLength(direction)/1,0.1)
		    local lineColour = clearColour
		    if(hit and dist<detectRange)then
		    	lineColour = hitColour
		    end
		    DebugLine(vehicleTransform.pos, fwdPos, lineColour[1], lineColour[2], lineColour[3])
		    costs[key] = costFunc(TransformToParentPoint(
		    								vehicleTransform,detect),hit)
		    DebugWatch("costs: "..key,costs[key])
		    if costs[key] < bestCost.val  then
		    	bestCost.key = key
		    	bestCost.val = costs[key] 
		    	bestCost.target = detect
		    end
		end
	end
	return bestCost

	-- DebugLine(vehicleTransform.pos, fwd, 1, 0, 0)
	-- DebugLine(vehicleTransform.pos, fwdL, 1, 0, 0)
	-- DebugLine(vehicleTransform.pos, fwdR, 1, 0, 0)

end

function vehicleDetection( )

	local vehicleTransform = GetBodyTransform(GetVehicleBody(vehicle.id))
	vehicleTransform.pos = TransformToParentPoint(vehicleTransform,Vec(0,testHeight,0))
	local fwd = 	TransformToParentPoint(vehicleTransform,Vec(0,0,-detectRange*1.5))
	local fwdL = 	TransformToParentPoint(vehicleTransform,Vec(detectRange,0,-detectRange))
	local fwdR = 	TransformToParentPoint(vehicleTransform,Vec(-detectRange,0,-detectRange))

	costs = { }
	bestCost = {key = 0, val = 100}

	if(VecLength(goalPos)> 0.5 and VecLength(
									VecSub(GetVehicleTransform(vehicle.id).pos,goalPos))>3) then	
		for key,detect in ipairs(detectPoints) do 
			QueryRejectVehicle(vehicle.id)
		    local fwdPos = 
		    						TransformToParentPoint(
		    								vehicleTransform,detect)
		    local direction = VecSub(fwdPos,vehicleTransform.pos)
		    hit, dist = QueryRaycast(vehicleTransform.pos, direction, VecLength(direction)/1,.5)
		    local lineColour = clearColour
		    if(hit and dist<detectRange)then
		    	lineColour = hitColour
		    end
		    DebugLine(vehicleTransform.pos, fwdPos, lineColour[1], lineColour[2], lineColour[3])
		    costs[key] = costFunc(TransformToParentPoint(
		    								vehicleTransform,detect),hit)
		    DebugWatch("costs: "..key,costs[key])
		    if costs[key] < bestCost.val  then
		    	bestCost.key = key
		    	bestCost.val = costs[key] 
		    end
		end
	end
	return bestCost

	-- DebugLine(vehicleTransform.pos, fwd, 1, 0, 0)
	-- DebugLine(vehicleTransform.pos, fwdL, 1, 0, 0)
	-- DebugLine(vehicleTransform.pos, fwdR, 1, 0, 0)

end


function MAV(targetCost)
	targetMoves.targetIndex = (targetMoves.targetIndex%#targetMoves.list)+1 
	targetMoves.target = VecSub(targetMoves.target,targetMoves.list[targetMoves.targetIndex])
	targetMoves.target = VecAdd(targetMoves.target,targetCost)
	targetMoves.list[targetMoves.targetIndex] = targetCost
	return VecScale(targetMoves.target,(#targetMoves.list/100))

end

function controlVehicle( targetCost)

	if(VecLength(goalPos)> 0.5) then
		local targetMove = VecNormalize(detectPoints[targetCost.key])

		if(VecLength(
										VecSub(GetVehicleTransform(vehicle.id).pos,goalPos))>3) then
			DebugWatch("pre updated",VecStr(targetMove))
			if(targetMove[1] ~= 0 and targetMove[3] ==0) then 
				targetMove[3] = 1
				
					targetMove[1] = -targetMove[1]
				

			end

			DriveVehicle(vehicle.id, -targetMove[3]*drivePower,-targetMove[1]*drivePower, false)
			DebugWatch("post updated",VecStr(targetMove))
			DebugWatch("motion2",VecStr(detectPoints[targetCost.key]))
		end
	end
end


function costFunc(testPos,hit)
	local cost = 100 
	if(not hit) then 
		cost = VecLength(VecSub(testPos,goalPos))
	end
	return cost
end

function vehicleMovement(vel,angVel)
	local vehicleTransform = GetBodyTransform(vehicle.body)
	local targetVel = 	TransformToParentPoint(vehicleTransform,vel)
	targetVel = VecSub(targetVel, vehicleTransform.pos)
	local targetAngVel = 	angVel---TransformToParentPoint(vehicleTransform,angVel)
	local currentVel = GetBodyVelocity(vehicle.body)
	local currentAngVel = GetBodyAngularVelocity(vehicle.body)

	if(VecLength(currentVel)<maxSpeed) then

		SetBodyVelocity(vehicle.body,VecAdd(currentVel,targetVel))
	end
	SetBodyAngularVelocity(vehicle.body, VecAdd(currentAngVel,targetAngVel))

end

-- SetBodyVelocity(handle, velocity)
-- SetBodyAngularVelocity(body, angVel)