local Width, Height = guiGetScreenSize()

local Positions = {Width-10-330, 8}

local Health, Armour, Oxygen, CarHP = 0, 0, 0, 0
local R, G, B = 0, 177, 37

--[[local Weapons = {"fist", "knuckle", "golf", "nights", "knife", "bat", "shovel", "cue", "katana", "chainsaw", 
	"pistol", "silenced", 
	"shotgun", "combat", 
	"machg", "tec",
	"ak", "m4",
	"rocketla", ""}]]

local AmmoPos = {8, 19}
local CarpPos = {18, 19}

local font = dxCreateFont("opensanslight.ttf", 12)

local customHUDEnabled = false

function enableCustomHUD()
	customHUDEnabled = not customHUDEnabled
	setPlayerHudComponentVisible("ammo", not customHUDEnabled)
	setPlayerHudComponentVisible("health", not customHUDEnabled)
	setPlayerHudComponentVisible("armour", not customHUDEnabled)
	setPlayerHudComponentVisible("breath", not customHUDEnabled)
	setPlayerHudComponentVisible("clock", not customHUDEnabled)	
	setPlayerHudComponentVisible("money", not customHUDEnabled)
	setPlayerHudComponentVisible("weapon", not customHUDEnabled)
	setPlayerHudComponentVisible("vehicle_name", not customHUDEnabled)
	setPlayerHudComponentVisible("area_name", not customHUDEnabled)
end

addCommandHandler("customhud", enableCustomHUD)
enableCustomHUD()

addEventHandler("onClientRender", root, function()
	if not customHUDEnabled then return false end
	Health, Armour, Oxygen = localPlayer.health, localPlayer.armor, localPlayer.oxygenLevel
	if Health > 100 then Health = 100 end
	if Armour > 100 then Armour = 100 end
	if Oxygen > 1000 then Oxygen = 1000 end

	dxDrawImage(Positions[1], Positions[2], 330, 54, "Elements/round.png") --Central Round for infobar

	--dxDrawImage(Positions[1]+10, Positions[2]+9, 36, 36, "Elements/weaps/rocketla.png")

	--Health Bar	
	dxDrawImage(Positions[1], Positions[2], 330, 54, "Elements/healthbar.png")
	--Armour/Oxygen Bar
	if (Armour > 0) or (isElInWater(localPlayer) and Armour <= 0) then dxDrawImage(Positions[1], Positions[2], 330, 54, "Elements/armorbar.png") end
	--Oxygen Bat
	if isElInWater(localPlayer) and Armour > 0 then 
		dxDrawImage(Positions[1], Positions[2], 330, 54, "Elements/oxybar.png") 
	end

	--Health level
	dxDrawImageSection(
			Positions[1]+4+(279-(Health*2.79)), Positions[2]+21, 		Health*2.79, 3,  --Тут творится полнейший песдес, добился сия методом подбора координат, и хз, что тут происходит.
			279-(Health*2.79), 0, 		Health*2.79, 3, 
			"Elements/health.png",
			0, 0, 0,
			tocolor(255, 0, 0))

	--Oxygen level
	if isElInWater(localPlayer) and Armour > 0 then 
		dxDrawImageSection(
			Positions[1]+174+(115-(Oxygen*0.115)), Positions[2]+39, 		Oxygen*0.115, 3, 
			115-(Oxygen*0.115), 0, 		Oxygen*0.115, 3, 
			"Elements/oxygen.png",
			0, 0, 0,
			tocolor(0, 132, 255)) 
	end
	--Armour/Oxygen level
	if (Armour > 0) or (isElInWater(localPlayer) and Armour <= 0) then
		if Armour <= 0 then Armour, R, G, B = Oxygen/10, 0, 132, 255 
		else R, G, B = 0, 177, 37 end 
		dxDrawImageSection(
			Positions[1]+43+(240-(Armour*2.4)), Positions[2]+30, 		Armour*2.4, 3, 
			240-(Armour*2.4), 0, 		Armour*2.4, 3, 
			"Elements/armour.png",
			0, 0, 0,
			tocolor(R, G, B)) 
	end

	--Time
	local h, m = getTime()
	dxDrawImage(Width-130, Positions[2]+56, 120, 40, "Elements/panel.png")
	dxDrawText(string.format("%i:%.2i", h, m), Width-130, Positions[2]+56, Width-10, Positions[2]+56+40, _, 1, font, "center", "center", true)
	dxDrawText(string.format("%i:%.2i", h, m), Width-130, Positions[2]+56, Width-10, Positions[2]+56+40, _, 1, font, "center", "center", true)

	--Money
	dxDrawText(string.format("$%.8i", getPlayerMoney(localPlayer)), Positions[1], 0, Positions[1]+276, 28, 
		_, 1, font, "right", "center", true)

	--Ammo
	if isPlayerAmmoWeapon(localPlayer) then
		AmmoPos[2] = getPedAmmoInClip(localPlayer)*(19/getWeaponProperty(getPedWeapon(localPlayer), getPedWeaponSkill(localPlayer, getPedWeapon(localPlayer)), "maximum_clip_ammo"))
		AmmoPos[1] = 8+(19-AmmoPos[2])
		dxDrawImage(Positions[1]+AmmoPos[1]+276, Positions[2]+AmmoPos[1], 2*AmmoPos[2], 2*AmmoPos[2], "Elements/ammoround.png")
		dxDrawImage(Width-250, Positions[2]+56, 120, 40, "Elements/panel.png")
		dxDrawText(getPedAmmoInClip(localPlayer).."/"..getPedTotalAmmo(localPlayer)-getPedAmmoInClip(localPlayer), 
			Width-250, Positions[2]+56, Width-130, Positions[2]+56+40, _, 1, font, "center", "center", true)
	end



	if localPlayer.inVehicle then
		--Car Health
		CarHP = localPlayer.vehicle.health or 1000
		if CarHP > 1000 then CarHP = 1000 end
		dxDrawImage(10, Height-62, 330, 54, "Elements/vehicle/vehicle.png")
		dxDrawImage(10, Height-62, 330, 54, "Elements/vehicle/carhpbar.png")
		dxDrawText(getVehicleName(localPlayer.vehicle), 62, Height-67, 330, Height-27, _, 1, font, "left", "center", true)
		dxDrawImageSection(
			57, Height-32, CarHP*0.24, 3, 
			0, 0, CarHP*0.24, 3, 
			"Elements/vehicle/carhp.png",
			0, 0, 0,
			tocolor(255, 80, 80))

		--Nitro
		local nitro = getVehicleNitroLevel(localPlayer.vehicle)
		if nitro and nitro > 0 then
			dxDrawImage(10, Height-62, 330, 54, "Elements/vehicle/nitrobar.png")
			dxDrawImageSection(
				51, Height-23, nitro*115, 3, 
				0, 0, nitro*115, 3, 
				"Elements/vehicle/nitro.png",
				0, 0, 0,
				tocolor(70, 70, 220))
		end


		--Speedometr
		local speed = around(getElementSpeed(localPlayer.vehicle), 0)

		dxDrawImage(300, Height-53, 120, 40, "Elements/panel.png")
		dxDrawText(speed.." KM/H", 300, Height-53, 420, Height-13, _, 1, font, "center", "center", true)

		if speed > 120 then speed = 120 end
		CarpPos[2] = speed*(19/120)
		CarpPos[1] = 18+(19-CarpPos[2])
		dxDrawImage(CarpPos[1], (Height-72)+CarpPos[1], 2*CarpPos[2], 2*CarpPos[2], "Elements/ammoround.png")

	end
	
	--Location
	local x, y, z = getElementPosition(localPlayer or localPlayer.vehicle)
	dxDrawText(getZoneName(x, y, z, true), Width-300, Height-63, Width-2, Height-43, _, 1, font, "right", "center", true)
	dxDrawText(getZoneName(x, y, z), Width-300, Height-43, Width-2, Height-23, _, 1, font, "right", "center", true)

end)

