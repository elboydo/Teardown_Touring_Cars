--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        race_Manager.lua             
*
* DESCRIPTION :
*       File that manages racing game mode events, positions, and timings. 
*		alongside hud elements and win / lose states
*		

*
* NOTES :
*       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
* 							 Release Date :    29 Nov 2021 
*
]]


raceManager = {
	raceStarted = false,
	startTime = 0,
	raceWon = false,
	checkpoints = {},
	path = {},
	laps =1,
	positionsUpdateTime = 0.100,
	currentUpdateTime = 0,
	positions = {

	},
	racers = {

	},
	preCountdown = 5,
	countdown = 4,

	defaultDisplayRange = 40,
	maxDisplayRange = 4000,
	displayRange = 40,




	cameraControlTag = "cameraController",
	cameraKeyword = "panCam" ,


	preRaceCam = {
		startCam = {x = 0,y = 1,z = -1},




	},

	font =	 "MOD/fonts/nk57-monospace.bold.ttf",


	raceMusic = "MOD/sounds/caveisland-hunted.ogg",

	mapNames = {
		[1] = "caveisland",
		[2] = "frustrum",
		[3] = "lee",
		[4] = "mansion",
		[5] = "marina",




	}

}

	

	startPan = 0

	xPanMax = 1
	xPanMin = -1

	yPanMax = 2.0
	yPanMin = 0.5

	zPanMax = 1
	zPanMin = -1

	camXPan = xPanMax
	camYPan = yPanMax
	camZPan = zPanMax


	xtimerMin = 100
	xtimerMax = 500
	ytimerMin = 100
	ytimerMax = 500
	ztimerMin = 300
	ztimerMax = 3000


	cameraTargetVehicle = 1


