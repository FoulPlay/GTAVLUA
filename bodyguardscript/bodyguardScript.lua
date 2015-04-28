--[[
Bodyguard Script by Foul Play. This is WIP so there will be bugs. Version 4
]]

--[[
Changelog:
1: First Test Version.
2: Fixed errors.
3: Fixed more errors.
4: Moved some stuff out of the BodyguardScript table to local variables. 
Removed 3 functions and moved their contents to the tick function.
Renamed some variables, fixed some errors and moved the variables to tick function
]]

--[["WEAPON_KNIFE", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_BAT", "WEAPON_GOLFCLUB", "WEAPON_CROWBAR",
	"WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50", "WEAPON_MICROSMG", "WEAPON_SMG",
	"WEAPON_ASSAULTSMG", "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG",
	"WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN", "WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN",
	"WEAPON_STUNGUN", "WEAPON_SNIPERRIFLE", "WEAPON_HEAVYSNIPER", "WEAPON_GRENADELAUNCHER", "WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG", "WEAPON_MINIGUN", "WEAPON_GRENADE", "WEAPON_STICKYBOMB", "WEAPON_SMOKEGRENADE", "WEAPON_BZGAS",
	"WEAPON_MOLOTOV", "WEAPON_FIREEXTINGUISHER", "WEAPON_PETROLCAN",
	"WEAPON_SNSPISTOL", "WEAPON_SPECIALCARBINE", "WEAPON_HEAVYPISTOL", "WEAPON_BULLPUPRIFLE", "WEAPON_HOMINGLAUNCHER",
	"WEAPON_PROXMINE", "WEAPON_SNOWBALL", "WEAPON_VINTAGEPISTOL", "WEAPON_DAGGER", "WEAPON_FIREWORK", "WEAPON_MUSKET",
	"WEAPON_MARKSMANRIFLE", "WEAPON_HEAVYSHOTGUN", "WEAPON_GUSENBERG", "WEAPON_HATCHET", "WEAPON_RAILGUN"]]

local bodyguardScript = {}

function bodyguardScript.unload()
	for k, guard in pairs(guards) do
		if (guard ~= nil) then
			PED.DELETE_PED(guard)
			guards[k] = nil
			bodyguardCount = 0
		end
	end
end

function bodyguardScript.deleteOnDead()
	for k, guard in pairs(guards) do
		if (guard ~= nil) then
			if (PED.IS_PED_FATALLY_INJURED(guard)) then
				PED.DELETE_PED(guard)
				guards[k] = nil
				bodyguardCount = bodyguardCount - 1
			end
		end
	end
end

function bodyguardScript.tick()
	--Player variables
	local playerPed = PLAYER.PLAYER_PED_ID() -- Do not touch this!
	local player = PLAYER.GET_PLAYER_PED(playerPed) -- Do not touch this!
	local playerExists = ENTITY.DOES_ENTITY_EXIST(playerPed) -- Do not touch this!
	local playerPosition = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, 0.0, 5.0, 0.0) -- Do not touch this!
	local playerGroup = PED.GET_PED_GROUP_INDEX(playerPed) -- Do not touch this!

	--Weapons tables
	local mainWeapons = {"WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", 
	"WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN", "WEAPON_SAWNOFFSHOTGUN", 
	"WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_SNIPERRIFLE", 
	"WEAPON_HEAVYSNIPER"}
	local secondaryWeapons = {"WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL",
	"WEAPON_PISTOL50", "WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG"}

	--Skins table
	local Skins = {"s_m_y_blackops_01", "s_m_y_blackops_02"}

	--Number variables.
	local bodyguardCount = 0
	local amountAllowed = 3

	--Guards table.
	local guards = {}

	if (get_key_pressed(45)) then
		for _, m in pairs(Skins) do
			STREAMING.REQUEST_MODEL(GAMEPLAY.GET_HASH_KEY(m))

			while (not STREAMING.HAS_MODEL_LOADED(GAMEPLAY.GET_HASH_KEY(m))) do
				wait(50)
			end

			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(GAMEPLAY.GET_HASH_KEY(m))
		end

		for i = 0, amountAllowed, 1 do
			if (bodyguardCount <= amountAllowed) then
				guards[i] = PED.CREATE_PED(26,
				GAMEPLAY.GET_HASH_KEY(Skins[math.random(#Skins)]),
				playerPosition.x,
				playerPosition.y,
				playerPosition.z,
				1,
				false,
				true)

				PED.SET_PED_CAN_SWITCH_WEAPON(guards[i], true)
				PED.SET_PED_AS_GROUP_MEMBER(guards[i], playerGroup)

				WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(secondaryWeapons[math.random(#secondaryWeapons)]), 1000, false)
				WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(mainWeapons[math.random(#mainWeapons)]), 1000, false)

				bodyguardCount = bodyguardCount + 1
			end
		end
	end

	if (get_key_pressed(46)) then
		bodyguardScript.unload()
	end

	bodyguardScript.deleteOnDead()
end

return bodyguardScript