function isElInWater(player) return (player.inVehicle == true and player.vehicle or player).inWater end

function getPedWeaponSkill(player, id)
	if id == 22 then id = 69
	elseif id == 23 then id = 70
	elseif id == 24 then id = 71
	elseif id == 25 then id = 72
	elseif id == 26 then id = 73
	elseif id == 27 then id = 74
	elseif id == 28 then id = 75
	elseif id == 29 then id = 76
	elseif id == 32 then id = 75
	elseif id == 30 then id = 77
	elseif id == 31 then id = 78
	elseif id == 34 then id = 79 
	else return "poor" end
	
	local s = getPedStat(player, id)
	if s == 0 then return "poor"
	elseif s == 999 then return "pro"
	else return "std" end
end

--local ammweaps = {16, 17, 18, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 41, 42, 43}
function isPlayerAmmoWeapon(player)
	local w = getPedWeapon(player)

	if w == 16 or w == 17 or w == 18 or w == 22 or w == 23 or 
		w == 24 or w == 25 or w == 26 or w == 27 or w == 28 or w == 29 or
		w == 30 or w == 31 or w == 32 or w == 33 or w == 34 or w == 35 or 
		w == 36 or w == 37 or w == 39 or w == 41 or w == 42 or w == 43 
			then return true
	else return false end
	 
end

function getElementSpeed(element, k)
	local speedx, speedy, speedz = getElementVelocity(element)
	local actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5) 
	if k == "kmh" or k == nil or k == 1 then return around(actualspeed * 180, 5)
	elseif k == "mps" or k == 2 then return around(actualspeed * 50, 5)
	elseif k == "mph" or k == 3 then return around(actualspeed * 111.847, 5) end
end

function around(fst, snd)
     local mid = math.pow(10,snd)
     return math.floor((fst*mid)+0.5)/mid
end