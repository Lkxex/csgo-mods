#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

// ==================== SPRAY DATA ====================
enum struct GraffitiItem
{
	int    id;
	char   name[64];
	char   category[16];
	char   material[64]; // sticker_material from items_game.txt
}

static const GraffitiItem g_Graffiti[] =
{
	// Standard (Legacy) - verified _nodrips suffix from pak01_dir.vpk
	{ 1697, "Axes Crossed",       "Standard",   "default/axes_crossed_nodrips"       },
	{ 1698, "Bubble: Dead",       "Standard",   "default/bubble_dead_nodrips"        },
	{ 1699, "Chess King",         "Standard",   "default/chess_king_nodrips"         },
	{ 1700, "Crown",              "Standard",   "default/crown_nodrips"              },
	{ 1701, "Dollar",             "Standard",   "default/dollar_nodrips"             },
	{ 1702, "Double Kill",        "Standard",   "default/double_kill_nodrips"        },
	{ 1703, "Eco Pistol",         "Standard",   "default/eco_pistol_nodrips"         },
	{ 1704, "Emoji: Angry",       "Standard",   "default/emo_angry_nodrips"          },
	{ 1705, "Emoji: Brainless",   "Standard",   "default/emo_brainless_nodrips"      },
	{ 1706, "Emoji: Despair",     "Standard",   "default/emo_despair_nodrips"        },
	{ 1707, "Emoji: Happy",       "Standard",   "default/emo_happy_nodrips"          },
	{ 1708, "Emoji: Ninja",       "Standard",   "default/emo_ninja_nodrips"          },
	{ 1709, "Emoji: Worry",       "Standard",   "default/emo_worry_nodrips"          },
	{ 1710, "Evil Eye",           "Standard",   "default/evil_eye_nodrips"           },
	{ 1711, "Eyeball",            "Standard",   "default/eyeball_nodrips"            },
	{ 1712, "GG",                 "Standard",   "default/gg_01_nodrips"              },
	{ 1713, "GG 2",               "Standard",   "default/gg_02_nodrips"              },
	{ 1714, "GLHF",               "Standard",   "default/glhf_nodrips"               },
	{ 1715, "Gunsmoke",           "Standard",   "default/gunsmoke_nodrips"           },
	{ 1716, "Butterfly",          "Standard",   "default/hand_butterfly_nodrips"     },
	{ 1717, "Loser",              "Standard",   "default/hand_loser_nodrips"         },
	{ 1718, "Sheriff Hat",        "Standard",   "default/hat_sherif_nodrips"         },
	{ 1719, "RIP Headstone",      "Standard",   "default/headstone_rip_nodrips"      },
	{ 1720, "Heart",              "Standard",   "default/heart_nodrips"              },
	{ 1721, "8-Ball",             "Standard",   "default/hl_eightball_nodrips"       },
	{ 1722, "Lambda",             "Standard",   "default/hl_lambda_nodrips"          },
	{ 1723, "Smiley",             "Standard",   "default/hl_smiley_nodrips"          },
	{ 1724, "Jump Shot",          "Standard",   "default/jump_shot_nodrips"          },
	{ 1725, "Karambit",           "Standard",   "default/karambit_nodrips"           },
	{ 1726, "Knives Crossed",     "Standard",   "default/knives_crossed_nodrips"     },
	{ 1727, "Molotov",            "Standard",   "default/moly_nodrips"               },
	{ 1728, "Dollar Necklace",    "Standard",   "default/necklace_dollar_nodrips"    },
	{ 1729, "No Scope",           "Standard",   "default/no_scope_nodrips"           },
	{ 1730, "Piggles",            "Standard",   "default/piggles_nodrips"            },
	{ 1731, "Popdog",             "Standard",   "default/popdog_nodrips"             },
	{ 1732, "Rooster",            "Standard",   "default/rooster_nodrips"            },
	{ 1733, "Salty",              "Standard",   "default/salty_nodrips"              },
	{ 1734, "Sorry",              "Standard",   "default/sorry_nodrips"              },
	{ 1735, "Tongue",             "Standard",   "default/tongue_nodrips"             },
	{ 1736, "Wings",              "Standard",   "default/wings_nodrips"              },
	{ 1737, "GTG",                "Standard",   "default/gtg_nodrips"                },
	// Capsule Series
	{ 1653, "Blood Boiler",       "Capsule",    "community_mix01/blood_boiler_nodrips"  },
	{ 1654, "Chicken",            "Capsule",    "community_mix01/chicken_nodrips"       },
	{ 1655, "Drug War Veteran",   "Capsule",    "community_mix01/drugwarveteran_nodrips"},
	{ 1656, "Flickshot",          "Capsule",    "community_mix01/flickshot_nodrips"     },
	{ 1657, "Hamster Hawk",       "Capsule",    "community_mix01/hamster_hawk_nodrips"  },
	{ 1658, "Ivette",             "Capsule",    "community_mix01/ivette_nodrips"        },
	{ 1659, "Kawaii Killer CT",   "Capsule",    "community_mix01/kawaiikiller_nodrips"  },
	{ 1660, "Kawaii Killer T",    "Capsule",    "community_mix01/kawaiikiller_t_nodrips"},
	{ 1661, "Martha",             "Capsule",    "community_mix01/martha_nodrips"        },
	{ 1662, "Old School",         "Capsule",    "community_mix01/oldschool_nodrips"     },
	{ 1663, "Pocket BBQ",         "Capsule",    "community_mix01/pocket_bbq_nodrips"    },
	{ 1664, "Rekt",               "Capsule",    "community_mix01/rekt_nodrips"          },
	{ 1665, "Shave Master",       "Capsule",    "community_mix01/shave_master_nodrips"  },
	{ 1666, "Shooting Star",      "Capsule",    "community_mix01/shootingstar_nodrips"  },
	{ 1667, "Skull",              "Capsule",    "community_mix01/skull_nodrips"         },
	{ 1668, "Tamara",             "Capsule",    "community_mix01/tamara_nodrips"        },
	{ 1669, "Unicorn",            "Capsule",    "community_mix01/unicorn_nodrips"       },
	{ 1670, "Winged Defuser",     "Capsule",    "community_mix01/winged_defuser_nodrips"},
	{ 1671, "Ace",                "Capsule",    "valve_sprays/ace_01_nodrips"           },
	{ 1672, "Banana",             "Capsule",    "valve_sprays/banana_nodrips"           },
	{ 1673, "Cerberus",           "Capsule",    "valve_sprays/cerberus_nodrips"         },
	{ 1674, "Clutch",             "Capsule",    "valve_sprays/clutch_01_nodrips"        },
	{ 1675, "Crown (Cap)",        "Capsule",    "valve_sprays/crown_nodrips"            },
	{ 1676, "CT",                 "Capsule",    "valve_sprays/ct_nodrips"               },
	{ 1677, "EZ",                 "Capsule",    "valve_sprays/ez_02_nodrips"            },
	{ 1678, "Fire Serpent",       "Capsule",    "valve_sprays/fireserpent_nodrips"      },
	{ 1679, "Howling Dawn",       "Capsule",    "valve_sprays/howling_dawn_nodrips"     },
	{ 1680, "Kisses",             "Capsule",    "valve_sprays/kisses_nodrips"           },
	{ 1681, "Lemon Squeeze",      "Capsule",    "valve_sprays/lemon_squeeze_nodrips"    },
	{ 1682, "Nice Shot",          "Capsule",    "valve_sprays/nice_shot_color_nodrips"  },
	{ 1683, "Phoenix",            "Capsule",    "valve_sprays/phoenix_nodrips"          },
	{ 1684, "Real MVP",           "Capsule",    "valve_sprays/realmvp_02_nodrips"       },
	{ 1685, "RIP",                "Capsule",    "valve_sprays/ripip_nodrips"            },
	{ 1686, "Target",             "Capsule",    "valve_sprays/target_02_nodrips"        },
	{ 1687, "Welcome Clutch",     "Capsule",    "valve_sprays/welcome_clutch_nodrips"   },
	{ 1688, "Wings (Cap)",        "Capsule",    "valve_sprays/wings_nodrips"            },
	// Standard 2
	{ 3983, "1G",                 "Std2",       "default2019/1g_nodrips"               },
	{ 3984, "200 IQ",             "Std2",       "default2019/200iq_nodrips"            },
	{ 3985, "Applause",           "Std2",       "default2019/applause_nodrips"         },
	{ 3986, "Beep",               "Std2",       "default2019/beep_nodrips"             },
	{ 3987, "Boom",               "Std2",       "default2019/boom_nodrips"             },
	{ 3988, "Bright Star",        "Std2",       "default2019/brightstar_nodrips"       },
	{ 3989, "Broken Heart",       "Std2",       "default2019/brokenheart_nodrips"      },
	{ 3990, "Bubble: Denied",     "Std2",       "default2019/bubble_denied_nodrips"    },
	{ 3991, "Bubble: Question",   "Std2",       "default2019/bubble_question_nodrips"  },
	{ 3992, "Chef Kiss",          "Std2",       "default2019/chef_kiss_nodrips"        },
	{ 3993, "Chick",              "Std2",       "default2019/chick_nodrips"            },
	{ 3994, "Choke",              "Std2",       "default2019/choke_nodrips"            },
	{ 3995, "Chunky Chicken",     "Std2",       "default2019/chunkychicken_nodrips"    },
	{ 3996, "Dead Now",           "Std2",       "default2019/dead_now_nodrips"         },
	{ 3997, "Fart",               "Std2",       "default2019/fart_nodrips"             },
	{ 3998, "Goofy",              "Std2",       "default2019/goofy_nodrips"            },
	{ 3999, "Grimace",            "Std2",       "default2019/grimace_nodrips"          },
	{ 4000, "Happy Cat",          "Std2",       "default2019/happy_cat_nodrips"        },
	{ 4001, "Hop",                "Std2",       "default2019/hop_nodrips"              },
	{ 4002, "Kiss",               "Std2",       "default2019/kiss_nodrips"             },
	{ 4003, "Lightbulb",          "Std2",       "default2019/lightbulb_nodrips"        },
	{ 4004, "Little Crown",       "Std2",       "default2019/little_crown_nodrips"     },
	{ 4005, "Little EZ",          "Std2",       "default2019/little_ez_nodrips"        },
	{ 4006, "Little Birds",       "Std2",       "default2019/littlebirds_nodrips"      },
	{ 4007, "NT",                 "Std2",       "default2019/nt_nodrips"               },
	{ 4008, "Okay",               "Std2",       "default2019/okay_nodrips"             },
	{ 4009, "OMG",                "Std2",       "default2019/omg_nodrips"              },
	{ 4010, "Oops",               "Std2",       "default2019/oops_nodrips"             },
	{ 4011, "Puke",               "Std2",       "default2019/puke_nodrips"             },
	{ 4012, "RLY",                "Std2",       "default2019/rly_nodrips"              },
	{ 4013, "Silver Bullet",      "Std2",       "default2019/silverbullet_nodrips"     },
	{ 4014, "Smarm",              "Std2",       "default2019/smarm_nodrips"            },
	{ 4015, "Smirk",              "Std2",       "default2019/smirk_nodrips"            },
	{ 4016, "Smooch",             "Std2",       "default2019/smooch_nodrips"           },
	{ 4017, "Thoughtful",         "Std2",       "default2019/thoughtfull_nodrips"      },
	{ 4018, "Uh Oh",              "Std2",       "default2019/uhoh_nodrips"             },
	// Weapons
	{ 4631, "AK-47",              "Weapons",    "default2020/ak47_nodrips"             },
	{ 4632, "AUG",                "Weapons",    "default2020/aug_nodrips"              },
	{ 4633, "AWP",                "Weapons",    "default2020/awp_nodrips"              },
	{ 4634, "PP-Bizon",           "Weapons",    "default2020/bizon_nodrips"            },
	{ 4635, "CZ75",               "Weapons",    "default2020/cz_nodrips"               },
	{ 4636, "FAMAS",              "Weapons",    "default2020/famas_nodrips"            },
	{ 4637, "Galil AR",           "Weapons",    "default2020/galil_nodrips"            },
	{ 4638, "M4A1-S",             "Weapons",    "default2020/m4a1_nodrips"             },
	{ 4639, "M4A4",               "Weapons",    "default2020/m4a4_nodrips"             },
	{ 4640, "MAC-10",             "Weapons",    "default2020/mac10_nodrips"            },
	{ 4641, "MP7",                "Weapons",    "default2020/mp7_nodrips"              },
	{ 4642, "MP9",                "Weapons",    "default2020/mp9_nodrips"              },
	{ 4643, "P90",                "Weapons",    "default2020/p90_nodrips"              },
	{ 4644, "SG 553",             "Weapons",    "default2020/sg553_nodrips"            },
	{ 4645, "UMP-45",             "Weapons",    "default2020/ump_nodrips"              },
	{ 4646, "XM1014",             "Weapons",    "default2020/xm1014_nodrips"           },
	// Illuminate / CNY (these already had _nodrips in items_game.txt where applicable)
	{ 2418, "Cheongsam 1",        "CNY",        "illuminate_capsule/cheongsam_1_nodrips"          },
	{ 2419, "Cheongsam 2",        "CNY",        "illuminate_capsule/cheongsam_2_nodrips"          },
	{ 2420, "Chinese Dragon",     "CNY",        "illuminate_capsule/chinese_dragon_nodrips"        },
	{ 2421, "Fury",               "CNY",        "illuminate_capsule/fury_nodrips"                  },
	{ 2422, "God of Fortune",     "CNY",        "illuminate_capsule/god_of_fortune_nodrips"        },
	{ 2423, "Hotpot",             "CNY",        "illuminate_capsule/hotpot_nodrips"                },
	{ 2424, "Koi 2",              "CNY",        "illuminate_capsule/koi_2_nodrips"                 },
	{ 2425, "Longevity",          "CNY",        "illuminate_capsule/longevity_nodrips"             },
	{ 2426, "Nezha",              "CNY",        "illuminate_capsule/nezha_nodrips"                 },
	{ 2427, "Noodles",            "CNY",        "illuminate_capsule/noodles_nodrips"               },
	{ 2428, "Panda",              "CNY",        "illuminate_capsule/panda_nodrips"                 },
	{ 2429, "Pixiu",              "CNY",        "illuminate_capsule/pixiu_nodrips"                 },
	{ 2430, "Red Koi",            "CNY",        "illuminate_capsule/red_koi_nodrips"               },
	{ 2431, "Rice",               "CNY",        "illuminate_capsule/rice_nodrips"                  },
	{ 2432, "Rice Pudding",       "CNY",        "illuminate_capsule/rice_pudding_nodrips"          },
	{ 2433, "Shaolin",            "CNY",        "illuminate_capsule/shaolin_1_nodrips"             },
	{ 2434, "Toy Tiger",          "CNY",        "illuminate_capsule/toytiger_nodrips"              },
	{ 2435, "Zombie",             "CNY",        "illuminate_capsule/zombie_nodrips"                },
};

