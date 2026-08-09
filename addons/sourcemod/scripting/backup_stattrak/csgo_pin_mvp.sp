#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

Database g_db = null;
int g_iPlayerMusic[MAXPLAYERS + 1] = {0, ...};
bool g_bDataLoaded[MAXPLAYERS + 1] = {false, ...};

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
	RegConsoleCmd("sm_music", Command_Mvp);
	RegAdminCmd("sm_mvptest", Command_MvpTest, ADMFLAG_ROOT, "Test MVP Music Kit");
	
	HookEvent("player_spawn", Event_PlayerSpawn);
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
		
		if(g_db != null)
		{
			char query[256];
			Format(query, sizeof(query), "SELECT music_id FROM mvp_music_prefs WHERE steamid = '%s'", auth);
			g_db.Query(SQL_OnClientLoad, query, GetClientUserId(client));
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

public void OnClientDisconnect(int client)
{
	g_bDataLoaded[client] = false;
	g_iPlayerMusic[client] = -1;
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
	menu.AddItem("", "--- Music List ---", ITEMDRAW_DISABLED);
	
	for(int i = 0; i < sizeof(g_MusicIDs); i++)
	{
		char idStr[16];
		IntToString(g_MusicIDs[i], idStr, sizeof(idStr));
		menu.AddItem(idStr, g_MusicNames[i], (g_MusicIDs[i] == g_iPlayerMusic[client]) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
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
	
	Event mvpEvent = CreateEvent("round_mvp");
	if(mvpEvent != null)
	{
		mvpEvent.SetInt("userid", GetClientUserId(client));
		mvpEvent.SetInt("reason", 0);
		mvpEvent.SetInt("value", 0);
		mvpEvent.SetInt("musickitmvps", 0);
		mvpEvent.SetInt("nomusic", 0);
		mvpEvent.FireToClient(client);
	}
	
	Event panelEvent = CreateEvent("cs_win_panel_round");
	if(panelEvent != null)
	{
		panelEvent.SetInt("final_event", 0);
		panelEvent.SetString("funfact_token", "");
		panelEvent.FireToClient(client);
	}
	
	// Create a 5 second timer to clear the stuck panel
	CreateTimer(5.0, Timer_ClearMvpPanel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Handled;
}

public Action Timer_ClearMvpPanel(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(client > 0 && IsClientInGame(client))
	{
		Event startEvent = CreateEvent("round_start");
		if(startEvent != null)
		{
			startEvent.FireToClient(client);
		}
	}
	return Plugin_Handled;
}


