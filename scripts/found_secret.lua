


function init()
	trophy = FindShape("secret_trophy")



end




function tick(dt)



	if(GetPlayerInteractShape(trophy)) then
		SetBool("savegame.mod.special_trophy",true)
		
	end


end