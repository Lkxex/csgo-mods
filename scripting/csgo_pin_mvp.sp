#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

Database g_db = null;
int g_iPlayerMusic[MAXPLAYERS + 1] = {0, ...};
bool g_bDataLoaded[MAXPLAYERS + 1] = {false, ...};

// --- StatTrak Variables ---
bool g_bStatTrakEnabled[MAXPLAYERS + 1] = {false, ...};
int g_iStatTrakCounts[MAXPLAYERS + 1][64]; // Supports up to 64 music kits dynamically
float g_flLastMvpTime[MAXPLAYERS + 1] = {0.0, ...};
Handle g_hMvpTimer[MAXPLAYERS + 1] = {null, ...};

// --- Lifecycle Management Globals ---
int g_iPendingQueries = 0;
bool g_bShuttingDown = false;
Handle g_hShutdownTimer = null;

// --- Verified Music Kit IDs ---
int g_MusicIDs[] = {
	0
	,2
	,3
	,4
	,5
	,6
	,7
	,8
	,9
	,10
	,11
	,12
	,13
	,14
	,15
	,16
	,17
	,18
	,19
	,20
	,21
	,22
	,23
	,24
	,25
	,26
	,27
	,28
	,29
	,30
	,31
	,39
	,40
	,41
	,42
	,50
	,51
	,52
	,53
	,60
	,61
	,68
	,69
	,70
};

char g_MusicNames[][64] = {
	"No Music Kit (Reset)"
	,"CS:GO (Default)"
	,"Daniel Sadowski, Crimson Assault"
	,"Noisia, Sharpened"
	,"Robert Allaire, Insurgency"
	,"Sean Murray, A*D*8"
	,"Feed Me, High Noon"
	,"Dren, Death's Head Demolition"
	,"Austin Wintory, Desert Fire"
	,"Sasha, LNOE"
	,"Skog, Metal"
	,"Midnight Riders, All I Want for Christmas"
	,"Matt Lange, IsoRhythm"
	,"Mateo Messina, For No Mankind"
	,"Various Artists, Hotline Miami"
	,"Daniel Sadowski, Total Domination"
	,"Damjan Mravunac, The Talos Principle"
	,"Proxy, Battlepack"
	,"Ki:Theory, MOLOTOV"
	,"Troels Folmann, Uber Blasto Phone"
	,"Kelly Bailey, Hazardous Environments"
	,"Skog, II-Headshot"
	,"Daniel Sadowski, The 8-Bit Kit"
	,"AWOLNATION, I Am"
	,"Mord Fustang, Diamonds"
	,"Michael Bross, Invasion!"
	,"Ian Hultquist, Lion's Mouth"
	,"New Beat Fund, Sponge Fingerz"
	,"Beartooth, Disgusting"
	,"Lennie Moore, Java Havana Funkaloo"
	,"Darude, Moments CSGO"
	,"The Verkkars, EZ4ENCE"
	,"Halo, The Master Chief Collection"
	,"Scarlxrd: King, Scar"
	,"Half-Life: Alyx, Anti-Citizen"
	,"Amon Tobin, All for Dust"
	,"Darren Korb, Hades Music Kit"
	,"Neck Deep, The Lowlife Pack"
	,"Scarlxrd, CHAIN$AW.LXADXUT."
	,"bbno$, u mad!"
	,"The Verkkars & n0thing, Flashbang Dance"
	,"Perfect World, ?? Hua Lian (Painted Face)"
	,"Denzel Curry, ULTIMATE"
	,"CS:GO"
};

public Plugin myinfo = 
{
	name = "CS:GO MVP Music Kits",
	author = "Assistant",
	description = "Allows players to choose MVP Music Kits",
	version = "1.2",
	url = ""
};

public void OnPluginStart()
{
	Database.Connect(SQL_OnConnect, "storage-local");
	
	RegConsoleCmd("sm_mvp", Command_Mvp);
	RegAdminCmd("sm_mvptest", Command_MvpTest, ADMFLAG_ROOT, "Test MVP Music Kit");
	
	HookEvent("round_mvp", Event_RoundMvp_Post, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn);
}

public void OnPluginEnd()
{
	// Graceful shutdown: wait for pending queries
	TryGracefulShutdown("Plugin unload");
	
	if(g_hShutdownTimer != null)
	{
		KillTimer(g_hShutdownTimer);
		g_hShutdownTimer = null;
	}
	
	if(g_db != null)
	{
		delete g_db;
		g_db = null;
	}
}

