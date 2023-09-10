
--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        skiMode.lua             
*
* DESCRIPTION :
*       File made by Rav mahov For something super secret.
*		
*
* NOTES :
*       
*
* AUTHOR :    Rav Mahov        START DATE   :    N/A
* 							 Release Date :    N/A 
*
]]

SKI_MODE = false
TARGET_ANGLE  =45


leftThrust = Vec(-7.5, -1.5 ,0)

rightThrust = Vec(14, 200 ,0)


bodyMass  = 0
imp = Vec(0,250,0)

function init( )
	
	vehicle = FindVehicle("cfg")
	body = GetVehicleBody(vehicle)
	shapes = GetBodyShapes(body)

	bodyMass =  GetBodyMass(body)
	imp[2] = bodyMass
end


function tick()
	bodyMass =  GetBodyMass(body)/100
	imp[2] = bodyMass

	DebugWatch("bodymass ",bodyMass)
	local min, max = GetBodyBounds(body)
	local boundsSize = VecSub(max, min)
	DebugWatch("bounds",boundsSize)
	if InputPressed("g") then
		if(not SKI_MODE) then 
			ApplyBodyImpulse(body, leftWheelBase,VecScale(imp,-1.5))
		end

		SKI_MODE = not SKI_MODE

	end


	if SKI_MODE then 
		targetAngle = (math.sin(math.rad(70)) * ((-7.5)))
		local rightWheelBase = TransformToParentPoint(GetVehicleTransform(vehicle),rightThrust)

		local leftWheelBase = TransformToParentPoint(GetVehicleTransform(vehicle),leftThrust)
		DebugWatch("targetAngle",targetAngle)

		DebugWatch("left wheel base ",leftWheelBase)
		DebugWatch("right wheel base",rightWheelBase)
		DebugWatch("current pos",VecSub(rightWheelBase,leftWheelBase)[2])
		if((VecSub(leftWheelBase, rightWheelBase)[2])<targetAngle) then
			ApplyBodyImpulse(body, leftWheelBase,VecScale(imp,1.2))
			DebugWatch("applying impulse up",imp)
		else
			ApplyBodyImpulse(body, leftWheelBase,VecScale(imp,-1.2))
			DebugWatch("applying impulse down",VecScale(imp,-1))
		end
	end
end