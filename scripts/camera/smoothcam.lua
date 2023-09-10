
-- emils camera script to make nice smooth floaty cameras 


DEBUG = false

cameraControlTag = "cameraController"
cameraKeyword = "panCam" 

function init()
	cameraController = FindLocation(cameraControlTag,true)

	lastCamKeyword = "nil"

	speed = GetFloatParam("speed",5)
	activateKey = GetStringParam("activateKey","m")
	if string.len(activateKey) == 0 then
		activateKey = "m"
	end
	if string.len(activateKey) > 1 then
		activateKey = string.sub(activateKey,1,1)
	end

	fixedCamTransform = nil
	feetToEye = 1.6933022737503
	lastCamDirection = nil
	lastPointSet = nil
	pointSet = {}
	nextPointSet = {}
	fadePos = GetPlayerTransform().pos
	fadeRot = GetPlayerTransform().rot
	t = nil
	tn = nil
	active = false
	fade = 0
	pathTimer = 0
	nextCam = -3
	timeInt = -1

	--##############

	camlocations = FindLocations("camlocation", true)
	if #camlocations < 4 then
		DebugPrint("Too few camera locations setup for Smoothcam.")
		return
	end

	-- Order the camlocations according to the value of their respective camlocation tag into the array smoothcams
	smoothcams = {}
	for i = 1, #camlocations do
		--smoothcams[tonumber(GetTagValue(camlocations[i],"camlocation"))] = GetLocationTransform(camlocations[i])
		smoothcams[i] = GetLocationTransform(camlocations[i])
		-- local val = GetTagValue(camlocations[i],"camlocation")
	end

	-- Break if the number of smoothcams doesn't match the number of camlocations, indicating the camlocations ahs been wrongly numbered
	if #smoothcams ~= #camlocations then
		DebugPrint("Camera locations does not appear to be numbered correctly for Smoothcam.")
		return
	end
	
	-- Duplicate first 4 cameralocations to the last four
	for i = 1, 4 do
		smoothcams[#smoothcams+1] = smoothcams[i]
	end

	bezierPoints = {}
	for i = 2, #smoothcams-1, 2 do
		bezierPoints[#bezierPoints+1] = bezierCenter(smoothcams[i-1].pos, smoothcams[i].pos)
		bezierPoints[#bezierPoints+1] = smoothcams[i].pos
		bezierPoints[#bezierPoints+1] = smoothcams[i+1].pos

		if i + 2 <= #smoothcams then
			bezierPoints[#bezierPoints+1] = bezierCenter(smoothcams[i+1].pos, smoothcams[i+2].pos)
		end
	end
end

function tick(dt)
	-- if InputPressed(activateKey) then
	-- 	active = active ~= true -- toggle state of active on press of the activateKey
	-- 	if active then
	-- 		fixedCamTransform = GetCameraTransform()
	-- 		DebugPrint("active is now: true")
	-- 		SetValue("fade",1,"cosine",3*(1-fade))
	-- 		fadePos = VecAdd(GetPlayerTransform().pos,Vec(0,feetToEye,0))
	-- 		fadeRot = GetPlayerTransform().rot
	-- 	else
	-- 		DebugPrint("active is now: false")
	-- 		SetValue("fade",0,"cosine",3*fade)
	-- 	end
	-- end

	-- DebugWatch("cam tag val ", GetTagValue(cameraController, cameraControlTag))

	local currentKeyword = GetTagValue(cameraController, cameraControlTag) 
	if currentKeyword ~= lastCamKeyword and currentKeyword == cameraKeyword then
		active =  true -- toggle state of active on press of the activateKey
		fixedCamTransform = GetCameraTransform()
		-- DebugPrint("active is now: true")
		SetValue("fade",1,"cosine",3*(1-fade))
		fadePos = VecAdd(GetPlayerTransform().pos,Vec(0,feetToEye,0))
		fadeRot = GetPlayerTransform().rot
			
	elseif(currentKeyword ~= lastCamKeyword and currentKeyword ~= cameraKeyword) then
		active = false -- toggle state of active on press of the activateKey
			-- DebugPrint("active is now: false")
			SetValue("fade",0,"cosine",3*fade)
	end
	
	lastCamKeyword = currentKeyword
	local subPathTimer = (pathTimer/speed) % 1
	
	if math.floor(pathTimer/speed) > timeInt then
		nextCam = nextCam + 4
		timeInt = math.floor(pathTimer/speed)
		if nextCam > #bezierPoints-4 then
			--print("loop")
			nextCam = nextCam - #bezierPoints+4
		end
		--print("New pointSet")
		local currentPoint = nextCam
		local nextPointSetCurrentPoint = nextCam + 4
		local setCounter = 1
		for i = nextCam,nextCam+3 do
			while currentPoint > #bezierPoints do
				currentPoint = currentPoint - #bezierPoints
			end
			while nextPointSetCurrentPoint > #bezierPoints do
				nextPointSetCurrentPoint = nextPointSetCurrentPoint - #bezierPoints
			end
			pointSet[setCounter] = bezierPoints[currentPoint]
			nextPointSet[setCounter] = bezierPoints[nextPointSetCurrentPoint]
			currentPoint = currentPoint + 1
			nextPointSetCurrentPoint = nextPointSetCurrentPoint + 1
			setCounter = setCounter + 1
		end
	end

	if active then
		t = cubicBezier(pointSet, subPathTimer) --bezierPoints[nextCam], bezierPoints[nextCam+1], bezierPoints[nextCam+2], bezierPoints[nextCam+3]
		if subPathTimer + 0.1 >= 1 then
			tn = cubicBezier(nextPointSet, subPathTimer + 0.1 - 1)
		else
			tn = cubicBezier(pointSet, subPathTimer + 0.1)
		end

		fadePos = VecLerp(fadePos,VecLerp(VecAdd(GetPlayerTransform().pos,Vec(0,feetToEye,0)),t,fade), 0.05)
		fadeRot = QuatSlerp(fadeRot,QuatSlerp(GetPlayerTransform().rot,QuatLookAt(t, tn),fade),0.05)

		if true then
			local c = nextCam
			while c+4 > #smoothcams do
				c = c - #smoothcams
			end
		end
		SetCameraTransform(Transform(fadePos,fadeRot))
	else
		if fade > 0 then
			t = cubicBezier(pointSet, subPathTimer)
			if subPathTimer + 0.1 >= 1 then
				tn = cubicBezier(nextPointSet, subPathTimer + 0.1 - 1)
			else
				tn = cubicBezier(pointSet, subPathTimer + 0.1)
			end
			fadePos = VecLerp(fadePos,VecLerp(VecAdd(GetPlayerTransform().pos,Vec(0,feetToEye,0)),t,fade), 0.05)
			fadeRot = QuatSlerp(fadeRot,QuatSlerp(GetPlayerTransform().rot,QuatLookAt(t, tn),fade),0.05)
			SetCameraTransform(Transform(fadePos,fadeRot))
		end
	end
	if(DEBUG) then
		DebugWatch("bezierPoints: ", #bezierPoints)
		DebugWatch("pathTimer: ", pathTimer)
		DebugWatch("pathTimer/speed: ", (pathTimer/speed))
		DebugWatch("subPathTimer: ", subPathTimer)
		DebugWatch("fade: ", fade)
		DebugWatch("timeInt: ", timeInt)
		DebugWatch("dt: ", dt)
		DebugWatch("subPathTimer % 0.25: ", (subPathTimer % 0.25))
	end
	if active or fade > 0 then
		pathTimer = pathTimer + dt
	end
end

function cubicBezier(ps,t)
	local x = cubicBezierPoint(ps[1][1],ps[2][1],ps[3][1],ps[4][1],t)
	local y = cubicBezierPoint(ps[1][2],ps[2][2],ps[3][2],ps[4][2],t)
	local z = cubicBezierPoint(ps[1][3],ps[2][3],ps[3][3],ps[4][3],t)

	local v = Vec(x,y,z)
	return v
end

function cubicBezierPoint(a0,a1,a2,a3,t)
	return math.pow(1 - t, 3) * a0 + 3 * math.pow(1 - t, 2) * t * a1 + 3 * (1 - t) * math.pow(t, 2) * a2 + math.pow(t, 3) * a3;
end

function bezierCenter(a,b)
	local x = (a[1] + b[1]) / 2
	local y = (a[2] + b[2]) / 2
	local z = (a[3] + b[3]) / 2
	local v = Vec(x,y,z)
	return v
end