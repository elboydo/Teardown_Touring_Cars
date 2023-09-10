
robot = {}

ACTIVE =1
INACTIVE = 0

function robot:initRobot(vehicle) 

	if unexpected_condition then error() end
	
	self.id = vehicle
	self.body = GetVehicleBody(self.id)
	self.transform =  GetBodyTransform(self.body)
	self.shapes = GetBodyShapes(self.body)
	self.weapons = {}
	local totalShapes = ""
	for i=1,#self.shapes do
		joints = GetShapeJoints(self.shapes[i])
		DebugPrint(#joints.." | "..#self.shapes)
		if(#joints>0) then
			for i=1,#joints do
				local value = GetTagValue(joints[i], "component")
		
				if(value~= "")then

						if(value=="rotating") then
							id = #self.weapons+1
							DebugPrint(value.." | "..id)
							self.weapons[id] = {}
							self.weapons[id].joint = joints[i]
							self.weapons[id].type = "rotating" 
							self.weapons[id].state = INACTIVE
							self.weapons[id].rpm 	= 25

						end

				end
			end
		end
	end
end

function robot:tick(dt)
	if InputPressed("lmb") then
		DebugPrint(#self.weapons)
		self:weaponActivation()
	end
	for key,weapon in ipairs(self.weapons) do 
		self:weaponFunctions(weapon)
	end

	
end

function robot:weaponActivation(dt)
	for key,weapon in ipairs(self.weapons) do 
		
		if(weapon.type == "rotating") then

			if(weapon.state == INACTIVE) then
				DebugPrint("activating")
				weapon.state = ACTIVE
			else
				weapon.state = INACTIVE
				DebugPrint("stopping")
			end
		end
	end
end
function robot:weaponFunctions(weapon) 
	if(weapon.state == ACTIVE) then
		SetJointMotor(weapon.joint, weapon.rpm)

	else
		SetJointMotor(weapon.joint, 0,200)
	end
end


function inVehicle(  )

end

function init()
	DebugPrint("start")
	vehicle = FindVehicle("cfg")
	fightingRobot = robot
	---robot:initRobot(robot)
	fightingRobot:initRobot(vehicle)
	 -- status,retVal = pcall(,vehicle)
	DebugPrint("started")
end

function tick(dt)
	DebugWatch("vehicle:",fightingRobot.id)
	if(fightingRobot.id~= 0 and GetPlayerVehicle()==fightingRobot.id)then
		-- DebugPrint("test")
		fightingRobot:tick(dt)
	end
end