// ==================== GLOBALS ====================
Database  g_hDB;
int       g_iPlayerGraffiti[MAXPLAYERS + 1] = {-1, ...};
bool      g_bDataLoaded[MAXPLAYERS + 1];
float     g_flLastSpray[MAXPLAYERS + 1];
int       g_iPlayerDecalEnt[MAXPLAYERS + 1] = {-1, ...};

#define SPRAY_DISTANCE   128.0  // max distance to spray on wall

float g_flSprayCooldown = 10.0; // adjustable via !spraycooldown

public Plugin myinfo =
{
	name        = "CS:GO Graffiti Selector",
	author      = "Assistant",
	description = "Oyunculara tum graffiti secimi ve spray komutu, SQLite ile kaydedilir",
	version     = "1.0",
	url         = ""
};

// ==================== INIT ====================
public void OnPluginStart()
{
	Database.Connect(SQL_OnConnect, "storage-local");

	// TO BE CONTINUED: Graffiti system temporarily deactivated
	// RegConsoleCmd("sm_graffiti", Cmd_Graffiti, "Graffiti secim menusu");
	// RegConsoleCmd("sm_spray", Cmd_SprayDirect, "Graffiti Cizer");
	// RegAdminCmd("sm_spraycooldown", Cmd_SprayCooldown, ADMFLAG_CHANGEMAP, "Spray bekleme suresini ayarla");

	// AddCommandListener(Hook_SprayMenu, "+spray_menu");

	PrintToServer("[Graffiti] Plugin yuklendi (Deactivated).");
}

