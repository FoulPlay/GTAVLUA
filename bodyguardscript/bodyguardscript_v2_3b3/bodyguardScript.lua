--[[
Bodyguard Script by Foul Play. This script is WIP, there will be bugs. 
Version: 2.3b3
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

	2.3b [13/05/15]
	*Beta version
	+Added 2 new functions "bodyguardScript.applyWeaponsToBodyguards" and "bodyguardScript.loadPedModels"
	*Made it so you can spawn bodyguards with random weapons and models
	*Made it so you can spawn bodyguards with single weapons and model.
	+More undocumented changes
	+Invincible is now can be configurable.
	+Single weapons or random weapons can be configurable.
	+Single models or random models can be configurable.

	2.3b2 [14/05/15]
	*Beta version 2
	+Fixed a bug where script not getting new player ped so when you change to Franklin, Michael or Trevor
	bodyguards do not spawn.
	+More undocumented changes.
	
	2.3b3 [17/05/15]
	*Beta version 3
	+Added teleportation for bodyguards.
	+More undocumented changes. 
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

--Reference for models
--[[
	"player_zero", "player_one", "player_two", "a_c_boar", "a_c_chimp", "a_c_cow", "a_c_coyote", "a_c_deer", "a_c_fish", "a_c_hen",
	"a_c_cat_01", "a_c_chickenhawk", "a_c_cormorant", "a_c_crow", "a_c_dolphin", "a_c_humpback", "a_c_killerwhale", "a_c_pigeon", "a_c_seagull", "a_c_sharkhammer",
	"a_c_pig", "a_c_rat", "a_c_rhesus", "a_c_chop", "a_c_husky", "a_c_mtlion", "a_c_retriever", "a_c_sharktiger", "a_c_shepherd", "s_m_m_movalien_01",
	"a_f_m_beach_01", "a_f_m_bevhills_01", "a_f_m_bevhills_02", "a_f_m_bodybuild_01", "a_f_m_business_02", "a_f_m_downtown_01", "a_f_m_eastsa_01", "a_f_m_eastsa_02", "a_f_m_fatbla_01", "a_f_m_fatcult_01",
	"a_f_m_fatwhite_01", "a_f_m_ktown_01", "a_f_m_ktown_02", "a_f_m_prolhost_01", "a_f_m_salton_01", "a_f_m_skidrow_01", "a_f_m_soucentmc_01", "a_f_m_soucent_01", "a_f_m_soucent_02", "a_f_m_tourist_01",
	"a_f_m_trampbeac_01", "a_f_m_tramp_01", "a_f_o_genstreet_01", "a_f_o_indian_01", "a_f_o_ktown_01", "a_f_o_salton_01", "a_f_o_soucent_01", "a_f_o_soucent_02", "a_f_y_beach_01", "a_f_y_bevhills_01",
	"a_f_y_bevhills_02", "a_f_y_bevhills_03", "a_f_y_bevhills_04", "a_f_y_business_01", "a_f_y_business_02", "a_f_y_business_03", "a_f_y_business_04", "a_f_y_eastsa_01", "a_f_y_eastsa_02", "a_f_y_eastsa_03",
	"a_f_y_epsilon_01", "a_f_y_fitness_01", "a_f_y_fitness_02", "a_f_y_genhot_01", "a_f_y_golfer_01", "a_f_y_hiker_01", "a_f_y_hippie_01", "a_f_y_hipster_01", "a_f_y_hipster_02", "a_f_y_hipster_03",
	"a_f_y_hipster_04", "a_f_y_indian_01", "a_f_y_juggalo_01", "a_f_y_runner_01", "a_f_y_rurmeth_01", "a_f_y_scdressy_01", "a_f_y_skater_01", "a_f_y_soucent_01", "a_f_y_soucent_02", "a_f_y_soucent_03",
	"a_f_y_tennis_01", "a_f_y_topless_01", "a_f_y_tourist_01", "a_f_y_tourist_02", "a_f_y_vinewood_01", "a_f_y_vinewood_02", "a_f_y_vinewood_03", "a_f_y_vinewood_04", "a_f_y_yoga_01", "a_m_m_acult_01",
	"a_m_m_afriamer_01", "a_m_m_beach_01", "a_m_m_beach_02", "a_m_m_bevhills_01", "a_m_m_bevhills_02", "a_m_m_business_01", "a_m_m_eastsa_01", "a_m_m_eastsa_02", "a_m_m_farmer_01", "a_m_m_fatlatin_01",
	"a_m_m_genfat_01", "a_m_m_genfat_02", "a_m_m_golfer_01", "a_m_m_hasjew_01", "a_m_m_hillbilly_01", "a_m_m_hillbilly_02", "a_m_m_indian_01", "a_m_m_ktown_01", "a_m_m_malibu_01", "a_m_m_mexcntry_01",
	"a_m_m_mexlabor_01", "a_m_m_og_boss_01", "a_m_m_paparazzi_01", "a_m_m_polynesian_01", "a_m_m_prolhost_01", "a_m_m_rurmeth_01", "a_m_m_salton_01", "a_m_m_salton_02", "a_m_m_salton_03", "a_m_m_salton_04",
	"a_m_m_skater_01", "a_m_m_skidrow_01", "a_m_m_socenlat_01", "a_m_m_soucent_01", "a_m_m_soucent_02", "a_m_m_soucent_03", "a_m_m_soucent_04", "a_m_m_stlat_02", "a_m_m_tennis_01", "a_m_m_tourist_01",
	"a_m_m_trampbeac_01", "a_m_m_tramp_01", "a_m_m_tranvest_01", "a_m_m_tranvest_02", "a_m_o_acult_01", "a_m_o_acult_02", "a_m_o_beach_01", "a_m_o_genstreet_01", "a_m_o_ktown_01", "a_m_o_salton_01",
	"a_m_o_soucent_01", "a_m_o_soucent_02", "a_m_o_soucent_03", "a_m_o_tramp_01", "a_m_y_acult_01", "a_m_y_acult_02", "a_m_y_beachvesp_01", "a_m_y_beachvesp_02", "a_m_y_beach_01", "a_m_y_beach_02",
	"a_m_y_beach_03", "a_m_y_bevhills_01", "a_m_y_bevhills_02", "a_m_y_breakdance_01", "a_m_y_busicas_01", "a_m_y_business_01", "a_m_y_business_02", "a_m_y_business_03", "a_m_y_cyclist_01", "a_m_y_dhill_01",
	"a_m_y_downtown_01", "a_m_y_eastsa_01", "a_m_y_eastsa_02", "a_m_y_epsilon_01", "a_m_y_epsilon_02", "a_m_y_gay_01", "a_m_y_gay_02", "a_m_y_genstreet_01", "a_m_y_genstreet_02", "a_m_y_golfer_01",
	"a_m_y_hasjew_01", "a_m_y_hiker_01", "a_m_y_hippy_01", "a_m_y_hipster_01", "a_m_y_hipster_02", "a_m_y_hipster_03", "a_m_y_indian_01", "a_m_y_jetski_01", "a_m_y_juggalo_01", "a_m_y_ktown_01",
	"a_m_y_ktown_02", "a_m_y_latino_01", "a_m_y_methhead_01", "a_m_y_mexthug_01", "a_m_y_motox_01", "a_m_y_motox_02", "a_m_y_musclbeac_01", "a_m_y_musclbeac_02", "a_m_y_polynesian_01", "a_m_y_roadcyc_01",
	"a_m_y_runner_01", "a_m_y_runner_02", "a_m_y_salton_01", "a_m_y_skater_01", "a_m_y_skater_02", "a_m_y_soucent_01", "a_m_y_soucent_02", "a_m_y_soucent_03", "a_m_y_soucent_04", "a_m_y_stbla_01",
	"a_m_y_stbla_02", "a_m_y_stlat_01", "a_m_y_stwhi_01", "a_m_y_stwhi_02", "a_m_y_sunbathe_01", "a_m_y_surfer_01", "a_m_y_vindouche_01", "a_m_y_vinewood_01", "a_m_y_vinewood_02", "a_m_y_vinewood_03",
	"a_m_y_vinewood_04", "a_m_y_yoga_01", "u_m_y_proldriver_01", "u_m_y_rsranger_01", "u_m_y_sbike", "u_m_y_staggrm_01", "u_m_y_tattoo_01", "csb_abigail", "csb_anita", "csb_anton",
	"csb_ballasog", "csb_bride", "csb_burgerdrug", "csb_car3guy1", "csb_car3guy2", "csb_chef", "csb_chin_goon", "csb_cletus", "csb_cop", "csb_customer",
	"csb_denise_friend", "csb_fos_rep", "csb_g", "csb_groom", "csb_grove_str_dlr", "csb_hao", "csb_hugh", "csb_imran", "csb_janitor", "csb_maude",
	"csb_mweather", "csb_ortega", "csb_oscar", "csb_porndudes", "csb_porndudes_p", "csb_prologuedriver", "csb_prolsec", "csb_ramp_gang", "csb_ramp_hic", "csb_ramp_hipster",
	"csb_ramp_marine", "csb_ramp_mex", "csb_reporter", "csb_roccopelosi", "csb_screen_writer", "csb_stripper_01", "csb_stripper_02", "csb_tonya", "csb_trafficwarden", "cs_amandatownley",
	"cs_andreas", "cs_ashley", "cs_bankman", "cs_barry", "cs_barry_p", "cs_beverly", "cs_beverly_p", "cs_brad", "cs_bradcadaver", "cs_carbuyer",
	"cs_casey", "cs_chengsr", "cs_chrisformage", "cs_clay", "cs_dale", "cs_davenorton", "cs_debra", "cs_denise", "cs_devin", "cs_dom",
	"cs_dreyfuss", "cs_drfriedlander", "cs_fabien", "cs_fbisuit_01", "cs_floyd", "cs_guadalope", "cs_gurk", "cs_hunter", "cs_janet", "cs_jewelass",
	"cs_jimmyboston", "cs_jimmydisanto", "cs_joeminuteman", "cs_johnnyklebitz", "cs_josef", "cs_josh", "cs_lamardavis", "cs_lazlow", "cs_lestercrest", "cs_lifeinvad_01",
	"cs_magenta", "cs_manuel", "cs_marnie", "cs_martinmadrazo", "cs_maryann", "cs_michelle", "cs_milton", "cs_molly", "cs_movpremf_01", "cs_movpremmale",
	"cs_mrk", "cs_mrsphillips", "cs_mrs_thornhill", "cs_natalia", "cs_nervousron", "cs_nigel", "cs_old_man1a", "cs_old_man2", "cs_omega", "cs_orleans",
	"cs_paper", "cs_paper_p", "cs_patricia", "cs_priest", "cs_prolsec_02", "cs_russiandrunk", "cs_siemonyetarian", "cs_solomon", "cs_stevehains", "cs_stretch",
	"cs_tanisha", "cs_taocheng", "cs_taostranslator", "cs_tenniscoach", "cs_terry", "cs_tom", "cs_tomepsilon", "cs_tracydisanto", "cs_wade", "cs_zimbor",
	"g_f_y_ballas_01", "g_f_y_families_01", "g_f_y_lost_01", "g_f_y_vagos_01", "g_m_m_armboss_01", "g_m_m_armgoon_01", "g_m_m_armlieut_01", "g_m_m_chemwork_01", "g_m_m_chemwork_01_p", "g_m_m_chiboss_01",
	"g_m_m_chiboss_01_p", "g_m_m_chicold_01", "g_m_m_chicold_01_p", "g_m_m_chigoon_01", "g_m_m_chigoon_01_p", "g_m_m_chigoon_02", "g_m_m_korboss_01", "g_m_m_mexboss_01", "g_m_m_mexboss_02", "g_m_y_armgoon_02",
	"g_m_y_azteca_01", "g_m_y_ballaeast_01", "g_m_y_ballaorig_01", "g_m_y_ballasout_01", "g_m_y_famca_01", "g_m_y_famdnf_01", "g_m_y_famfor_01", "g_m_y_korean_01", "g_m_y_korean_02", "g_m_y_korlieut_01",
	"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03", "g_m_y_mexgang_01", "g_m_y_mexgoon_01", "g_m_y_mexgoon_02", "g_m_y_mexgoon_03", "g_m_y_mexgoon_03_p", "g_m_y_pologoon_01", "g_m_y_pologoon_01_p",
	"g_m_y_pologoon_02", "g_m_y_pologoon_02_p", "g_m_y_salvaboss_01", "g_m_y_salvagoon_01", "g_m_y_salvagoon_02", "g_m_y_salvagoon_03", "g_m_y_salvagoon_03_p", "g_m_y_strpunk_01", "g_m_y_strpunk_02", "hc_driver",
	"hc_gunman", "hc_hacker", "ig_abigail", "ig_amandatownley", "ig_andreas", "ig_ashley", "ig_ballasog", "ig_bankman", "ig_barry", "ig_barry_p",
	"ig_bestmen", "ig_beverly", "ig_beverly_p", "ig_brad", "ig_bride", "ig_car3guy1", "ig_car3guy2", "ig_casey", "ig_chef", "ig_chengsr",
	"ig_chrisformage", "ig_clay", "ig_claypain", "ig_cletus", "ig_dale", "ig_davenorton", "ig_denise", "ig_devin", "ig_dom", "ig_dreyfuss",
	"ig_drfriedlander", "ig_fabien", "ig_fbisuit_01", "ig_floyd", "ig_groom", "ig_hao", "ig_hunter", "ig_janet", "ig_jay_norris", "ig_jewelass",
	"ig_jimmyboston", "ig_jimmydisanto", "ig_joeminuteman", "ig_johnnyklebitz", "ig_josef", "ig_josh", "ig_kerrymcintosh", "ig_lamardavis", "ig_lazlow", "ig_lestercrest",
	"ig_lifeinvad_01", "ig_lifeinvad_02", "ig_magenta", "ig_manuel", "ig_marnie", "ig_maryann", "ig_maude", "ig_michelle", "ig_milton", "ig_molly",
	"ig_mrk", "ig_mrsphillips", "ig_mrs_thornhill", "ig_natalia", "ig_nervousron", "ig_nigel", "ig_old_man1a", "ig_old_man2", "ig_omega", "ig_oneil",
	"ig_orleans", "ig_ortega", "ig_paper", "ig_patricia", "ig_priest", "ig_prolsec_02", "ig_ramp_gang", "ig_ramp_hic", "ig_ramp_hipster", "ig_ramp_mex",
	"ig_roccopelosi", "ig_russiandrunk", "ig_screen_writer", "ig_siemonyetarian", "ig_solomon", "ig_stevehains", "ig_stretch", "ig_talina", "ig_tanisha", "ig_taocheng",
	"ig_taostranslator", "ig_taostranslator_p", "ig_tenniscoach", "ig_terry", "ig_tomepsilon", "ig_tonya", "ig_tracydisanto", "ig_trafficwarden", "ig_tylerdix", "ig_wade",
	"ig_zimbor", "mp_f_deadhooker", "mp_f_freemode_01", "mp_f_misty_01", "mp_f_stripperlite", "mp_g_m_pros_01", "mp_headtargets", "mp_m_claude_01", "mp_m_exarmy_01", "mp_m_famdd_01",
	"mp_m_fibsec_01", "mp_m_freemode_01", "mp_m_marston_01", "mp_m_niko_01", "mp_m_shopkeep_01", "mp_s_m_armoured_01", "", "", "", "",
	"", "s_f_m_fembarber", "s_f_m_maid_01", "s_f_m_shop_high", "s_f_m_sweatshop_01", "s_f_y_airhostess_01", "s_f_y_bartender_01", "s_f_y_baywatch_01", "s_f_y_cop_01", "s_f_y_factory_01",
	"s_f_y_hooker_01", "s_f_y_hooker_02", "s_f_y_hooker_03", "s_f_y_migrant_01", "s_f_y_movprem_01", "s_f_y_ranger_01", "s_f_y_scrubs_01", "s_f_y_sheriff_01", "s_f_y_shop_low", "s_f_y_shop_mid",
	"s_f_y_stripperlite", "s_f_y_stripper_01", "s_f_y_stripper_02", "s_f_y_sweatshop_01", "s_m_m_ammucountry", "s_m_m_armoured_01", "s_m_m_armoured_02", "s_m_m_autoshop_01", "s_m_m_autoshop_02", "s_m_m_bouncer_01",
	"s_m_m_chemsec_01", "s_m_m_ciasec_01", "s_m_m_cntrybar_01", "s_m_m_dockwork_01", "s_m_m_doctor_01", "s_m_m_fiboffice_01", "s_m_m_fiboffice_02", "s_m_m_gaffer_01", "s_m_m_gardener_01", "s_m_m_gentransport",
	"s_m_m_hairdress_01", "s_m_m_highsec_01", "s_m_m_highsec_02", "s_m_m_janitor", "s_m_m_lathandy_01", "s_m_m_lifeinvad_01", "s_m_m_linecook", "s_m_m_lsmetro_01", "s_m_m_mariachi_01", "s_m_m_marine_01",
	"s_m_m_marine_02", "s_m_m_migrant_01", "u_m_y_zombie_01", "s_m_m_movprem_01", "s_m_m_movspace_01", "s_m_m_paramedic_01", "s_m_m_pilot_01", "s_m_m_pilot_02", "s_m_m_postal_01", "s_m_m_postal_02",
	"s_m_m_prisguard_01", "s_m_m_scientist_01", "s_m_m_security_01", "s_m_m_snowcop_01", "s_m_m_strperf_01", "s_m_m_strpreach_01", "s_m_m_strvend_01", "s_m_m_trucker_01", "s_m_m_ups_01", "s_m_m_ups_02",
	"s_m_o_busker_01", "s_m_y_airworker", "s_m_y_ammucity_01", "s_m_y_armymech_01", "s_m_y_autopsy_01", "s_m_y_barman_01", "s_m_y_baywatch_01", "s_m_y_blackops_01", "s_m_y_blackops_02", "s_m_y_busboy_01",
	"s_m_y_chef_01", "s_m_y_clown_01", "s_m_y_construct_01", "s_m_y_construct_02", "s_m_y_cop_01", "s_m_y_dealer_01", "s_m_y_devinsec_01", "s_m_y_dockwork_01", "s_m_y_doorman_01", "s_m_y_dwservice_01",
	"s_m_y_dwservice_02", "s_m_y_factory_01", "s_m_y_fireman_01", "s_m_y_garbage", "s_m_y_grip_01", "s_m_y_hwaycop_01", "s_m_y_marine_01", "s_m_y_marine_02", "s_m_y_marine_03", "s_m_y_mime",
	"s_m_y_pestcont_01", "s_m_y_pilot_01", "s_m_y_prismuscl_01", "s_m_y_prisoner_01", "s_m_y_ranger_01", "s_m_y_robber_01", "s_m_y_sheriff_01", "s_m_y_shop_mask", "s_m_y_strvend_01", "s_m_y_swat_01",
	"s_m_y_uscg_01", "s_m_y_valet_01", "s_m_y_waiter_01", "s_m_y_winclean_01", "s_m_y_xmech_01", "s_m_y_xmech_02", "u_f_m_corpse_01", "u_f_m_miranda", "u_f_m_promourn_01", "u_f_o_moviestar",
	"u_f_o_prolhost_01", "u_f_y_bikerchic", "u_f_y_comjane", "u_f_y_corpse_01", "u_f_y_corpse_02", "u_f_y_hotposh_01", "u_f_y_jewelass_01", "u_f_y_mistress", "u_f_y_poppymich", "u_f_y_princess",
	"u_f_y_spyactress", "u_m_m_aldinapoli", "u_m_m_bankman", "u_m_m_bikehire_01", "u_m_m_fibarchitect", "u_m_m_filmdirector", "u_m_m_glenstank_01", "u_m_m_griff_01", "u_m_m_jesus_01", "u_m_m_jewelsec_01",
	"u_m_m_jewelthief", "u_m_m_markfost", "u_m_m_partytarget", "u_m_m_prolsec_01", "u_m_m_promourn_01", "u_m_m_rivalpap", "u_m_m_spyactor", "u_m_m_willyfist", "u_m_o_finguru_01", "u_m_o_taphillbilly",
	"u_m_o_tramp_01", "u_m_y_abner", "u_m_y_antonb", "u_m_y_babyd", "u_m_y_baygor", "u_m_y_burgerdrug_01", "u_m_y_chip", "u_m_y_cyclist_01", "u_m_y_fibmugger_01", "u_m_y_guido_01",
	"u_m_y_gunvend_01", "u_m_y_hippie_01", "u_m_y_imporage", "u_m_y_justin", "u_m_y_mani", "u_m_y_militarybum", "u_m_y_paparazzi", "u_m_y_party_01", "u_m_y_pogo_01", "u_m_y_prisoner_01"
]]

--[[
	Planned:
	Make a GUI version of the script.
]]

--Main table.
local bodyguardScript = {} --Do not touch this!

--Guard table
local guards = {} --Do not touch this!

local bodyguardsInvincibleEnabled = true --true to enable invincible and false to disable.

local bodyguardVehicle = "CAVALCADE2"

--Weapons tables
local rndMeleeWeapons = {"WEAPON_KNIFE", "WEAPON_CROWBAR"} --You can modify this with any melee weapons.
local rndSecondaryWeapons = {"WEAPON_PISTOL", "WEAPON_STUNGUN"} --You can modify this with any side weapons.
local rndPrimaryWeapons = {"WEAPON_ASSAULTRIFLE", "WEAPON_PUMPSHOTGUN"} --You can modify this with any main weapons.

local RndModels = false -- true for random models else false for single model.
local RndWeapons = false -- true for random weapons else false for single weapon.

--Models tables
local RndModels_table = {"s_f_y_hooker_03", "g_m_y_salvaboss_01", "u_f_y_corpse_02", 
"a_m_m_skidrow_01", "s_m_y_garbage", "ig_lamardavis", "u_m_y_rsranger_01", 
"a_m_o_tramp_01", "u_m_y_hippie_01", 
"s_m_y_barman_01", "ig_cletus"}

--Number variables.
local bodyguardCount = 0 --Do not touch this!
local amountAllowed = 3 --You can modify this up to 7 guards!
local bodyguardInVehicle = 0 -- Do not touch this!

--Single Ped Model
local pedModel = "s_m_y_blackops_01" --You can modify this with any model.

--Single Weapons.
local meleeWeapon = "WEAPON_KNIFE" --You can modify this with any melee weapon.
local secondaryWeapon = "WEAPON_PISTOL" --You can modify this with any secondary weapon.
local primaryWeapon = "WEAPON_ASSAULTRIFLE" --You can modify this with any primary weapon.

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

function bodyguardScript.unloadPedModel()
	model_hash = GAMEPLAY.GET_HASH_KEY(pedModel)

	while (true) do
		if (STREAMING.HAS_MODEL_LOADED(model_hash)) then
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
			print("[bodyguardScript.unloadPedModel]: Model: " .. pedModel .. "(" .. model_hash .. ")" .. 
			" has been set to 'NO LONGER NEEDED'." )
			break
		end
		wait(10)
	end
end

--WILL UPDATE THIS FUNCTION SOON!
function bodyguardScript.unloadRndPedModels()
	for _, m in pairs(RndModels_table) do
		model_hash = GAMEPLAY.GET_HASH_KEY(m)

		while (true) do
			if (STREAMING.HAS_MODEL_LOADED(model_hash)) then
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
				print("[bodyguardScript.unloadRndPedModels]: Model: " .. m .. "(" .. model_hash .. ")" .. 
				" has been set to 'NO LONGER NEEDED'." )
				break
			end
			wait(10)
		end
	end
end

--WILL UPDATE THIS FUNCTION SOON!
function bodyguardScript.loadRndPedModels()
	for k, v in pairs(RndModels_table) do
		model_hash = GAMEPLAY.GET_HASH_KEY(v)

		if (not STREAMING.HAS_MODEL_LOADED(model_hash)) then
			STREAMING.REQUEST_MODEL(model_hash)
			print("[bodyguardScript.loadRndPedModels]: Requesting Model: " .. v .. "(" .. model_hash .. ")")

			while (true) do
				if (STREAMING.HAS_MODEL_LOADED(model_hash)) then
					print("[bodyguardScript.loadRndPedModels]: Model: " .. v .. "(" .. model_hash .. ")" .. " been loaded.")
					break
				end
				wait(10)
			end
		end
	end
end

function bodyguardScript.loadPedModel()
	model_hash = GAMEPLAY.GET_HASH_KEY(pedModel)

	if (not STREAMING.HAS_MODEL_LOADED(model_hash)) then
		STREAMING.REQUEST_MODEL(model_hash)
		print("[bodyguardScript.loadPedModel]: Requesting Model: " .. pedModel .. "(" .. model_hash .. ")")

		while (true) do
			if (STREAMING.HAS_MODEL_LOADED(model_hash)) then
				print("[bodyguardScript.loadPedModel]: Model: " .. pedModel .. "(" .. model_hash .. ")" .. " been loaded.")
				break
			end
			wait(10)
		end
	end
end

function bodyguardScript.applyRndWeaponsToBodyguards(i)
	local rndMWeapon = math.random(#rndMeleeWeapons)
	local rndSWeapon = math.random(#rndSecondaryWeapons)
	local rndPWeapon = math.random(#rndPrimaryWeapons)

	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(rndMeleeWeapons[rndMWeapon]), 500, true)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(rndSecondaryWeapons[rndSWeapon]), 500, true)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(rndPrimaryWeapons[rndPWeapon]), 500, true)
end

function bodyguardScript.applyWeaponsToBodyguards(i)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(meleeWeapon), 500, true)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(secondaryWeapon), 500, true)
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(guards[i], GAMEPLAY.GET_HASH_KEY(primaryWeapon), 500, true)
end

