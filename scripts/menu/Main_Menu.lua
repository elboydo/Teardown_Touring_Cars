
#include "../trackDescriptions.lua"



selectedMap = nil
selected_map_num = nil
STOP_THE_MUSIC = true
selected_mode = nil
selected_car = nil


ui_font_s = 24
ui_font_m = 40
ui_font_l = 60


function init()

	camPos = FindLocation('camPos',true)

	mapNames = {
		[1] = "caveisland",
		[2] = "frustrum",
		[3] = "lee",
		[4] = "mansion",
		[5] = "marina",
	}

	menu_music = mapNames[math.random(1,#mapNames)].."-hunted.ogg"

	STOP_THE_MUSIC = GetBool("savegame.mod.play_menu_music")

end

function getMapInfo(raceMap)
	--- set custom track values
	local map = {}
	if(trackDescriptions[raceMap]) then
		map.name = trackDescriptions[raceMap].name
		map.lines = deepcopy(trackDescriptions[raceMap].lines)
		raceManager.laps = trackDescriptions[raceMap].trackLaps
		if(trackDescriptions[raceMap].grid ) then
			mapSize.grid =  trackDescriptions[raceMap].grid
		end
		if(trackDescriptions[raceMap].completionRange ) then
			ai.raceValues.completionRange =  trackDescriptions[raceMap].completionRange 
		end
	else
		raceMap = "teardownRacing"

		map.validMaterials = deepcopy(trackDescriptions[raceMap].validMaterials)
		map.name = trackDescriptions[raceMap].name
		map.lines = deepcopy(trackDescriptions[raceMap].lines)
		raceManager.laps = trackDescriptions[raceMap].trackLaps
	end

	return map

end

function tick(dt)

	-- DebugWatch('selectedMap', selectedMap)

	-- if(GetTime()<5) then 
	if(not STOP_THE_MUSIC)then 
		PlayMusic(menu_music)
	else
		StopMusic()
	end
--	DebugWatch("Camera valid:",	IsHandleValid(camPos))
--	DebugWatch("Camera pos:",	camPos)
	SetCameraTransform(GetLocationTransform(camPos))

end

function draw()

	window_width = UiWidth()
	window_height =  UiHeight()
	UiMakeInteractive()
	UiModalBegin()

	uiDrawBackground()
	uiDrawTitle()
	uiDrawMusicButtons()
	uiDrawExitButton()

	do UiPush()
		UiTranslate(0, 300)
		draw_menu()
	UiPop() end

	UiModalEnd()
end


function draw_menu()

	local window_width = UiWidth()
	local window_height = UiHeight()

	maxMenuItems = 6

	tracks = {
		"moriSawa",
		"BlueTideRing",
		"skogsEntrada",
		"Norrbotten_raceway"
	}

	UiFont("regular.ttf", 32)

	local w,h = nil 
	for i=1,#tracks do 
		line = trackDescriptions[tracks[i]].name 
		l_w, l_h = UiGetTextSize(line)
		if(w == nil or l_w>w)then 
			w=l_w
			h = l_h
		end
	end

	-- Draw track names.
	do UiPush()
		UiTranslate(window_width/30, 0)
		UiFont("bold.ttf", ui_font_l)
		UiText('Race Tracks:')
	UiPop() end

	do UiPush()

		UiTranslate(window_width/30, 0)

		for i = 1,#tracks do
			if(selected_map_num == i ) then 
				UiButtonImageBox("ui/common/box-outline-fill-6.png", 3, 3)
			else
				UiButtonImageBox("ui/common/box-outline-6.png", 3, 3,0,0,0,0)
			end

			UiTranslate(0, 56)

			UiPush()

				UiAlign('left middle')
				if UiTextButton(trackDescriptions[tracks[i]].name, w*1.5, h*1.5) then
					--DebugPrint("track: "..trackDescriptions[tracks[i]].name)
					selectedMap = tracks[i]
					selected_map_num = i
					selected_car = nil	
					selected_mode = nil
					selected_map_image = 'MOD/images/tracks/'..selectedMap..'.png'
					--DebugPrint("chosen map"..selectedMap)
					--DebugPrint("l")
				end
			UiPop()
		end
	UiPop() end

	if(selectedMap) then

		draw_selected_track()

		do UiPush()
			UiTranslate(UiCenter(), UiMiddle() + 200)
			UiAlign("center")
			line = "Start Race!"
			l_w, l_h = UiGetTextSize(line)
			UiButtonImageBox("ui/common/box-outline-6.png", 3, 3)
			UiButtonHoverColor(0, 0, 1)
			if UiTextButton(line, w*1.5, h*1.5) then
				start_race()
			end
		UiPop() end

	end

end

function draw_selected_track()

	local window_width = UiWidth()
	local window_height =  UiHeight()

	if(selectedMap) then 
		map = trackDescriptions[selectedMap]

		if(map.lines) then
			lines = map.lines
		end
		-- for key,line in ipairs(lines) do 
		-- 	UiText(line)
		-- 	w, h = UiGetTextSize(line)
		-- 	UiTranslate(0,h*1.1)
		-- --	DebugPrint(line)
		-- end

		-- Layout
		do UiPush()

			UiTranslate(window_width/30, UiHeight()*0.41)

			UiAlign("left")
			UiColor(0.9, 0.9, 0.9, 1)
			UiFont("bold.ttf", ui_font_l)
			t_text = "Layout:"
			UiText(t_text)
			UiAlign("left")
			w, h = UiGetTextSize(t_text)
			UiTranslate(0,50)
			UiFont("regular.ttf", ui_font_s)
			UiWordWrap(500)
			local w, h
			local modes = {
				[1] = "base Car"
			}
			if(map.modes) then
				modes = map.modes
			end
			local w,h = nil 
			for key,mode in ipairs(modes) do 
				line = mode.name 
				l_w, l_h = UiGetTextSize(line)
				if(w == nil or l_w>w)then 
					w=l_w
					h = l_h
				end
			end

			for key,mode in ipairs(modes) do
				if(selected_mode == mode.id or (selected_mode == nil and key ==1)) then 
					UiButtonImageBox("ui/common/box-outline-fill-6.png", 3, 3)
				else
					UiButtonImageBox("ui/common/box-outline-6.png", 3, 3)
				end
				line = mode.name 
				if UiTextButton(line, w*1.5, h*1.5) then
					selected_mode = mode.id
				end	
				UiTranslate(0,h*2.1)

			end
		UiPop() end

		-- Track Desc
		do UiPush()

			local ww = 500
			UiTranslate(UiWidth()*0.37, 0)

			do UiPush()
				UiAlign("center")
				UiTranslate(ww/2,0)
				UiImageBox(selected_map_image, ww, ww*0.6, 1, 1)
			UiPop() end

			UiTranslate(0, ww*0.7)

			UiColor(0.9, 0.9, 0.9, 1)
			UiFont("bold.ttf", 48)
			if(map.name) then 
				do UiPush()
				UiTranslate(ww/2,0)
				UiAlign("center")
				UiText(map.name)
				UiPop() end
			else
				UiText("Unknown map")
			end

			UiAlign("left")
			UiTranslate(0,50)
			UiFont("regular.ttf", ui_font_s)
			UiWordWrap(ww)

			local w, h
			local lines = {
				[1] = "well this will be fun!",
				[2] = "god speed...",
				[3] = "We are rooting for you!!"

			}
			if(map.lines) then
				lines = map.lines
			end
			for key,line in ipairs(lines) do 
				UiText(line)
				w, h = UiGetTextSize(line)
				UiTranslate(0,h*1.1)

			end
		UiPop() end

		-- Cars, Start
		do UiPush()

			-- UiTranslate(UiWidth() - (UiWidth()/6), UiHeight()*0.33)
			UiTranslate(UiWidth() * 0.79, 0)
			UiAlign("left")
			UiColor(0.9, 0.9, 0.9, 1)
			UiFont("bold.ttf", ui_font_l)
			t_text = "Cars:"
			UiText(t_text)

			UiAlign("left")
			w, h = UiGetTextSize(t_text)
			-- UiTranslate(-w/2,50)
			UiFont("regular.ttf", ui_font_s)
			UiWordWrap(500)

			UiTranslate(0,50)


			local valid_cars = {
				[1] = {name = "base Car", id = "base"}
			}
			if(map.valid_cars) then
				valid_cars = map.valid_cars
			end
			w,h = nil 
			for key,car in ipairs(valid_cars) do 
				line = car.name
				l_w, l_h = UiGetTextSize(line)
				if(w == nil or l_w>w)then 
					w=l_w
					h = l_h
				end
			end
			for key,car in ipairs(valid_cars) do 
				if(selected_car == car.id or (selected_car == nil and key ==1)) then 

					UiButtonImageBox("ui/common/box-outline-fill-6.png", 3, 3)
				else
					UiButtonImageBox("ui/common/box-outline-6.png", 3, 3)
				end
				line = car.name
				if(car.unlocked or GetBool("savegame.mod.special_trophy") ==true) then 
					if UiTextButton(line, w*1.5, h*1.5) then
						selected_car = car.id
					end	
				else
					UiTextButton("Locked", w*1.5, h*1.5)
				end
				UiTranslate(0,h*2.1)
			end
		UiPop() end


	end


end

function draw_player_name(window_width,window_height)
	UiFont("bold.ttf", 26)
	t_text = "Player Name: "
	UiText(t_text)
	local w, h = UiGetTextSize(t_text)
	UiTranslate(w*2,0)

	player_name = "test"
end

function draw_music_options(window_width,window_height)
	UiTranslate(window_width/30,20)
		-- UiAlign("center top")
	-- UiTranslate(UiCenter(), 50)
	UiFont("bold.ttf", 20)
	t_text = "player Name: "
	local w, h = UiGetTextSize(t_text)
	UiTranslate(0,30)


	line = "Menu music: "
	l_w, l_h = UiGetTextSize(line)
	UiText(line)
	UiTranslate(w*1.5,0)
	UiButtonImageBox("ui/common/box-outline-6.png", 3, 3)
	UiButtonHoverColor(0, 0, 1)


	local menu_music_state = "Enabled"

	-- DebugWatch("menu registry music: ",GetBool("savegame.mod.play_menu_music"))
	-- DebugWatch("menu music: ",STOP_THE_MUSIC)
	if(GetBool("savegame.mod.play_menu_music")) then
		menu_music_state = "Disabled"
	end

	l_w, l_h = UiGetTextSize(menu_music_state)
	if UiTextButton(menu_music_state, l_w*1.5,l_h*1.5) then

		SetBool("savegame.mod.play_menu_music", not GetBool("savegame.mod.play_menu_music"))
		STOP_THE_MUSIC = GetBool("savegame.mod.play_menu_music")
	end	
	UiTranslate(-w*1.5,h*2)


	line = "Race music: "
	l_w, l_h = UiGetTextSize(line)
	UiText(line)
	UiTranslate(w*1.5,0)
	UiButtonImageBox("ui/common/box-outline-6.png", 3, 3)
	UiButtonHoverColor(0, 0, 1)


	local race_music_state = "Enabled"

	if(GetBool("savegame.mod.play_race_music")) then
		race_music_state = "Disabled"
	end

	l_w, l_h = UiGetTextSize(race_music_state)
	if UiTextButton(race_music_state, l_w*1.5,l_h*1.5) then
		SetBool("savegame.mod.play_race_music", not GetBool("savegame.mod.play_race_music"))
	end	
	

end

function start_race()
	local map = trackDescriptions[selectedMap]
	if(selected_mode == nil) then 
		selected_mode = map.modes[1].id
	end
	if(selected_car == nil) then 
		selected_car = map.valid_cars[1].id
	end
	weather=""
	if(selected_car == "ai3_bangers" and math.random()>0.9) then 
		weather = " rain"
	end

	StartLevel("race", "MOD/"..selectedMap..".xml", "ai3".." "..selected_mode.." "..selected_car.." playerState"..weather)

end


-- ui functions

function uiDrawBackground()
	--- draw menu background
	do UiPush()
		UiColor(0.29, 0.45, 0.36)
		UiRect(window_width,window_height)
	UiPop() end
end

function uiDrawMusicButtons()

	do UiPush()
		draw_music_options(window_width,window_height)
	UiPop() end

end

function uiDrawExitButton()

	-- DebugWatch("selected map: ",selectedMap)

	do UiPush()

		--Draw buttons
		UiTranslate(window_width-20, 20)
		UiFont("regular.ttf", 32)
		UiAlign('right top')
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)

		if UiTextButton("Exit", 200, 40) then
			Menu()
		end

	UiPop() end
end

function uiDrawTitle()
	do UiPush()

		UiTranslate(UiCenter(), 20)
		UiAlign("center top")
		UiFont("bold.ttf", 72)
		UiText("Teardown Touring Cars")

		UiTranslate(0, 80)
		draw_player_name(window_width,window_height)

	UiPop() end
end