public void OnMapStart()
{
	if (!DirExists("materials")) CreateDirectory("materials", 511);
	if (!DirExists("materials/decals")) CreateDirectory("materials/decals", 511);
	if (!DirExists("materials/decals/custom_gen")) CreateDirectory("materials/decals/custom_gen", 511);

	int total = sizeof(g_Graffiti);
	for (int i = 0; i < total; i++)
	{
		// Sadece dosya adını alalım (örn: "crown_nodrips")
		char materialPath[128];
		strcopy(materialPath, sizeof(materialPath), g_Graffiti[i].material);
		
		char baseName[64];
		int lastSlash = -1;
		for (int j = strlen(materialPath) - 1; j >= 0; j--) {
			if (materialPath[j] == '/') {
				lastSlash = j;
				break;
			}
		}
		
		if (lastSlash != -1) {
			strcopy(baseName, sizeof(baseName), materialPath[lastSlash + 1]);
		} else {
			strcopy(baseName, sizeof(baseName), materialPath);
		}

		char vmtPath[PLATFORM_MAX_PATH];
		Format(vmtPath, sizeof(vmtPath), "materials/decals/custom_gen/%s.vmt", baseName);
		
		File f = OpenFile(vmtPath, "w");
		if (f != null) {
			f.WriteLine("\"LightmappedGeneric\"");
			f.WriteLine("{");
			f.WriteLine("\t\"$basetexture\" \"decals/sprays/%s\"", materialPath);
			f.WriteLine("\t\"$translucent\" 1");
			f.WriteLine("\t\"$decal\" 1");
			f.WriteLine("\t\"$vertexcolor\" 1");
			f.WriteLine("\t\"$vertexalpha\" 1");
			f.WriteLine("\t\"$decalscale\" 0.125");
			f.WriteLine("}");
			delete f;
		}

		char downloadPath[PLATFORM_MAX_PATH];
		Format(downloadPath, sizeof(downloadPath), "materials/decals/custom_gen/%s.vmt", baseName);
		AddFileToDownloadsTable(downloadPath);
		
		char precachePath[128];
		Format(precachePath, sizeof(precachePath), "decals/custom_gen/%s", baseName);
		PrecacheDecal(precachePath, true);
	}
}