function raceManager:init(racers,path)
	----- MORE DRIVE TO SURVIVE stuff

	self.raceMusic = self.mapNames[math.random(1,#self.mapNames)].."-hunted.ogg"



	self.laps = self.laps -1

	self.sndWin = LoadSound("MOD/sounds/win.ogg")

	self.sndFail = LoadSound("MOD/sounds/fail.ogg")
	---------


	self.cameraController = FindLocation(self.cameraControlTag,true)
	self.lastCamKeyword = "nil"



	self.path = path
	for key,val in ipairs(racers) do 
		self.racers[#self.racers+1] = val
		-- DebugPrint(self.racers[#self.racers].driverName.." | "..#self.racers)
		self.positions[#self.positions+1] = {car = key,finished = false} 
	end

	self.currentUpdateTime = self.positionsUpdateTime



		--- stuff for race prep and sounds and stuff

	self.startTimerInt = math.floor(self.countdown)
	self.sndReady = LoadSound("MOD/sounds/ready.ogg")

	self.sndStart = LoadSound("MOD/sounds/start.ogg")

	self.trackType = GetTagValue(FindLocation("trackType"),"trackType")

	if self.trackType == nil or self.trackType == "" then 

		self.trackType = "default"
	end


end

function raceManager:startRace()
	self.startTime = GetTime()
end


function raceManager:lapTime()
	return GetTime() -  self.startTime 
end


function raceManager:cameraControl()
	local currentKeyword = GetTagValue(self.cameraController, self.cameraControlTag) 

	self.lastCamKeyword = currentKeyword

	if(InputPressed("space") or InputPressed("interact")) then
		RACECOUNTDOWN = true
		SetTag(self.cameraController,self.cameraControlTag,"raceStarted") 
	end
end


function raceManager:raceCountdown()
	if(self.preCountdown >0 ) then
		self.preCountdown = self.preCountdown - GetTimeStep()
	elseif(self.countdown>0) then
			self.countdown = self.countdown - GetTimeStep()
			if(math.floor(self.countdown) < self.startTimerInt) then
				self.startTimerInt = math.floor(self.countdown)
				if math.floor(self.countdown) > 0 then
					PlaySound(self.sndReady)

					-- if(PLAYERRACING) then
					-- 	self:StartCamPos(math.floor(self.countdown))
					-- end
				else
					if(not RACESTARTED) then 
						PlaySound(self.sndStart)
					end

					if(not STOPTHEMUSIC) then 
						PlayMusic(self.raceMusic)
					end
					RACESTARTED =true
					self:startRace()
				end
			end

		
	end 
end



--- handle player split times and lap tims - must use triggers instead of default optimal points

function raceManager:playerHandler()
 	if (not playerConfig.finished and aiVehicles[playerConfig.car].raceValues.laps > self.laps) then
 		playerConfig.finished = true
 		StopMusic()
 		PlaySound(self.sndWin)
 		RACEENDED = true
 		playerConfig.finalTime = self:lapTime()
 		if(playerConfig.finalTime < savedBest)then
 			SetFloat("savegame.mod.besttime."..raceMap.."."..self.trackType.."." .. GetTagValue(roundCar,"trackinfo"),playerConfig.finalTime)
 		end
 		if(not bestLap or  playerConfig.bestLap < bestLap) then
			SetFloat("savegame.mod.bestLap."..raceMap.."."..self.trackType.."." .. GetTagValue(roundCar,"trackinfo"),playerConfig.bestLap)
 		end 
 	elseif( not playerConfig.finished and GetVehicleHealth(aiVehicles[playerConfig.car].id)<=0.05 ) then
 		playerConfig.finished = true
 		StopMusic()
 		PlaySound(self.sndFail)
 		PLAYER_TOTALED = true 	
 		RACEENDED = true	
 	end
 end 

	-- if(PLAYERRACING) then 
	-- 	if(raceManager.countdown > 0 and  raceManager.preCountdown <=0 ) then
	-- 		raceManager:StartCamPos()
	-- 	end

	-- end


function raceManager:cameraManager()

	--- get input to change target car
	if(InputPressed("left")) then
		cameraTargetVehicle = cameraTargetVehicle  - 1
		if(cameraTargetVehicle ) < 1 then 
			cameraTargetVehicle  = #self.positions
		end
	elseif(InputPressed("right")) then 
		cameraTargetVehicle = (cameraTargetVehicle%#self.positions) + 1
	elseif(InputPressed("up")) then
		cameraTargetVehicle = 1
	end

	local car = self.positions[cameraTargetVehicle].car



	self:cameraOperator(car)
	-- body
end


function raceManager:cameraOperator(car)
	local leadCar = self.racers[car]
	-- DebugWatch("leading car: ",leadCar.driverName)
	local vehicleTransform = GetVehicleTransform(leadCar.id)

	if(camXPan >=xPanMax)then

		SetValue("camXPan", xPanMin, "linear", math.random(xtimerMin,xtimerMax)/100)
	
	elseif(camXPan<=xPanMin) then
		SetValue("camXPan", xPanMax, "linear", math.random(xtimerMin,xtimerMax)/100)
	end
	if(camYPan >=yPanMax)then

		SetValue("camYPan", yPanMin, "cosine", math.random(ytimerMin,ytimerMax)/100)
	
	elseif(camYPan<=yPanMin) then
		SetValue("camYPan", yPanMax, "cosine", math.random(ytimerMin,ytimerMax)/100)
	end
	if(camZPan >=zPanMax)then

		SetValue("camZPan", zPanMin, "cosine", math.random(ztimerMin,ztimerMax)/100)
	
	elseif(camZPan<=zPanMin) then
		SetValue("camZPan", zPanMax, "cosine", math.random(ztimerMin,ztimerMax)/100)
	end

	local xPan = 0

	local camPos = Vec((leadCar.bodyXSize/3)*camXPan,0,(-leadCar.bodyYSize/3)*camZPan)
	camPos =  TransformToParentPoint(vehicleTransform,camPos)
	camPos = VecAdd(camPos,Vec(0,(leadCar.bodyZSize/3)*camYPan),0)
	local camRot = QuatLookAt(camPos,vehicleTransform.pos)
	
	SetCameraTransform(Transform(camPos,camRot))

	-- local front = self.bodyYSize/4 
	-- local side = self.bodyXSize/4
	-- local height = self.bodyZSize /4

	-- vehicleTransform.pos = TransformToParentPoint(vehicleTransform,Vec(0,height/4	,-front/4))
	-- local front = self.bodyYSize/4 
	-- local side = self.bodyXSize/4
	-- local height = self.bodyZSize /4
end


function raceManager:StartCamPos(countdown)
	local leadCar = aiVehicles[playerConfig.car]
	local vehicleTransform = GetVehicleTransform(aiVehicles[playerConfig.car].id)

	-- local camPos = Vec((leadCar.bodyXSize/3)* math.random(xtimerMin,xtimerMax)/100,0,(-leadCar.bodyYSize/3)*math.random(ztimerMin,ztimerMax)/100)
	-- camPos =  TransformToParentPoint(vehicleTransform,camPos)
	-- camPos = VecAdd(camPos,Vec(0,(leadCar.bodyZSize/3)*math.random(ytimerMin,ytimerMax)/100),0)
	-- local camRot = QuatLookAt(camPos,vehicleTransform.pos)
	
	-- SetCameraTransform(Transform(camPos,camRot))


end

function raceManager:raceTick()
	if not string.find(GetString("game.levelpath"), "main.xml") then
		if PauseMenuButton("Teardown Touring Cars") then
			StartLevel("", "MOD/main.xml")
		end
	end

	-- ###################################
	-- #
	-- # Racing gates
	-- #	
	-- ###################################	

	if(self.currentUpdateTime<0) then
		self.currentUpdateTime = self.positionsUpdateTime
		local checkVals = {}

		local bestVal = {0,0}
		local lapVal = 0
		local finished = false
		for i = 1,#self.positions do 
			if(not self.positions[i].finished) then
				finished = false 
				bestVal = {[1] = 0,[2] = 0,[3] = 1000}
				lapVal = 0

				-- iterate through list of racers and do simple seelction sort based on target node and dist to node

				for key,racer in ipairs(self.racers) do 
					lapVal =  racer.raceValues.completedGoals + racer.raceValues.laps * #self.path

					if(not checkVals[key] and  (lapVal > bestVal[2] or (lapVal == bestVal[2] and  racer:goalDistance()<bestVal[3]))) then
						
						
						bestVal[1] = key
						bestVal[2] = lapVal 
						bestVal[3] =  racer:goalDistance()
						-- DebugPrint(self.racers[key].raceValues.laps.." | "..lapVal)
					end
				end
				if(bestVal[1]) ~= 0 then
					a = self.racers[bestVal[1]].raceValues
					if(self.racers[bestVal[1]].raceValues.laps > self.laps) then
						finished = true
					end
					checkVals[ bestVal[1]] = true
					self.positions[i].car = bestVal[1]
					self.positions[i].finished = finished
				end
			else
				checkVals[self.positions[i].car] = true
			end
		end
	else
		self.currentUpdateTime = self.currentUpdateTime - GetTimeStep()
	end
end



function raceManager:raceGates()

	-- ###################################
	-- #
	-- # Racing gates
	-- #	
	-- ###################################

	inTrigger = 0
	if not gameOver and not gameWin then
		--if v > 0 then
			for i=1,#triggers do
				if IsVehicleInTrigger(triggers[i], v) or IsVehicleInTrigger(triggers[i], startCar) then
					if gateState[i] == 0 then
						if i == #triggers and totalPassed == 0 then
							--We just passed the finish gate, but now as the start line.
						else
							if i == 1 then
								gateState[i] = 1
								SetTag(triggers[i],"uipos","green")
								totalPassed = totalPassed + 1
								raceTime = raceTime + 15
								local indicatorColor = {0,1,0}
								addPowerupIndicator("CHECKPOINT!" ..  " +15s TIME!",indicatorColor)
								if totalPassed < #triggers then
									PlaySound(sndConfirm)
								end
							elseif i > 1 and gateState[i-1] == 1 then
								if i == #triggers and (not IsVehicleInTrigger(triggers[i], startCar) and v ~= startCar) then
									if lastFrameInTrigger == 0 then
										PlaySound(sndReject)
										local indicatorColor = {1,0,0}
										addPowerupIndicator("YOU MUST FINISH WITH THE START CAR!",indicatorColor)
									end
								else
									gateState[i] = 1
									SetTag(triggers[i],"uipos","green")
									totalPassed = totalPassed + 1
									raceTime = raceTime + 15
									if totalPassed < #triggers then
										local indicatorColor = {0,1,0}
										addPowerupIndicator("CHECKPOINT!" ..  " +15s TIME!",indicatorColor)
										PlaySound(sndConfirm)
									end
								end
								
							else
								if lastFrameInTrigger == 0 then
									PlaySound(sndReject)
									local indicatorColor = {1,0,0}
									addPowerupIndicator("WRONG CHECKPOINT!",indicatorColor)
								end
							end
						end
					end
					inTrigger = inTrigger + 1
				end
			end
		--end
	end
end


function raceManager:round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


function raceManager:formatTime(time)
	minutes = math.floor(time/60)
	if minutes < 10 then
		minutes = "0"..minutes 
	end
	-- minutes = 0
	seconds = self:round(time%60,2)
	if seconds < 10 then
		seconds = "0"..seconds
	end
	return minutes..":"..seconds
end


function raceManager:draw()

		-- DebugPrint(#self.positions)


		if PLAYERRACING and (not RACESTARTED or playerConfig.finished) then
			UiMakeInteractive()
		end

		UiPush()
		UiAlign("top left")
		local w = 400
		local h = #self.positions*22 + 60
		UiTranslate(UiWidth()-w-20, 50)--UiHeight()-h-20 - 200) -- because I don't know how big the official vehicle UI will be
		

		-- if(PLAYERRACING) then 
		-- 	self:displayPlayerPos()

		-- end


		UiAlign("top left")

		UiColor(0,0,0,0.5)
		UiImageBox("ui/common/box-solid-6.png", w, h, 6, 6)
		UiTranslate(125, 32)
		UiColor(1,1,1)
		UiTranslate(-80, 0)

		pushVals = 0

		local totalTranslate = 0 
		local posGap = 10
		local nameOffset = 160
		local numOffset = 40
		local lapNumOffset = 50	

		local dedentOffset = (posGap+nameOffset+numOffset+lapNumOffset)
		
		local func = "Driver"
		local driverNum = "Car"
		UiFont("bold.ttf", 22)
		UiAlign("right")
		UiText("Pos")
		UiTranslate(posGap, 0)
		-- UiFont("regular.ttf", 22)
		UiAlign("left")			
		UiText(func)
		UiTranslate(nameOffset, 0)
		-- UiText("| "..driverNum)
		UiTranslate(numOffset,0)
		UiText(" | ".."Laps")

		UiTranslate(lapNumOffset,0)
		UiText(" | ".."Best Lap")
		UiTranslate(-dedentOffset, 22)

		for key,val in ipairs(self.positions) do
			
			if(self.racers[val.car].raceValues.laps<=self.laps) then 
				UiColor(1,1,1)
			else
				UiColor(0,1,0)
			end


				
			-- info[#info+1] = {key, self.racers[val.car].driverName,val.car}
			-- DebugPrint(val.car.." | "..self.racers[val.car].driverName.." | "..key)
			
			local func = self.racers[val.car].driverName
			if(not self.racers[val.car].playerName and self.racers[val.car].driverFName and self.racers[val.car].driverSName) then
				-- DebugPrint(string.sub(self.racers[val.car].driverFName, 1, 1))
				func =   string.sub(self.racers[val.car].driverFName, 1, 1).."."..self.racers[val.car].driverSName


			elseif(self.racers[val.car].playerName) then
				func = self.racers[val.car].playerName
			end


			local driverNum = val.car
			UiFont("bold.ttf", 22)
			UiAlign("right")
			UiText(key)
			UiTranslate(posGap, 0)
			UiFont("regular.ttf", 22)
			UiAlign("left")			
			UiText(func)
			UiTranslate(nameOffset, 0)
			-- UiText("| "..driverNum)
			UiTranslate(numOffset,0)
			UiText(" | "..self.racers[val.car].raceValues.laps)

			UiTranslate(lapNumOffset,0)

			local lapTime = 0

			if(	 self.racers[val.car].raceValues.bestLap ) then
				lapTime = self.racers[val.car].raceValues.bestLap 


			elseif(RACESTARTED) then

				lapTime= self:lapTime()

			end
			UiText(" | "..self:formatTime(lapTime))
			UiTranslate(-dedentOffset, 22)


			-- UiTranslate(10, 0)
			-- UiFont("regular.ttf", 22)
			-- UiAlign("left")
			-- UiText(func.." | "..driverNum.." | "..self.racers[val.car].raceValues.laps)

			-- UiTranslate(-10, 22)
		end
		UiPop()



		-- info = {}
		-- for key,val in ipairs(self.positions) do
			
				
		-- 	info[#info+1] = {key, self.racers[val.car].driverName,val.car}
		-- 	DebugPrint(self.racers[val.car].driverName.." | "..key)
		-- end
		-- DebugPrint(#self.positions)

		-- UiPush()
		-- UiAlign("top left")
		-- local w = 250
		-- local h = #info*22 + 30
		-- UiTranslate(UiWidth()-w-20, UiHeight()-h-20 - 200) -- because I don't know how big the official vehicle UI will be
		-- UiColor(0,0,0,0.5)
		-- UiImageBox("ui/common/box-solid-6.png", 250, h, 6, 6)
		-- UiTranslate(125, 32)
		-- UiColor(1,1,1)
		-- UiTranslate(-60, 0)
		-- for i=1, #info do
			
		-- 	local key = info[i][1]
		-- 	local func = info[i][2]
		-- 	local driverNum = info[i][3]
		-- 	UiFont("bold.ttf", 22)
		-- 	UiAlign("right")
		-- 	UiText(key)
		-- 	UiTranslate(10, 0)
		-- 	UiFont("regular.ttf", 22)
		-- 	UiAlign("left")
		-- 	UiText(func.." | "..driverNum)

		-- 	UiTranslate(-10, 22)
		-- end
		-- UiPop()

end



function raceManager:displayPlayerPos(customSize)
	local offset = {x = 100, y = 50}
	local textSize = 64
	local infoTextSize = 24

	if(customSize) then
		textSize = customSize
	end
	UiFont("bold.ttf", textSize )

	-- UiTranslate(0,yOffset)


	for key,val in ipairs(self.positions) do
			
		if(self.racers[val.car].id == self.racers[playerConfig.car].id) then
			
			local position = self:ordinal_numbers(tostring(key))


			UiTranslate(offset.x,0)
			UiAlign("right middle")
			UiFont("bold.ttf", textSize )

		--- draw current player laps
			if(PLAYER_TOTALED) then 
				UiAlign("center middle")
				position = "DNF - player wrecked"
			end
			UiText(position )
			UiTranslate(-offset.x,0	)
			

			break
		end 
	end


end


function raceManager:ordinal_numbers(n)
	local ordinal, digit = {"st", "nd", "rd"}, string.sub(n, -1)
	if tonumber(digit) > 0 and tonumber(digit) <= 3 and tonumber(string.sub(n,-2)) ~= 11 and tonumber(string.sub(n,-2)) ~= 12 and tonumber(string.sub(n,-2)) ~= 13 then
		return n .. ordinal[tonumber(digit)]
	else
		return n .. "th"
	end

end

function raceManager:testRect( )
	--Draw full-screen black rectangle
	UiColor(0, 0, 0)
	UiRect(UiWidth(), UiHeight())

	--Draw smaller, red, rotating rectangle in center of screen
	UiPush()
		UiColor(1, 0, 0)
		UiTranslate(UiCenter(), UiMiddle())
		UiRotate(GetTime())
		UiAlign("center middle")
		UiRect(100, 100)
	UiPop()

end


function raceManager:setDisplayRange()
	if(self.displayRange == self.maxDisplayRange) then
		self.displayRange = self.defaultDisplayRange

	elseif (self.displayRange == self.defaultDisplayRange) then 
		self.displayRange = self.maxDisplayRange		
	end
end

-- if possible plot an ai drviers name and number above their car if within range
function raceManager:driverNameDisplay()
	local displayRange = self.defaultDisplayRange


	local uiScaleFactor = 0.6

	local rectScale = 30

	local colourW = 30
	local colourH = 30

	local namePlacardW = 170
	local namePlacardH = 30


	local letterSize = 11.8

	local maxDist = 0

	UiPush()
		-- UiAlign("top left")
		-- local w = 300
		-- local h = #self.positions*22 + 30
		-- UiTranslate(UiWidth()-w-20, 50)--UiHeight()-h-20 - 200) -- because I don't know how big the official vehicle UI will be
		-- UiColor(0,0,0,0.5)
		-- UiImageBox("ui/common/box-solid-6.png", w, h, 6, 6)
		-- UiTranslate(125, 32)
		-- UiColor(1,1,1)
		-- UiTranslate(-80, 0)

		pushVals = 0
		local Car = nil



		for Poskey,Posval in ipairs(self.positions) do
			val = self.racers[Posval.car]
			if(not PLAYERRACING or  ( 
				val.id ~= self.racers[playerConfig.car].id or not RACESTARTED or playerConfig.finished)) then 

				local vehicleTransform = GetVehicleTransform(val.id)

				local distToPlayer = VecLength(VecSub(vehicleTransform.pos,GetCameraTransform().pos))
				if(distToPlayer <= self.displayRange) then  

					vehicleTransform.pos =VecAdd(vehicleTransform.pos,Vec(0,val.bodyZSize /6,0)) --TransformToParentPoint(vehicleTransform,Vec(0,val.bodyZSize /4,0))
					-- local name = Vec((leadCar.bodyXSize/3)*camXPan,(leadCar.bodyZSize/3)*camYPan,(-leadCar.bodyYSize/3)*camZPan)
					-- camPos =  TransformToParentPoint(vehicleTransform,camPos)
					-- local camRot = QuatLookAt(camPos,vehicleTransform.pos)
			
					-- UiTranslate(UiCenter(), UiMiddle())
					UiPush()



						local x, y, dist = UiWorldToPixel(vehicleTransform.pos)
							
						if dist > 0 then

							local func = val.driverName
			
							if(not val.playerName and val.driverFName and val.driverSName) then
								-- DebugPrint(string.sub(self.racers[val.car].driverFName, 1, 1))
								func =   string.sub(val.driverFName, 1, 1).."."..val.driverSName


							elseif(val.playerName) then
								func = val.playerName
							end


							local driverNum = val.car

							UiTranslate(x, y)
							-- UiText("Label")
							-- UiTranslate(x, y)
							-- UiRotate(GetTime())
							UiAlign("left middle")

							UiScale((displayRange/distToPlayer)*uiScaleFactor, (displayRange/distToPlayer)*uiScaleFactor)
							UiColor(1,1,1,1)
							UiTranslate(-(colourW *2), 0)
							
							UiFont("bold.ttf", 46)--math.floor(10* (displayRange/distToPlayer)))
							--DebugPrint(string.len(tostring(Poskey)))
							UiTranslate(-colourW * string.len(tostring(Poskey)),0)
							UiText(Poskey)
							UiTranslate(colourW * string.len(tostring(Poskey)),0)
							UiAlign("left middle")
							UiTranslate((colourW *0.25), 0)
							
							
							UiColor(val.hudColour[1],val.hudColour[2],val.hudColour[3])
							
							
													
							UiImageBox("ui/common/box-solid-6.png", colourW , colourH, 6, 6)
							UiTranslate(colourW , 0)
							
							
							UiColor(0,0,0,0.5)
							UiImageBox("ui/common/box-solid-6.png", letterSize * string.len(func) , namePlacardH, 6, 6)

							UiTranslate(5, 0)
							UiColor(1,1,1)

							UiFont("MOD/fonts/nk57-monospace.bold.ttf", 18)

							UiText(func)
							UiTranslate(10, 0)

							-- UiRect(rectScale * (displayRange/distToPlayer), rectScale* (displayRange/distToPlayer))
						end	

					UiPop()
					-- local func = self.racers[val.car].driverName
					-- local driverNum = val.car
					-- UiFont("bold.ttf", 22)
					-- UiAlign("right")
					-- UiText(key)
					-- UiTranslate(10, 0)
					-- UiFont("regular.ttf", 22)
					-- UiAlign("left")			
					-- UiText(func)
					-- UiTranslate(160, 0)
					-- UiText("| "..driverNum)
					-- UiTranslate(30,0)
					-- UiText(" | "..self.racers[val.car].raceValues.laps)
					-- UiTranslate(-200, 22)
				end
			end
		end
	UiPop()




	-- local x, y, dist = UiWorldToPixel(point)
	-- if dist > 0 then
	-- 	UiTranslate(x, y)
	-- 	UiText("Label")
	-- end	

	-- body
end


function raceManager:drawIntro()
	UiPush()

		UiTranslate(0,0)
		UiTranslate(UiCenter(), UiHeight()*0.33)
		UiAlign("center")
		UiColor(0.9, 0.9, 0.9, 1)
		UiFont("bold.ttf", 64)
		if(map.name) then 
			UiText(map.name)
		else
			UiText("Löckelle: Skogs Entrada")
		end
		UiAlign(left)
		UiTranslate(-300,50)
		UiFont("regular.ttf", 24)
		UiWordWrap(600)
		local w, h
		local lines = {
			[1] = "Löckelle's oldest race track. In it's history, it been the site of 12 runnings of the Löckelle Grand Prix between 1964 and 1986 and currently hosts many regional and International racing events.",
			[2] = "Gordon Woo is said to have first raced on this track as a child, and has been a long term investor, saving it from closure after the incident of 1992...",
			[3] = "Today you will race the track and perhaps it may make your fame..."

		}
		if(map.lines) then
			lines = map.lines
		end
		for key,line in ipairs(lines) do 
			UiText(line)
			w, h = UiGetTextSize(line)
			UiTranslate(0,h*1.1)

		end
		-- local line0 = ""
		-- local line1 = "Löckelle's oldest race track. In it's history, it been the site of 12 runnings of the Löckelle Grand Prix between 1964 and 1986 and currently hosts many regional and International racing events."
		-- local line2 = "Gordon Woo is said to have first raced on this track as a child, and has been a long term investor, saving it from closure after the incident of 1992..."
		-- local line3 = "Today you will race the track and perhaps it may make your fame..."

		-- UiText(line1)
		-- local w, h = UiGetTextSize(line1)
		-- UiTranslate(0,h*1.1)

		-- UiText(line2)
		-- w, h = UiGetTextSize(line2)
		-- UiTranslate(0,h*1.1)

		-- UiText(line3)
		-- w, h = UiGetTextSize(line3)
		-- UiTranslate(0,h+1.1)

		-- UiText(line4)

		UiTranslate(300,h*2.2)
		UiAlign("center")
		UiText("PRESS SPACE / INTERACT TO CONTINUE")
	UiPop()

end


function raceManager:drawStart()
	UiPush()
		UiTranslate(UiWidth()/2, UiHeight()/2)
		UiAlign("center middle")
		UiScale(self.countdown % 1 * 10)
		UiFont("bold.ttf", 128)
		local alpha = self.countdown % 1
		UiColor(1,0,0, alpha)
		UiTextShadow(0,0,0,alpha/2,2)
		if math.floor(self.countdown) > 0 then
			UiText(math.floor(self.countdown))
		else
			UiText("DRIVE!")
		end
	UiPop()
end


function raceManager:raceStats()
	UiPush()



	UiPop()
end


function raceManager:playerRaceStats(vehicle)
	local offset = {x = 100, y = 70}
	local textSize = 64
	local infoTextSize = 24
	local offsetCoef = 2

	UiPush()
		UiTranslate(offset.x*0.5,offset.y)

		self:displayPlayerPos()

		UiTranslate(offset.x*offsetCoef,0)

		UiAlign("center middle")
		UiFont("bold.ttf", textSize )

		--- draw current player laps
		UiText("Lap" )
		UiTranslate(offset.x*(offsetCoef*0.5),0)
		UiFont("bold.ttf",textSize)
		UiText((aiVehicles[playerConfig.car].raceValues.laps+1).."/"..self.laps+1 )

		UiTranslate(-offset.x*offsetCoef,textSize*0.5)
		--- draw current player race time, lap time, best lap
		raceManager:drawPlayerLaptimeInfo(vehicle, playerConfig.hudInfo.lapInfo,infoTextSize)

	UiPop()
end

function raceManager:drawPlayerLaptimeInfo(vehicle, cfg,textSize)
	local time = 0
	local yOffset = 30
	local xOffset = 0
	UiFont(self.font, textSize )

	UiTranslate(0,textSize)
	for key,val in ipairs(cfg) do

		time = val.time
		if(val.name == "Lap" and val.time ==0) then
			time = self:lapTime()
		elseif(val.name == "Lap") then 
			time = self:lapTime() - vehicle.raceValues.lastLap 

		else 
			time =  self:lapTime() - val.time
		end

		if(val.name =="Race" and RACEENDED) then 
			time =  vehicle.raceValues.lastLap 
		end

		if(val.name == "Best" and val.time ==0) then
			time = "--:--.--" 
		elseif(val.name=="Best") then
			time =	self:formatTime(playerConfig.bestLap)

		else
			time =	self:formatTime(time)
		end


		UiAlign("right middle")
		UiText(val.name.."|")

		UiTranslate(xOffset,0)




		UiAlign("left middle")

		UiText(time)
		UiTranslate(-xOffset,textSize)
	end
end



function raceManager:endScreen(vehicle)
	local offset = {x = 200,y = UiHeight()/3}
	local textSize = 128
	local infoTextSize = 64
	local offsetCoef = 2
	UiPush()
		UiTranslate(UiCenter(),UiMiddle()-offset.y)

		self:displayPlayerPos(textSize)

		UiTranslate(0,textSize)

		--[[

			Draw previous best time and inform player if new best lap is better


			[3] = {
				name = "Best",
				time = 0,
			},
		]]



		endGameInfo = {
			[1] =  deepcopy(playerConfig.hudInfo.lapInfo[1]),
			[2] =  deepcopy(playerConfig.hudInfo.lapInfo[3]),

		}



		local recordText = "Record Time : "
		local recordTime = savedBest
		UiFont(self.font, infoTextSize )

		if(not PLAYER_TOTALED and  playerConfig.finalTime < savedBest)then
			UiAlign("center middle")
			UiText("New Record Set!!")
			recordText = "Previous Record"
			-- recordTime = playerConfig.finalTime

			UiTranslate(0,infoTextSize) 

		end

		if(savedBest ~= DEFAULTRACETIME) then
			recordTime = self:formatTime(recordTime)
		else
			recordTime = "--:--.--" 
		end
		UiAlign("right middle")
		UiText(recordText.."|")
		UiAlign("left middle")
		UiText(recordTime)
		UiTranslate(0,infoTextSize)


		raceManager:drawPlayerLaptimeInfo(vehicle, endGameInfo,infoTextSize)
--		UiTranslate(UiCenter(),UiMiddle())

		UiTranslate(0,infoTextSize)
		UiAlign("center middle")
		UiFont(self.font, infoTextSize )
		UiText("Press Space/interact to return to menu")
		if(InputPressed("space") or InputPressed("interact")) then
			StartLevel("main_menu", "MOD/main.xml")
		end

	UiPop()
end