public void SQL_OnConnect(Database db, const char[] error, any data)
{
	if(db == null)
	{
		LogError("Database connection error: %s", error);
		return;
	}
	
	g_db = db;
	
	// Create new simplified table
	char query[512];
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS mvp_music_prefs (steamid VARCHAR(32) PRIMARY KEY, music_id INTEGER DEFAULT 0)");
	g_db.Query(SQL_CheckError, query);
	
	// Migrate data from old table if possible (best-effort)
	Format(query, sizeof(query), "INSERT OR IGNORE INTO mvp_music_prefs (steamid, music_id) SELECT steamid, music_id FROM pin_mvp_prefs");
	g_db.Query(SQL_CheckError, query);
	
	// Create StatTrak tables
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS custom_mvp_stattrak_settings (steamid VARCHAR(32) PRIMARY KEY, enabled INTEGER NOT NULL DEFAULT 0)");
	g_db.Query(SQL_CheckError, query);
	
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS custom_mvp_stattrak_counters (steamid VARCHAR(32) NOT NULL, music_id INTEGER NOT NULL, mvp_count INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (steamid, music_id))");
	g_db.Query(SQL_CheckError, query);
}

public void SQL_CheckError(Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0])
	{
		LogError("SQL Query Error: %s", error);
	}
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if(!IsFakeClient(client))
	{
		g_bDataLoaded[client] = false;
		g_iPlayerMusic[client] = -1;
		g_bStatTrakEnabled[client] = false;
		for(int i = 0; i < sizeof(g_MusicIDs); i++)
		{
			g_iStatTrakCounts[client][i] = 0;
		}
		
		if(g_db != null)
		{
			char query[256];
			Format(query, sizeof(query), "SELECT music_id FROM mvp_music_prefs WHERE steamid = '%s'", auth);
			g_db.Query(SQL_OnClientLoad, query, GetClientUserId(client));
			
			char query2[256];
			Format(query2, sizeof(query2), "SELECT enabled FROM custom_mvp_stattrak_settings WHERE steamid = '%s'", auth);
			g_db.Query(SQL_OnClientLoadSettings, query2, GetClientUserId(client));
			
			char query3[256];
			Format(query3, sizeof(query3), "SELECT music_id, mvp_count FROM custom_mvp_stattrak_counters WHERE steamid = '%s'", auth);
			g_db.Query(SQL_OnClientLoadCounters, query3, GetClientUserId(client));
		}
	}
}

public void SQL_OnClientLoad(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if(!client) return;
	
	if(error[0])
	{
		LogError("SQL Load Error: %s", error);
		return;
	}
	
	if(results.FetchRow())
	{
		g_iPlayerMusic[client] = results.FetchInt(0);
	}
	g_bDataLoaded[client] = true;
	
	if(IsClientInGame(client))
	{
		ApplyPlayerSettings(client);
	}
}

public void SQL_OnClientLoadSettings(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if(!client) return;
	
	if(error[0])
	{
		LogError("SQL Load Settings Error: %s", error);
		return;
	}
	
	if(results.FetchRow())
	{
		g_bStatTrakEnabled[client] = results.FetchInt(0) != 0;
	}
}

public void SQL_OnClientLoadCounters(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if(!client) return;
	
	if(error[0])
	{
		LogError("SQL Load Counters Error: %s", error);
		return;
	}
	
	while(results.FetchRow())
	{
		int music_id = results.FetchInt(0);
		int mvp_count = results.FetchInt(1);
		
		for(int i = 0; i < sizeof(g_MusicIDs); i++)
		{
			if(g_MusicIDs[i] == music_id)
			{
				g_iStatTrakCounts[client][i] = mvp_count;
				break;
			}
		}
	}
}

public void OnClientDisconnect(int client)
{
	g_bDataLoaded[client] = false;
	g_iPlayerMusic[client] = -1;
	if (g_hMvpTimer[client] != null)
	{
		KillTimer(g_hMvpTimer[client]);
		g_hMvpTimer[client] = null;
	}
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client > 0 && g_bDataLoaded[client])
	{
		ApplyPlayerSettings(client);
	}
	return Plugin_Continue;
}

void ApplyPlayerSettings(int client)
{
	if(!IsClientInGame(client)) return;
	
	if(g_iPlayerMusic[client] >= 0)
	{
		SetEntProp(client, Prop_Send, "m_unMusicID", g_iPlayerMusic[client]);
	}
}

void SavePlayerSettings(int client)
{
	char auth[32];
	if(GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)))
	{
		char query[512];
		Format(query, sizeof(query), "REPLACE INTO mvp_music_prefs (steamid, music_id) VALUES ('%s', %d)", auth, g_iPlayerMusic[client]);
		g_db.Query(SQL_CheckError, query);
	}
}