// ==================== DB ====================
public void SQL_OnConnect(Database db, const char[] error, any data)
{
	if (db == null) { LogError("[Graffiti] DB Hatasi: %s", error); return; }
	g_hDB = db;
	g_hDB.SetCharset("utf8");
	g_hDB.Query(SQL_TableCreated,
		"CREATE TABLE IF NOT EXISTS graffiti_prefs ("
		... "  steamid     TEXT    PRIMARY KEY,"
		... "  graffiti_id INTEGER NOT NULL DEFAULT -1"
		... ");");
}

public void SQL_TableCreated(Database db, DBResultSet results, const char[] error, any data)
{
	if (error[0]) LogError("[Graffiti] Tablo hatasi: %s", error);
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client)) return;
	g_iPlayerGraffiti[client] = -1;
	g_bDataLoaded[client]     = false;
	g_flLastSpray[client]     = 0.0;
	LoadClientData(client);
}

public void OnClientDisconnect(int client)
{
	g_iPlayerGraffiti[client] = -1;
	g_bDataLoaded[client]     = false;
	
	if (g_iPlayerDecalEnt[client] != -1 && IsValidEntity(g_iPlayerDecalEnt[client]))
	{
		AcceptEntityInput(g_iPlayerDecalEnt[client], "Kill");
	}
	g_iPlayerDecalEnt[client] = -1;
}

