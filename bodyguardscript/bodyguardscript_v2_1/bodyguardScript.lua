--[[
Bodyguard Script by Foul Play. This script is WIP, there will be bugs. 
Version: 2.0
Please report bugs to https://github.com/FoulPlay/GTAVLUA/issues
]]

--[[
	Changelog:
	2.0 [29/04/15]
	[
		*New test version with old content from Version: 1.5.
		+Added a new table for melee weapons
		+Renamed "mainWeapons" to "primaryWeapons"
		+Added "WEAPON_NIGHTSTICK", "WEAPON_CROWBAR" and "WEAPON_BAT" to meleeWeapons table.
		+Created 3 new functions: "bodyguardScript.loadPedModels", "bodyguardScript.applyNativesToBodyguards" 
		and "bodyguardScript.applyWeaponsToBodyguards".
		-Removed "PED.IS_PED_FATALLY_INJURED(guard)"
		+Replaced "PED.IS_PED_FATALLY_INJURED(guard)" with "ENTITY.GET_ENTITY_HEALTH(guard) <= 0" to fix a bug with Guards getting removed
		when they shouldn't do. (It is mine fault because I didn't know about the Native "ENTITY.GET_ENTITY_HEALTH".)
		+Added "WEAPON_PISTOL", "WEAPON_APPISTOL", "WEAPON_PUMPSHOTGUN", "WEAPON_ASSAULTSHOTGUN" and "WEAPON_SMG" to the "secondaryWeapons" table.
		+Added "WEAPON_CARBINERIFLE", "WEAPON_HEAVYSNIPER", "WEAPON_ADVANCEDRIFLE", "WEAPON_SPECIALCARBINE", "WEAPON_COMBATMG" to the "primaryWeapons" table.
		-Removed "ENTITY.GET_ENTITY_HEALTH(guard) <= 0"
		+Replaced "ENTITY.GET_ENTITY_HEALTH(guard) <= 0" with "ENTITY.IS_ENTITY_DEAD(guard)"
		+Fixed a bug where they get deleted when not fully dead.
		+Added "PED.SET_PED_ARMOUR(guards[i], 200)", "WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(guards[i], false)",
		"AI.SET_PED_PATH_CAN_USE_CLIMBOVERS(guards[i], true)", "AI.SET_PED_PATH_CAN_USE_LADDERS(guards[i], true)" and
		"AI.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(guards[i], true)" to the "bodyguardScript.applyNativesToBodyguards" function.
		+More changes that are undocumented.
	]
	2.1 [02/05/15]
	[
		+Fixed a bug where models do not load and causing the bodyguards not to spawn.
		*Rewritten the "bodyguardScript.loadPedModels" function.
	]
]]

--[[
	Planned:
	Make a GUI version of the script.
	Make a unloadPedModels function.
]]

--Reference for guns
--[[
	"WEAPON_KNIFE", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_BAT", "WEAPON_GOLFCLUB", "WEAPON_CROWBAR",
	"WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50", "WEAPON_MICROSMG", "WEAPON_SMG",
	"WEAPON_ASSAULTSMG", "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG",
	"WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN", "WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN",
	"WEAPON_STUNGUN", "WEAPON_SNIPERRIFLE", "WEAPON_HEAVYSNIPER", "WEAPON_GRENADELAUNCHER", "WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG", "WEAPON_MINIGUN", "WEAPON_GRENADE", "WEAPON_STICKYBOMB", "WEAPON_SMOKEGRENADE", "WEAPON_BZGAS",
	"WEAPON_MOLOTOV", "WEAPON_FIREEXTINGUISHER", "WEAPON_PETROLCAN",
	"WEAPON_SNSPISTOL", "WEAPON_SPECIALCARBINE", "WEAPON_HEAVYPISTOL", "WEAPON_BULLPUPRIFLE", "WEAPON_HOMINGLAUNCHER",
	"WEAPON_PROXMINE", "WEAPON_SNOWBALL", "WEAPON_VINTAGEPISTOL", "WEAPON_DAGGER", "WEAPON_FIREWORK", "WEAPON_MUSKET",
	"WEAPON_MARKSMANRIFLE", "WEAPON_HEAVYSHOTGUN", "WEAPON_GUSENBERG", "WEAPON_HATCHET", "WEAPON_RAILGUN"
]]

--Main table.
local bodyguardScript = {}

--Guard table
local guards = {}

--Player variables
local playerPed = PLAYER.PLAYER_PED_ID() -- Do not touch this!
local player = PLAYER.GET_PLAYER_PED(playerPed) -- Do not touch this!
local playerExists = ENTITY.DOES_ENTITY_EXIST(playerPed) -- Do not touch this!
local playerPosition = ENTITY.GET_ENTITY_COORDS(playerPed, false) -- Do not touch this!
local playerGroup = PED.GET_PED_GROUP_INDEX(playerPed) -- Do not touch this!