function bodyguardScript.applyNativesToBodyguards(i)
	local playerPed = PLAYER.PLAYER_PED_ID()--Do not touch this!
	local playerGroup = PED.GET_PED_GROUP_INDEX(playerPed)--Do not touch this!
	
	PED.SET_PED_CAN_SWITCH_WEAPON(guards[i], true)
	PED.SET_PED_AS_GROUP_MEMBER(guards[i], playerGroup)
	PED.SET_PED_ACCURACY(guards[i], 100)

	ENTITY.SET_ENTITY_INVINCIBLE(guards[i], bodyguardsInvincibleEnabled)

	WEAPON.SET_PED_DROPS_WEAPONS_WHEN_DEAD(guards[i], false)

	AI.SET_PED_PATH_CAN_USE_CLIMBOVERS(guards[i], true)
	AI.SET_PED_PATH_CAN_USE_LADDERS(guards[i], true)
	AI.SET_PED_PATH_CAN_DROP_FROM_HEIGHT(guards[i], true)
end

function bodyguardScript.GetRndModel()
	local rndMod_1 = RndModels_table[math.random(#RndModels_table)]
	local rndMod_2 = RndModels_table[math.random(#RndModels_table)]

	if (RndMod_1 == RndMod_2 and RndMod_2 == RndMod_1) then
		return RndModels_table[math.random(#RndModels_table)]
	elseif (not RndMod_1 == RndMod_2 and not RndMod_2 == RndMod_1) then
		return RndMod_1 or RndMod_2
	end
end

function bodyguardScript.teleportbodyguardsToPlayer()
	local playerPed = PLAYER.PLAYER_PED_ID()
	local player = PLAYER.GET_PLAYER_PED(playerPed)
	local playerPosition = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, 0.0, 2.5, 0.0)--Do not touch this!

	for k, guard in pairs(guards) do
		if (guard ~= nil) then
			if (not PED.IS_PED_IN_ANY_VEHICLE(playerPed, false) and not PED.IS_PED_IN_ANY_VEHICLE(guard, false)) then
				ENTITY.SET_ENTITY_COORDS(guard, playerPosition.x, playerPosition.y,
				playerPosition.z, false, false, false, false)
				print("[bodyguardScript.teleportbodyguardsToPlayer]: Part 1: I'm working.")
			elseif(PED.IS_PED_IN_ANY_VEHICLE(playerPed, false) and not PED.IS_PED_IN_ANY_VEHICLE(guard, false)) then
				ENTITY.SET_ENTITY_COORDS(guard, playerPosition.x, playerPosition.y,
				playerPosition.z, false, false, false, false)
				print("[bodyguardScript.teleportbodyguardsToPlayer]: Part 2: I'm working.")
			end
		end
	end
end

--[[function bodyguardScript.followPlayerInVehicle()
	local playerPed = PLAYER.PLAYER_PED_ID()
	local player = PLAYER.GET_PLAYER_PED(playerPed)
	local playerPosition = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, 0.0, 5.0, 0.0)--Do not touch this!
	STREAMING.REQUEST_MODEL(bodyguardVehicle)

	while (not STREAMING.HAS_MODEL_LOADED(bodyguardVehicle)) do
		wait(10)
	end
	--local veh = VEHICLE.CREATE_VEHICLE(bodyguardVehicle, playerPosition.x, playerPosition.y, playerPosition.z, 0.0, 1, 1)
	if 
	for k, guard in pairs(guards) do
		if (guard ~= nil) then
			
		end
	end
end]]

function bodyguardScript.tick()
	local playerPed = PLAYER.PLAYER_PED_ID()--Do not touch this!
	local player = PLAYER.GET_PLAYER_PED(playerPed)--Do not touch this!
	local playerExists = ENTITY.DOES_ENTITY_EXIST(playerPed)--Do not touch this!
	local playerPosition = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, 0.0, 5.0, 0.0)--Do not touch this!
	local playerGroup = PED.GET_PED_GROUP_INDEX(playerPed)--Do not touch this!

	if (get_key_pressed(45) and playerExists) then
		for i = 0, amountAllowed, 1 do
			if (bodyguardCount < amountAllowed) then
				bodyguardScript.loadRndPedModels()
				bodyguardScript.loadPedModel()

				if (RndModels == true) then
					guards[i] = PED.CREATE_PED(26,
					GAMEPLAY.GET_HASH_KEY(bodyguardScript.GetRndModel()),
					playerPosition.x,
					playerPosition.y,
					playerPosition.z,
					1,
					false,
					true)

					if (RndWeapons == true) then
						bodyguardScript.applyRndWeaponsToBodyguards(i)
					elseif (RndWeapons == false) then
						bodyguardScript.applyWeaponsToBodyguards(i)
					end

					bodyguardScript.applyNativesToBodyguards(i)
					bodyguardScript.unloadRndPedModels()
				elseif (RndModels == false) then
					guards[i] = PED.CREATE_PED(26,
					GAMEPLAY.GET_HASH_KEY(pedModel),
					playerPosition.x,
					playerPosition.y,
					playerPosition.z,
					1,
					false,
					true)

					if (RndWeapons == true) then
						bodyguardScript.applyRndWeaponsToBodyguards(i)
					elseif (RndWeapons == false) then
						bodyguardScript.applyWeaponsToBodyguards(i)
					end

					bodyguardScript.applyNativesToBodyguards(i)
					bodyguardScript.unloadPedModel()
				end

				bodyguardCount = bodyguardCount + 1
				print("[bodyguardScript.tick]: Number of bodyguards: " .. bodyguardCount)
			end
		end
	end

	if (get_key_pressed(46) and playerExists) then
		bodyguardScript.unload()
	end
	
	if (get_key_pressed(35) and playerExists) then
		bodyguardScript.teleportbodyguardsToPlayer()
	end

	bodyguardScript.deleteOnDead()
end

return bodyguardScript