void LoadClientData(int client)
{
	if (g_hDB == null) return;
	char steamid[32];
	if (!GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid))) return;
	char query[256];
	Format(query, sizeof(query),
		"SELECT graffiti_id FROM graffiti_prefs WHERE steamid = '%s' LIMIT 1;", steamid);
	g_hDB.Query(SQL_OnLoad, query, GetClientUserId(client));
}

public void SQL_OnLoad(Database db, DBResultSet results, const char[] error, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return;
	if (error[0]) { LogError("[Graffiti] Yukleme hatasi: %s", error); return; }
	if (results.FetchRow())
	{
		int itemId = results.FetchInt(0);
		g_iPlayerGraffiti[client] = FindIndexById(itemId);
	}
	g_bDataLoaded[client] = true;
}

void SaveClientData(int client)
{
	if (g_hDB == null) return;
	char steamid[32];
	if (!GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid))) return;
	int itemId = (g_iPlayerGraffiti[client] >= 0) ? g_Graffiti[g_iPlayerGraffiti[client]].id : -1;
	char query[256];
	Format(query, sizeof(query),
		"INSERT OR REPLACE INTO graffiti_prefs (steamid, graffiti_id) VALUES ('%s', %d);",
		steamid, itemId);
	g_hDB.Query(SQL_OnSave, query);
}