void SaveStatTrakSetting(int client)
{
	if(g_db == null) return;
	char auth[32];
	if(GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)))
	{
		char query[512];
		Format(query, sizeof(query), "REPLACE INTO custom_mvp_stattrak_settings (steamid, enabled) VALUES ('%s', %d)", auth, g_bStatTrakEnabled[client] ? 1 : 0);
		g_iPendingQueries++;
		g_db.Query(SQL_OnSettingsSave, query);
	}
}

void SaveStatTrakCount(int client, int music_id, int count)
{
	if(g_db == null) 
	{
		LogError("Cannot save StatTrak: Database not connected");
		return;
	}
	
	char auth[32];
	if(!GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)))
	{
		LogError("Cannot save StatTrak: Failed to get AuthId for client %d", client);
		return;
	}
	
	char query[512];
	Format(query, sizeof(query), "REPLACE INTO custom_mvp_stattrak_counters (steamid, music_id, mvp_count) VALUES ('%s', %d, %d)", auth, music_id, count);
	g_iPendingQueries++;
	g_db.Query(SQL_OnStatTrakSave, query);
}

public void SQL_OnStatTrakSave(Database db, DBResultSet results, const char[] error, any data)
{
	g_iPendingQueries--;
	
	if(error[0])
	{
		LogError("StatTrak save failed: %s", error);
	}
	
	CheckShutdown();
}

public void SQL_OnSettingsSave(Database db, DBResultSet results, const char[] error, any data)
{
	g_iPendingQueries--;
	
	if(error[0])
	{
		LogError("StatTrak settings save failed: %s", error);
	}
	
	CheckShutdown();
}

void CheckShutdown()
{
	if(g_bShuttingDown && g_iPendingQueries <= 0)
	{
		if(g_hShutdownTimer != null)
		{
			KillTimer(g_hShutdownTimer);
			g_hShutdownTimer = null;
		}
		g_bShuttingDown = false;
		LogMessage("All pending queries completed. Shutdown safe.");
	}
}