--Weapons tables
local meleeWeapons = {"WEAPON_NIGHTSTICK", "WEAPON_CROWBAR", "WEAPON_BAT"}
local secondaryWeapons = {"WEAPON_PISTOL", "WEAPON_APPISTOL", "WEAPON_PUMPSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_SMG"}
local primaryWeapons = {"WEAPON_CARBINERIFLE", "WEAPON_HEAVYSNIPER", "WEAPON_ADVANCEDRIFLE", "WEAPON_SPECIALCARBINE", "WEAPON_COMBATMG"}

--Skins table
local Skins = {"s_m_y_blackops_01", "s_m_y_blackops_02"}

--Number variables.
local bodyguardCount = 0
local amountAllowed = 3
local Models_Loaded = 0

--Bool variables
local Has_Models_loaded = false

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
			if (ENTITY.IS_ENTITY_DEAD(guard)) then
				PED.DELETE_PED(guard)
				guards[k] = nil

				bodyguardCount = bodyguardCount - 1

				print(bodyguardCount)
			end
		end
	end
end

--Backup function (Will remove later.)
--[[function bodyguardScript.loadPedModels()
	for _, m in pairs(Skins) do
		while (Has_Models_loaded == false) do
			skin_hash = GAMEPLAY.GET_HASH_KEY(m)
			STREAMING.REQUEST_MODEL(skin_hash)

			if (STREAMING.HAS_MODEL_LOADED(skin_hash)) then
				Models_Loaded = Models_Loaded + 1
				print("Model: " .. m .. "(" .. skin_hash .. ")" .. "has been loaded.")
			elseif (not STREAMING.HAS_MODEL_LOADED(skin_hash)) then
				Models_Loaded = Models_Loaded - 1
				print("Model: " .. m .. "(" .. skin_hash .. ")" .. "has not been loaded.")
			end
			wait(100)
		end
	end

	if (Models_Loaded == #Skins and Has_Models_loaded == false) then
		print("All models has been loaded.")
		Has_Models_loaded = true
	end
end]]

function bodyguardScript.loadPedModels()
	while (Has_Models_loaded == false) do
		for _, m in pairs(Skins) do
			skin_hash = GAMEPLAY.GET_HASH_KEY(m)
			STREAMING.REQUEST_MODEL(skin_hash)

			if (STREAMING.HAS_MODEL_LOADED(skin_hash)) then
				Models_Loaded = Models_Loaded + 1
				print("Model: " .. m .. "(" .. skin_hash .. ")" .. "has been loaded.")
				wait(100)
			elseif (not STREAMING.HAS_MODEL_LOADED(skin_hash)) then
				Models_Loaded = Models_Loaded - 1
				print("Model: " .. m .. "(" .. skin_hash .. ")" .. "has not been loaded.")
				wait(100)
			end

		end

		wait(100)

		if (Models_Loaded == #Skins and Has_Models_loaded == false) then
			print("All models have been loaded.")
			Has_Models_loaded = true
		end
		
		if (Has_Models_loaded == true) then
			break
		end
	end
end

function bodyguardScript.applyNativesToBodyguards(i)
	PED.SET_PED_CAN_SWITCH_WEAPON(guards[i], true)
	PED.SET_PED_AS_GROUP_MEMBER(guards[i], playerGroup)
	PED.SET_PED_ARMOUR(guards[i], 200)

	WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(guards[i], false)

	AI.SET_PED_PATH_CAN_USE_CLIMBOVERS(guards[i], true)
	AI.SET_PED_PATH_CAN_USE_LADDERS(guards[i], true)
	AI.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(guards[i], true)
end

function bodyguardScript.applyWeaponsToBodyguards(i)
	local rndMWeapon = math.random(#meleeWeapons)
	local rndSWeapon = math.random(#secondaryWeapons)
	local rndPWeapon = math.random(#primaryWeapons)

	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(meleeWeapons[rndMWeapon]), 2, false)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(secondaryWeapons[rndSWeapon]), 5, false)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(primaryWeapons[rndPWeapon]), 7, false)
end

function bodyguardScript.tick()
	bodyguardScript.loadPedModels()

	if (get_key_pressed(45)) then
		for i = 0, amountAllowed, 1 do
			if (bodyguardCount < amountAllowed) then
				local playerPosition = ENTITY.GET_ENTITY_COORDS(playerPed, false)

				guards[i] = PED.CREATE_PED(26,
				GAMEPLAY.GET_HASH_KEY(Skins[math.random(#Skins)]),
				playerPosition.x,
				playerPosition.y + 5,
				playerPosition.z,
				1,
				false,
				true)

				bodyguardScript.applyNativesToBodyguards(i)
				bodyguardScript.applyWeaponsToBodyguards(i)

				bodyguardCount = bodyguardCount + 1

				print(bodyguardCount)
			end
		end
	end

	if (get_key_pressed(46)) then
		bodyguardScript.unload()
	end

	bodyguardScript.deleteOnDead()
end

return bodyguardScript