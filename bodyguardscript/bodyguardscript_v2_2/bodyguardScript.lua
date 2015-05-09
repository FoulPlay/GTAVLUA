--[[
Bodyguard Script by Foul Play. This script is WIP, there will be bugs. 
Version: 2.2
Please report bugs to https://github.com/FoulPlay/GTAVLUA/issues
]]

--[[
	Changelog:

	2.0 [29/04/15]
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

	2.1 [02/05/15]
	+Fixed a bug where models do not load and causing the bodyguards not to spawn.
	*Rewritten the "bodyguardScript.loadPedModels" function.

	2.2 [09/05/15]
	*Rewritten the "bodyguardScript.loadPedModels" function again.
	+Added "bodyguardScript.unloadPedModels" function.
	+Renamed "Models_Loaded" to "int_Models_Loaded".
	+Renamed "Has_Models_loaded" to "bool_Models_Loaded".
	+Renamed "Skins" to "Models".
	+More undocumented changes.
]]

--[[
	Planned:
	Make a GUI version of the script.
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
local bodyguardScript = {} --Do not touch this!

--Guard table
local guards = {} --Do not touch this!

--Player variables
local playerPed = PLAYER.PLAYER_PED_ID() --Do not touch this!
local player = PLAYER.GET_PLAYER_PED(playerPed) --Do not touch this!
local playerExists = ENTITY.DOES_ENTITY_EXIST(playerPed) --Do not touch this!
local playerPosition = ENTITY.GET_ENTITY_COORDS(playerPed, true) --Do not touch this!
local playerGroup = PED.GET_PED_GROUP_INDEX(playerPed) --Do not touch this!

--Weapons tables
local meleeWeapons = {"WEAPON_NIGHTSTICK", "WEAPON_CROWBAR", "WEAPON_BAT"} --You can modify this with any melee weapons.
local secondaryWeapons = {"WEAPON_PISTOL", "WEAPON_SMG"} --You can modify this with any side weapons.
local primaryWeapons = {"WEAPON_ASSAULTRIFLE", "WEAPON_PUMPSHOTGUN", "WEAPON_MG"} --You can modify this with any main weapons.

--Skins table
local Models = {"s_m_y_blackops_01", "s_m_y_blackops_02"} --You can modify this with any models.

--Number variables.
local bodyguardCount = 0 --Do not touch this!
local amountAllowed = 3 --You can modify this up to 7 guards!

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

				print("[bodyguardScript.deleteOnDead]: Number of bodyguards: " .. bodyguardCount)
			end
		end
	end
end

function bodyguardScript.unloadPedModels()
	for _, m in pairs(Models) do
		model_hash = GAMEPLAY.GET_HASH_KEY(m)

		while (true) do
			if (STREAMING.HAS_MODEL_LOADED(model_hash)) then
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
				print("[bodyguardScript.unloadPedModels]: Model: " .. m .. "(" .. model_hash .. ")" .. 
				" has been set to 'NO LONGER NEEDED'." )
				break
			end
			wait(1)
		end
	end
end

function bodyguardScript.loadPedModels()
	for _, m in pairs(Models) do
		model_hash = GAMEPLAY.GET_HASH_KEY(m)

		if (not STREAMING.HAS_MODEL_LOADED(model_hash)) then
			STREAMING.REQUEST_MODEL(model_hash)
			print("[bodyguardScript.loadPedModels]: Requesting Model: " .. m .. "(" .. model_hash .. ")")

			while (true) do
				if (STREAMING.HAS_MODEL_LOADED(model_hash)) then
					print("[bodyguardScript.loadPedModels]: Model: " .. m .. "(" .. model_hash .. ")" .. " been loaded.")
					break
				end
				wait(1)
			end
		end
	end
end

function bodyguardScript.applyNativesToBodyguards(i)
	PED.SET_PED_CAN_SWITCH_WEAPON(guards[i], true)
	PED.SET_PED_AS_GROUP_MEMBER(guards[i], playerGroup)
	PED.SET_PED_ACCURACY(guards[i], 100)

	ENTITY.SET_ENTITY_INVINCIBLE(guards[i], true)

	WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(guards[i], false)

	AI.SET_PED_PATH_CAN_USE_CLIMBOVERS(guards[i], true)
	AI.SET_PED_PATH_CAN_USE_LADDERS(guards[i], true)
	AI.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(guards[i], true)
end

function bodyguardScript.applyWeaponsToBodyguards(i)
	local rndMWeapon = math.random(#meleeWeapons)
	local rndSWeapon = math.random(#secondaryWeapons)
	local rndPWeapon = math.random(#primaryWeapons)

	wait(1)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(meleeWeapons[rndMWeapon]), 1, true)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(secondaryWeapons[rndSWeapon]), 2, true)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(primaryWeapons[rndPWeapon]), 3, true)
end

function bodyguardScript.tick()
	if (get_key_pressed(45)) then
		for i = 0, amountAllowed, 1 do
			if (bodyguardCount < amountAllowed) then
				local playerPosition = ENTITY.GET_ENTITY_COORDS(playerPed, false)

				bodyguardScript.loadPedModels()

				guards[i] = PED.CREATE_PED(26,
				GAMEPLAY.GET_HASH_KEY(Models[math.random(#Models)]),
				playerPosition.x,
				playerPosition.y + 5,
				playerPosition.z,
				1,
				false,
				true)

				bodyguardScript.applyNativesToBodyguards(i)
				bodyguardScript.applyWeaponsToBodyguards(i)

				bodyguardCount = bodyguardCount + 1

				print("[bodyguardScript.tick]: Number of bodyguards: " .. bodyguardCount)

				bodyguardScript.unloadPedModels()
			end
		end
	end

	if (get_key_pressed(46)) then
		bodyguardScript.unload()
	end

	bodyguardScript.deleteOnDead()
end

return bodyguardScript