public void SQL_OnSave(Database db, DBResultSet results, const char[] error, any data)
{
	if (error[0]) LogError("[Graffiti] Kayit hatasi: %s", error);
}

// ==================== SPRAY COMMAND ====================
public Action Hook_SprayMenu(int client, const char[] command, int argc)
{
	Cmd_SprayDirect(client, 0);
	return Plugin_Handled;
}

public Action Cmd_SprayDirect(int client, int args)
{
	if (!client) return Plugin_Handled;
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		PrintToChat(client, " \x01[\x06Graffiti\x01] \x07Spray icin hayatta olmalisin!");
		return Plugin_Handled;
	}
	if (g_iPlayerGraffiti[client] < 0)
	{
		PrintToChat(client, " \x01[\x06Graffiti\x01] \x07Once !graffiti yazarak bir seçim yap!");
		return Plugin_Handled;
	}

	float now = GetGameTime();
	float elapsed = now - g_flLastSpray[client];
	if (elapsed < g_flSprayCooldown)
	{
		int remaining = RoundToFloor(g_flSprayCooldown - elapsed);
		PrintToChat(client, " \x01[\x06Graffiti\x01] \x07Bekleme suresi: %d saniye", remaining);
		return Plugin_Handled;
	}

	// Trace from eye to find wall
	float eyePos[3], eyeAng[3], endPos[3];
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);

	Handle tr = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceFilter_NoPlayers, client);
	if (!TR_DidHit(tr))
	{
		delete tr;
		PrintToChat(client, " \x01[\x06Graffiti\x01] \x07Duvara bak ve tekrar dene!");
		return Plugin_Handled;
	}

	TR_GetEndPosition(endPos, tr);
	delete tr;

	// Check distance
	float dist = GetVectorDistance(eyePos, endPos);
	if (dist > SPRAY_DISTANCE)
	{
		PrintToChat(client, " \x01[\x06Graffiti\x01] \x07Duvara daha yakın dur! (max %dm)", RoundToFloor(SPRAY_DISTANCE));
		return Plugin_Handled;
	}

	// Use info_decal entity to place the graffiti on the wall
	// Find the graffiti ID from idx
	int idx = g_iPlayerGraffiti[client];
	int gId = g_Graffiti[idx].id;
	DoInfoDecalFallback(client, gId);
	
	return Plugin_Handled;
}

// ==================== COOLDOWN COMMAND ====================
public Action Cmd_SprayCooldown(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Graffiti] Kullanim: !spraycooldown <saniye> (0 = sinirsiz) | Mevcut: %.0f sn", g_flSprayCooldown);
		return Plugin_Handled;
	}

	char arg[16];
	GetCmdArg(1, arg, sizeof(arg));
	float newVal = StringToFloat(arg);

	if (newVal < 0.0)    newVal = 0.0;
	if (newVal > 3600.0) newVal = 3600.0;

	g_flSprayCooldown = newVal;

	if (newVal == 0.0)
		PrintToChatAll(" \x01[\x06Graffiti\x01] Admin spray bekleme suresini \x0Bsifirladi \x01(sinirsiz)!");
	else
		PrintToChatAll(" \x01[\x06Graffiti\x01] Admin spray bekleme suresi: \x0B%.0f saniye\x01!", newVal);

	return Plugin_Handled;
}

