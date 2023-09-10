--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        TrackDescriptions.lua             
*
* DESCRIPTION :
*       File that holds all track descriptions and behaviors
*		

*
* NOTES :
*       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
* 							 Release Date :    29 Nov 2021 
*
]]

trackDescriptions = {

	teardownRacing = {
			name = "Teardown Touring Cars",
					lines = {
							[1] = [[Teardown Touring Cars is the latest series of 
							high octane entertainment, powered by elboydos AVF_AI]],
							
							[2] = [[Cars will be able to race at high speed around almost any given track 
							]],
							[3] = [[HAVE FUN! :)]],
							},

					trackLaps = 3,



	  validMaterials = {
	  	[1] = {	
	  		material = "masonry",


		  validSurfaceColours ={ 
					[1] = {
						r = 0.20,
						g = 0.20,
						b = 0.20,
						range = 0.02
					},
					[2] = {
						r = 0.80,
						g = 0.60,
						b = 0.60,
						range = 0.02
					},
					[3] = {
						r = 0.34,
						g = 0.34,
						b = 0.34,
						range = 0.02
					},
				},
			},
		},

	},

	figureEight = {
			name = "Lockelle Speedway",
					lines = {
							[1] = [[Lockelles finest crash filled figure 8 speedway!, powered by elboydos AVF_AI]],
							
							[2] = [[Cars will be able to race at high speed around almost any given track 
							]],
							[3] = [[HAVE FUN! :)]],
							},

					trackLaps = 6,
			grid = 5,

	  validMaterials = {
	  	[1] = {	
	  		material = "masonry",


		  validSurfaceColours ={ 
					[1] = {
						r = 0.20,
						g = 0.20,
						b = 0.20,
						range = 0.02
					},
					[2] = {
						r = 0.80,
						g = 0.60,
						b = 0.60,
						range = 0.02
					},
					[3] = {
						r = 0.34,
						g = 0.34,
						b = 0.34,
						range = 0.02
					},
				},
			},
		},

	},


	Norrbotten_raceway = {
			name = "Norrbotten Hills Raceway",
					lines = {
							[1] = [[
								Norrbotten Hills Raceway has over 50 years of motorsport history
								 and is the fastest quarter-mile oval in Europe,
							]],
							
							[2] = [[With the speeds many cars achieve around its fearsome steeply banked turns really having to be seen to be believed!  
							]],
							},

					valid_cars = {
						[1] = {name = "Bangers", id="ai3_bangers", unlocked=true},
						[2] = {name = "Sprint Cars ", id="ai3_sprintCar", unlocked=true},
						[3] = {name = "Blue Tide BT9", id="ai3_f1", unlocked=true},
						[4] = {name = "Crownzygot XVC-alpha",id="ai3_raceCar",unlocked=true},
						[5] = {name = "Eurus IV XXF",id="ai3_sportsCar",unlocked=true},
						[6] = {name = "Bulletproof Bomb",id="ai3_wacky", unlocked=false,condition={[1]="indy_1_2"}},
						[7] = {name = "Super Emil Racer", id= "ai3_emil", unlocked=false, condition = {[1]="f1_1_2",[2]="indy_1_2"}},
					},


					modes = {
						[1] = {name = "Oval Circuit", id="oval"},

					},


					trackLaps = 4,
			grid = 2,
			completionRange = 13,

	  validMaterials = {
	  	[1] = {	
	  		material = "masonry",


		  validSurfaceColours ={ 
					[1] = {
						r = 0.20,
						g = 0.20,
						b = 0.20,
						range = 0.02
					},
					[2] = {
						r = 0.80,
						g = 0.60,
						b = 0.60,
						range = 0.02
					},
					[3] = {
						r = 0.34,
						g = 0.34,
						b = 0.34,
						range = 0.02
					},
				},
			},
		},

	},

	skogsEntrada = {
					name = "Löckelle: Skogs Entrada",
					lines = {
							[1] = "Löckelle's oldest race track. In it's history, it been the site of 12 runnings of the Löckelle Grand Prix between 1964 and 1986 and currently hosts many regional and International racing events.",
							[2] = "Gordon Woo is said to have first raced on this track as a child, and has been a long term investor, saving it from closure after the incident of 1992...",
							[3] = "Today you will race the track and perhaps it may make your fame..."
							},



					valid_cars = {
						[1] = {name = "Blue Tide BT9", id="ai3_f1", unlocked=true},
						[2] = {name = "Crownzygot XVC-alpha",id="ai3_raceCar",unlocked=true},
						[3] = {name = "Eurus IV XXF",id="ai3_sportsCar",unlocked=true},
						[4] = {name = "Bangers", id="ai3_bangers", unlocked=true},
						[5] = {name = "Bulletproof Bomb",id="ai3_wacky", unlocked=true,condition={[1]="indy_1_2"}},
						[6] = {name = "Super Emil Racer", id= "ai3_emil", unlocked=false, condition = {[1]="f1_1_2",[2]="indy_1_2"}},
					},


					modes = {
						[1] = {name = "F1", id="f1"},
						[2] = {name = "Indy Car", id="indyCircuit"}

					},

					trackLaps = 4,

					validMaterials = {
						[1] = {	
							material = "masonry",


					  validSurfaceColours ={ 
								[1] = {
									r = 0.20,
									g = 0.20,
									b = 0.20,
									range = 0.02
								},	
								[2] = {
									r = 0.80,
									g = 0.60,
									b = 0.60,
									range = 0.02
								},
								[3] = {
									r = 0.34,
									g = 0.34,
									b = 0.34,
									range = 0.02
								},
							},
						},
					},

	},




	BlueTideRing = {
					name = "Löckelle: Blue Tide Ring",
					lines = {
							[1] = [[Created By Blue Tide as a means to build cars capable of defeating Gordon Woo]],
							[2] = [[This has been the founding of many promising young drivers, the Central Narwell considered a symbol of great luck]],
							[3] = [[Filled with many tight corners and fast straights, "At that speed, it's so dangerous man!"]]
							},

					grid = 4,

					completionRange = 5,

					trackLaps = 4,



					valid_cars = {
						[1] = {name = "Blue Tide BT9", id="ai3_f1", unlocked=true},
						[2] = {name = "Crownzygot XVC-alpha",id="ai3_raceCar",unlocked=true},
						[3] = {name = "Eurus IV XXF",id="ai3_sportsCar",unlocked=true},
						[4] = {name = "Bangers", id="ai3_bangers", unlocked=true},
						[5] = {name = "Bulletproof Bomb",id="ai3_wacky", unlocked=false,condition={[1]="indy_1_2"}},
						[6] = {name = "Super Emil Racer", id= "ai3_emil", unlocked=false, condition = {[1]="f1_1_2",[2]="indy_1_2"}},
					},
					modes = {
						[1] = {name = "F1", id="f1"},
						[2] = {name = "Indy Car", id="indyCircuit"}

					},


					validMaterials = {
						[1] = {	
							material = "masonry",


					  validSurfaceColours ={ 
								[1] = {
									r = 0.20,
									g = 0.20,
									b = 0.20,
									range = 0.02
								},	
								[2] = {
									r = 0.80,
									g = 0.60,
									b = 0.60,
									range = 0.02
								},
								[3] = {
									r = 0.34,
									g = 0.34,
									b = 0.34,
									range = 0.02
								},
							},
						},
					},

	},

	korsikanskElv = {
		name = "Korsikansk Elv"



	},

	korpikselvanBellopete = {
		name = "Korpikselvan bellopete "

	},

	kullgruveKanal = {
		name = "Kullgruve Kanál"
	},
	--- thank you mr floppy jack
	usfvenChauffuse = {
		name = "Usfven Chauffuse"

	} ,

	moriSawa = {
		name = "Mori Sawa",
					lines = {
							[1] = [[Founded in an old Lockelle Army airstrip, Motorsport has found a new home ]],
							[2] = [[With a large stipend from BlueTide Corperation, this year lockelle welcomes the rallycross world tour]],
							[3] = [[We hope you've tested your suspension, as things are about to get bumpy!]]
							},



					trackLaps = 4,

					valid_cars = {
						[1] = {name = "Rally Cross (mixed)", id="rallycross",unlocked=true},
					},
					modes = {
						[1] = {name="RallyCross", id = "rallycross"},

					},
					
					validMaterials = {
						[1] = {	
							material = "masonry",


					  validSurfaceColours ={ 
								[1] = {
									r = 0.20,
									g = 0.20,
									b = 0.20,
									range = 0.02
								},	
								[2] = {
									r = 0.80,
									g = 0.60,
									b = 0.60,
									range = 0.02
								},
								[3] = {
									r = 0.34,
									g = 0.34,
									b = 0.34,
									range = 0.02
								},
								[4] = {
									r = 0.30,
									g = 0.30,
									b = 0.30,
									range = 0.02
								},
							},
						},
						[2] = {	
							material = "dirt",


					  validSurfaceColours ={ 
								[1] = {
									r = 0.66,
									g = 0.56,
									b = 0.42,
									range = 0.02
								},	
							},
						},
					},

	}


} 


unlockConditions = {

	indy_1_2 = {
		info = "Beat the indy car world record on Skogs entrada and Blue tide ring",
		maps = {
			[1] = "skogsEntrada",
			[2] = "BlueTideRing",

		}
	},

	f1_1_2 = {
		info = "Beat the f1 world record on Skogs entrada and Blue tide ring",
		maps = {
			[1] = "skogsEntrada",
			[2] = "BlueTideRing",

		}
		
	}

}