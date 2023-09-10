-- Animate camera (both position and orientation) between two locataions in a given time


pTime = GetFloatParam("time", 10)


timeVal = 0

function init()
	locations  = FindLocations("f1_camLoc",true)

	startTransform = GetLocationTransform(FindLocation("start"))
	endTransform = GetLocationTransform(FindLocation("end"))
	tim = 0.0
	target =0
	transitionTime = pTime/#locations

	SetValue("timeVal", pTime-transitionTime, "cosine", pTime)


	SetCameraTransform( GetLocationTransform(locations[2]))
	lastTarget = -1
	currentTarget = GetLocationTransform(locations[1])
	nextTarget = GetLocationTransform(locations[2])	
	lastTargetRot = Quat()
end


function tick(dt)

	local t = (timeVal%transitionTime) / transitionTime
	local target = math.floor(timeVal/transitionTime)+1
	local progress = timeVal%transitionTime
	DebugWatch("t time",t)
	DebugWatch("tiemval",(timeVal%transitionTime) )
	DebugWatch("transitionTime",transitionTime)
	DebugWatch("current point:",math.floor((timeVal/transitionTime)+1).." / "..#locations)

	if(target~= lastTarget) then
		DebugPrint(VecStr(currentTarget.pos))
		lastTarget = target 
		currentTarget = GetLocationTransform(locations[target])
		DebugPrint(target.." | "..target+1)
		nextTarget = GetLocationTransform(locations[target+1])
		DebugPrint(tostring(IsHandleValid(locations[target])).." | "..tostring(IsHandleValid(locations[target+1])))
		lastTargetRot = QuatCopy(nextTargetRot)
		nextTargetRot = QuatLookAt(currentTarget.pos, nextTarget.pos)

	end
	local pos = VecLerp(currentTarget.pos, nextTarget.pos, t)
	local rot = QuatSlerp(lastTargetRot, nextTargetRot, t)
	-- if t > 1.0 then t = 1.0 end
	-- if()
	-- local pos = VecLerp(startTransform.pos, endTransform.pos, t)
	-- local rot = QuatSlerp(startTransform.rot, endTransform.rot, t)

	DebugPrint(VecStr(pos))
	SetCameraTransform(Transform(pos, rot))
end

