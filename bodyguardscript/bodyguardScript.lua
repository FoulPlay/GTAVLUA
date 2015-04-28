--[[
Bodyguard Script by Foul Play. This is WIP so there will be bugs. Version 3
]]

--[[Changelog:
1: First Test Version.
2: Fixed errors.
3: Fixed more errors.
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

local bodyguardScript = {
guards = {}, -- Do not touch this!
amountAllowed = 3, -- You can modify this up to 8 because that's all you are allowed.
bodyguardCount = 0, -- Do not touch this!
SkinsIDs = {"s_m_y_blackops_01", "s_m_y_blackops_02"}, -- You can modify this with only models to add or remove!
mainWeapons = {"WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG", 
"WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN", "WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", 
"WEAPON_BULLPUPSHOTGUN", "WEAPON_SNIPERRIFLE", "WEAPON_HEAVYSNIPER"}, -- Shotguns to Heavy Weapons 
secondaryWeapons = {"WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50", "WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG"} --Pistols to SMGS
}
local playerPed = PLAYER.PLAYER_PED_ID() -- Do not touch this!
local player = PLAYER.GET_PLAYER_PED(playerPed) -- Do not touch this!
local playerExists = ENTITY.DOES_ENTITY_EXIST(playerPed) -- Do not touch this!
local playerPosition = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, 0.0, 5.0, 0.0) -- Do not touch this!
local playerGroup = PED.GET_PED_GROUP_INDEX(playerPed) -- Do not touch this!

function bodyguardScript.unload()
	for k, guard in pairs(bodyguardScript.guards) do
		if (guard ~= nil) then
			PED.DELETE_PED(guard)
			bodyguardScript.guards[k] = nil
			bodyguardScript.bodyguardCount = 0
		end
	end
end

function bodyguardScript.deleteOnDead()
	for k, guard in pairs(bodyguardScript.guards) do
		if (guard ~= nil) then
			if (PED.IS_PED_FATALLY_INJURED(guard)) then
				PED.DELETE_PED(guard)
				bodyguardScript.guards[k] = nil
				bodyguardScript.bodyguardCount = bodyguardScript.bodyguardCount - 1
			end
		end
	end
end

function bodyguardScript.spawnGuard(i)
	bodyguardScript.guards[i] = PED.CREATE_PED(26,
	GAMEPLAY.GET_HASH_KEY(bodyguardScript.SkinsIDs[math.random(#bodyguardScript.SkinsIDs)]),
	playerPosition.x,
	playerPosition.y,
	playerPosition.z,
	1,
	false,
	true)

	bodyguardScript.bodyguardCount = bodyguardScript.bodyguardCount + 1

	bodyguardScript.applyFlagsToGuard(i)
	bodyguardScript.randomizeGuardGuns(i)
end

function bodyguardScript.randomizeGuardGuns(i)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguardScript.guards[i], GAMEPLAY.GET_HASH_KEY(bodyguardScript.secondaryWeapons[math.random(#bodyguardScript.secondaryWeapons)]), 250, false)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguardScript.guards[i], GAMEPLAY.GET_HASH_KEY(bodyguardScript.mainWeapons[math.random(#bodyguardScript.mainWeapons)]), 500, false)
end

function bodyguardScript.applyFlagsToGuard(i)
	PED.SET_PED_CAN_SWITCH_WEAPON(bodyguardScript.guards[i], true)
	PED.SET_PED_AS_GROUP_MEMBER(bodyguardScript.guards[i], playerGroup)
end

function bodyguardScript.tick()
	if (get_key_pressed(45)) then
		for _, m in pairs(bodyguardScript.SkinsIDs) do
			STREAMING.REQUEST_MODEL(GAMEPLAY.GET_HASH_KEY(m))

			while (not STREAMING.HAS_MODEL_LOADED(GAMEPLAY.GET_HASH_KEY(m))) do
				wait(50)
			end

			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(GAMEPLAY.GET_HASH_KEY(m))
		end
		for i = 0, bodyguardScript.amountAllowed, 1 do
			if (bodyguardScript.bodyguardCount < bodyguardScript.amountAllowed) then
				bodyguardScript.spawnGuard(i)
			end
		end
	end

	if (get_key_pressed(46)) then
		bodyguardScript.unload()
	end

	bodyguardScript.deleteOnDead()
end

return bodyguardScript