Action TryGracefulShutdown(const char[] context)
{
	if(g_iPendingQueries > 0)
	{
		LogMessage("%s: Waiting for %d pending queries to complete...", context, g_iPendingQueries);
		g_bShuttingDown = true;
		
		// Wait up to 2.0 seconds for queries to complete
		g_hShutdownTimer = CreateTimer(2.0, Timer_ForceShutdown, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled; // Indicate we're handling shutdown gracefully
	}
	return Plugin_Continue;
}

public Action Timer_ForceShutdown(Handle timer)
{
	g_hShutdownTimer = null;
	
	if(g_iPendingQueries > 0)
	{
		LogWarning("Force shutdown: %d queries did not complete in time. Data may be lost.", g_iPendingQueries);
	}
	
	g_bShuttingDown = false;
	return Plugin_Stop;
}

public Action Event_RoundMvp_Post(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	if(client <= 0 || !IsClientInGame(client))
	{
		LogMessage("round_mvp: Invalid client for userid %d (client index: %d, in-game: %s)", 
			userid, client, client > 0 ? "yes" : "no");
		return Plugin_Continue;
	}
	
	if(g_bStatTrakEnabled[client] && g_iPlayerMusic[client] > 0)
	{
		// Prevent double counting within same round
		if(GetGameTime() - g_flLastMvpTime[client] < 2.0)
		{
			int kitIdx = -1;
			for(int i = 0; i < sizeof(g_MusicIDs); i++)
			{
				if(g_MusicIDs[i] == g_iPlayerMusic[client]) { kitIdx = i; break; }
			}
			if(kitIdx != -1) { event.SetInt("musickitmvps", g_iStatTrakCounts[client][kitIdx]); }
			return Plugin_Continue;
		}
		g_flLastMvpTime[client] = GetGameTime();
		
		int kitIndex = -1;
		for(int i = 0; i < sizeof(g_MusicIDs); i++)
		{
			if(g_MusicIDs[i] == g_iPlayerMusic[client])
			{
				kitIndex = i;
				break;
			}
		}
		
		if(kitIndex != -1)
		{
			g_iStatTrakCounts[client][kitIndex]++;
			SaveStatTrakCount(client, g_MusicIDs[kitIndex], g_iStatTrakCounts[client][kitIndex]);
			
			event.SetInt("musickitmvps", g_iStatTrakCounts[client][kitIndex]);
		}
	}
	return Plugin_Continue;
}

public Action Command_Mvp(int client, int args)
{
	if(!client || !IsClientInGame(client)) return Plugin_Handled;
	
	Menu menu = new Menu(MenuHandler_Mvp);
	menu.SetTitle("==== [ MUSIC KITS ] ====\n ");
	menu.AddItem("", "--- Selected Music ---", ITEMDRAW_DISABLED);
	
	char currentMusicName[64] = "None";
	for(int i = 0; i < sizeof(g_MusicIDs); i++)
	{
		if(g_MusicIDs[i] == g_iPlayerMusic[client])
		{
			strcopy(currentMusicName, sizeof(currentMusicName), g_MusicNames[i]);
			break;
		}
	}
	menu.AddItem("", currentMusicName, ITEMDRAW_DISABLED);
	
	menu.AddItem("", " ", ITEMDRAW_SPACER);
	
	char statTrakStr[64];
	Format(statTrakStr, sizeof(statTrakStr), "StatTrak™ MVP: [%s]", g_bStatTrakEnabled[client] ? "ON" : "OFF");
	menu.AddItem("stattrak_toggle", statTrakStr);
	
	menu.AddItem("", " ", ITEMDRAW_SPACER);
	menu.AddItem("", "--- Music List ---", ITEMDRAW_DISABLED);
	
	for(int i = 0; i < sizeof(g_MusicIDs); i++)
	{
		char idStr[16];
		IntToString(g_MusicIDs[i], idStr, sizeof(idStr));
		
		char displayStr[128];
		if (g_bStatTrakEnabled[client] && g_iStatTrakCounts[client][i] > 0 && g_MusicIDs[i] > 0)
		{
			Format(displayStr, sizeof(displayStr), "%s [\xe2\x98\x85 %d]", g_MusicNames[i], g_iStatTrakCounts[client][i]);
		}
		else
		{
			strcopy(displayStr, sizeof(displayStr), g_MusicNames[i]);
		}
		
		menu.AddItem(idStr, displayStr, (g_MusicIDs[i] == g_iPlayerMusic[client]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_Mvp(Menu menu, MenuAction action, int client, int selection)
{
	if(action == MenuAction_Select)
	{
		if(!IsClientInGame(client)) return 0;
		char idStr[16];
		menu.GetItem(selection, idStr, sizeof(idStr));
		
		if(StrEqual(idStr, "stattrak_toggle"))
		{
			g_bStatTrakEnabled[client] = !g_bStatTrakEnabled[client];
			SaveStatTrakSetting(client);
			Command_Mvp(client, 0); // Re-open menu
			return 0;
		}
		
		g_iPlayerMusic[client] = StringToInt(idStr);
		SavePlayerSettings(client);
		ApplyPlayerSettings(client);
		
		PrintToChat(client, " \x04[MVP]\x01 Your music kit has been updated.");
		Command_Mvp(client, 0);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
}

public Action Command_MvpTest(int client, int args)
{
	if(!client || !IsClientInGame(client)) return Plugin_Handled;
	
	// Kill existing timer to prevent cutting off the new test
	if (g_hMvpTimer[client] != null)
	{
		KillTimer(g_hMvpTimer[client]);
		g_hMvpTimer[client] = null;
	}
	
	// 1. Fake round_start to clean up previous test/music/panel
	Event startEvent = CreateEvent("round_start");
	if(startEvent != null)
	{
		startEvent.FireToClient(client);
	}
	
	// 2. Fake round_mvp for Music Kit Anthem and MVP star
	Event mvpEvent = CreateEvent("round_mvp");
	if(mvpEvent != null)
	{
		mvpEvent.SetInt("userid", GetClientUserId(client));
		mvpEvent.SetInt("reason", 0);
		mvpEvent.SetInt("value", 0);
		
		int fakeCount = 0;
		if(g_bStatTrakEnabled[client] && g_iPlayerMusic[client] > 0)
		{
			for(int i = 0; i < sizeof(g_MusicIDs); i++)
			{
				if(g_MusicIDs[i] == g_iPlayerMusic[client])
				{
					fakeCount = g_iStatTrakCounts[client][i];
					break;
				}
			}
		}
		
		mvpEvent.SetInt("musickitmvps", fakeCount);
		mvpEvent.SetInt("nomusic", 0);
		mvpEvent.FireToClient(client);
	}
	
	// 3. Fake cs_win_panel_round for funfacts
	Event panelEvent = CreateEvent("cs_win_panel_round");
	if(panelEvent != null)
	{
		panelEvent.SetInt("final_event", 0);
		panelEvent.SetString("funfact_token", "");
		panelEvent.FireToClient(client);
	}
	
	// 15 seconds timer to naturally allow music to finish before cleanup
	g_hMvpTimer[client] = CreateTimer(15.0, Timer_ClearMvpPanel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action Timer_ClearMvpPanel(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(client > 0 && IsClientInGame(client))
	{
		g_hMvpTimer[client] = null;
		Event startEvent = CreateEvent("round_start");
		if(startEvent != null)
		{
			startEvent.FireToClient(client);
		}
	}
	return Plugin_Handled;
}