// ==================== INFO DECAL ====================
public void DoInfoDecalFallback(int client, int gId)
{
	float pos[3]; GetClientEyePosition(client, pos);
	float ang[3]; GetClientEyeAngles(client, ang);
	
	Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter_NoPlayers, client);
	if (TR_DidHit(tr))
	{
		float end[3];
		TR_GetEndPosition(end, tr);
		
		int index = -1;
		int total = sizeof(g_Graffiti);
		for (int i = 0; i < total; i++)
		{
			if (g_Graffiti[i].id == gId)
			{
				index = i;
				break;
			}
		}
		
		if (index != -1)
		{
			char materialPath[128];
			strcopy(materialPath, sizeof(materialPath), g_Graffiti[index].material);
			
			char baseName[64];
			int lastSlash = -1;
			for (int j = strlen(materialPath) - 1; j >= 0; j--) {
				if (materialPath[j] == '/') {
					lastSlash = j;
					break;
				}
			}
			
			if (lastSlash != -1) {
				strcopy(baseName, sizeof(baseName), materialPath[lastSlash + 1]);
			} else {
				strcopy(baseName, sizeof(baseName), materialPath);
			}
			
			char texturePath[128];
			Format(texturePath, sizeof(texturePath), "decals/custom_gen/%s", baseName);
			
			int decalIndex = PrecacheDecal(texturePath, true);
			
			TE_Start("BSP Decal");
			TE_WriteVector("m_vecOrigin", end);
			TE_WriteNum("m_nEntity", 0); // World Entity
			TE_WriteNum("m_nIndex", decalIndex);
			TE_SendToAll();
			
			g_flLastSpray[client] = GetGameTime();
			PrintToChat(client, " \x01[\x06Graffiti\x01] \x0B%s \x01sprey yapıldı!", g_Graffiti[index].name);
		}
	}
	delete tr;
}

bool TraceFilter_NoPlayers(int entity, int contentsMask, any data)
{
	return entity != data && entity > MaxClients;
}

// ==================== MENU ====================
public Action Cmd_Graffiti(int client, int args)
{
	if (!client) return Plugin_Handled;
	OpenCategoryMenu(client);
	return Plugin_Handled;
}

void OpenCategoryMenu(int client)
{
	Menu menu = new Menu(MenuH_Category);
	menu.SetTitle("Graffiti Sec - Kategori");
	menu.AddItem("Standard",  "Standard (41 adet)");
	menu.AddItem("Std2",      "Standard 2 (36 adet)");
	menu.AddItem("Capsule",   "Capsule (36 adet)");
	menu.AddItem("Weapons",   "Silahlar (16 adet)");
	menu.AddItem("CNY",       "Illuminate/CNY (18 adet)");
	menu.Display(client, 60);
}

public int MenuH_Category(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char cat[16];
		menu.GetItem(param2, cat, sizeof(cat));
		OpenGraffitiMenu(param1, cat);
	}
	else if (action == MenuAction_End) delete menu;
	return 0;
}

void OpenGraffitiMenu(int client, const char[] category)
{
	Menu menu = new Menu(MenuH_Graffiti);
	char title[64];
	Format(title, sizeof(title), "Graffiti - %s", category);
	menu.SetTitle(title);

	if (g_iPlayerGraffiti[client] >= 0)
	{
		char cur[80];
		Format(cur, sizeof(cur), "[ Secili: %s ]", g_Graffiti[g_iPlayerGraffiti[client]].name);
		menu.AddItem("-1", cur, ITEMDRAW_DISABLED);
	}

	int total = sizeof(g_Graffiti);
	for (int i = 0; i < total; i++)
	{
		if (!StrEqual(g_Graffiti[i].category, category)) continue;
		char idxStr[8];
		IntToString(i, idxStr, sizeof(idxStr));
		char label[72];
		Format(label, sizeof(label), "%s%s",
			(g_iPlayerGraffiti[client] == i) ? "✔ " : "",
			g_Graffiti[i].name);
		menu.AddItem(idxStr, label);
	}

	menu.ExitBackButton = true;
	menu.Display(client, 60);
}

public int MenuH_Graffiti(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char idxStr[8];
		menu.GetItem(param2, idxStr, sizeof(idxStr));
		int i = StringToInt(idxStr);
		if (i < 0) return 0;

		g_iPlayerGraffiti[param1] = i;
		SaveClientData(param1);

		PrintToChat(param1, " \x01[\x06Graffiti\x01] Secildi: \x0B%s \x01- Duvara sprey icin: \x04!spray", g_Graffiti[i].name);
		OpenGraffitiMenu(param1, g_Graffiti[i].category);
	}
	else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
		OpenCategoryMenu(param1);
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}

// ==================== HELPERS ====================
int FindIndexById(int itemId)
{
	int total = sizeof(g_Graffiti);
	for (int i = 0; i < total; i++)
		if (g_Graffiti[i].id == itemId) return i;
	return -1;
}

