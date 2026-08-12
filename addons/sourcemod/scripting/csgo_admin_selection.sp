#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <admin_selection>

#pragma semicolon 1
#pragma newdecls required

Database g_db = null;

// Track whether this plugin has granted ADMFLAG_GENERIC to a user
bool g_bTempAdmins[MAXPLAYERS + 1] = {false, ...};
bool g_bPersistentAdmins[MAXPLAYERS + 1] = {false, ...};

bool g_bSingleplayerMode = true;
int g_SingleplayerHostAccountID = 0;

public Plugin myinfo = 
{
	name = "Admin Selection API",
	author = "Assistant",
	description = "Centralized Admin Selection System",
	version = "1.0",
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("AdminSelection_IsAdmin", Native_IsAdmin);
	CreateNative("AdminSelection_HasFlag", Native_HasFlag);
	CreateNative("AdminSelection_GetFlags", Native_GetFlags);
	CreateNative("AdminSelection_IsActive", Native_IsActive);
	
	RegPluginLibrary("admin_selection");
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	Database.Connect(SQL_OnConnect, "storage-local");
	
	RegConsoleCmd("sm_adminsec", Command_AdminSec, "Set temporary admin");
	RegConsoleCmd("sm_adminseckal", Command_AdminSecKal, "Set persistent admin");
	RegConsoleCmd("sm_adminseckaldir", Command_AdminSecKaldir, "Remove persistent admin");
	
	RegConsoleCmd("sm_multiplayer", Command_MultiplayerMod, "Enable custom admin system (Multiplayer mode)");
	
	AddCommandListener(Command_BlockAdminMenu, "sm_admin");
	
	PrintToServer("[Admin Selection] Sunucu Singleplayer modunda baslatildi. Ozel admin sistemi kapali. !multiplayer ile aktiflestirin.");
}

public Action Command_BlockAdminMenu(int client, const char[] command, int argc)
{
	if (g_bSingleplayerMode)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Singleplayer modunda admin menusu engellenmistir.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void SQL_OnConnect(Database db, const char[] error, any data)
{
	if(db == null)
	{
		LogError("Database connection error: %s", error);
		return;
	}
	
	g_db = db;
	char query[512];
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS admin_selection_admins (account_id INTEGER PRIMARY KEY)");
	g_db.Query(SQL_CheckError, query);
}

public void SQL_CheckError(Database db, DBResultSet results, const char[] error, any data)
{
	if(error[0])
	{
		LogError("SQL Query Error: %s", error);
	}
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_bTempAdmins[i] = false;
	}
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if(!IsFakeClient(client))
	{
		g_bTempAdmins[client] = false;
		g_bPersistentAdmins[client] = false;
		
		int accountID = GetSteamAccountID(client);
		
		if (g_bSingleplayerMode)
		{
			if (accountID > 0)
			{
				if (g_SingleplayerHostAccountID == 0)
				{
					g_SingleplayerHostAccountID = accountID;
				}
				else if (g_SingleplayerHostAccountID != accountID)
				{
					KickClient(client, "Sunucu Singleplayer modundadir. Baska oyuncu katilamaz.");
					return;
				}
			}
		}
		else if (g_db != null)
		{
			if (accountID > 0)
			{
				char query[256];
				Format(query, sizeof(query), "SELECT account_id FROM admin_selection_admins WHERE account_id = %d", accountID);
				g_db.Query(SQL_OnAdminLoad, query, GetClientUserId(client));
			}
		}
	}
}

public void SQL_OnAdminLoad(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if(!client) return;
	
	if(error[0])
	{
		LogError("SQL Admin Load Error: %s", error);
		return;
	}
	
	if(results.FetchRow())
	{
		g_bPersistentAdmins[client] = true;
		ApplyAdminFlag(client);
	}
}

public void OnClientDisconnect(int client)
{
	g_bTempAdmins[client] = false;
	g_bPersistentAdmins[client] = false;
	
	if (!IsFakeClient(client))
	{
		if (g_bSingleplayerMode)
		{
			int accountID = GetSteamAccountID(client);
			if (accountID > 0 && accountID == g_SingleplayerHostAccountID)
			{
				g_SingleplayerHostAccountID = 0;
				PrintToServer("[Admin Selection] Host ayrildi. Singleplayer modu varsayilan duruma dondu.");
			}
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (g_bSingleplayerMode && !IsFakeClient(client))
	{
		StripAllAdminFlags(client);
	}
}

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen)
{
	// Bağlantı reddetme işlemini OnClientAuthorized içine taşıdık. 
	// Çünkü OnClientConnect anında oyuncunun SteamID'si henüz belli olmuyor 
	// ve sunucu sahibi olup olmadığını anlayamıyoruz.
	return true;
}

// ---------------------------
// NATIVES
// ---------------------------

public any Native_IsAdmin(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) return false;
	
	if (g_bSingleplayerMode)
	{
		return CanManageSelectedAdmins(client);
	}
	
	return g_bTempAdmins[client] || g_bPersistentAdmins[client];
}

public any Native_HasFlag(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) return false;
	
	AdminFlag flag = view_as<AdminFlag>(GetNativeCell(2));
	
	if (g_bSingleplayerMode)
	{
		if (CanManageSelectedAdmins(client) && flag == Admin_Generic) return true;
		return false;
	}
	
	if (g_bTempAdmins[client] || g_bPersistentAdmins[client])
	{
		if (flag == Admin_Generic)
		{
			return true;
		}
	}
	return false;
}

public any Native_GetFlags(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients) return 0;
	
	if (g_bSingleplayerMode)
	{
		if (CanManageSelectedAdmins(client)) return (1 << view_as<int>(Admin_Generic));
		return 0;
	}
	
	if (g_bTempAdmins[client] || g_bPersistentAdmins[client])
	{
		return (1 << view_as<int>(Admin_Generic));
	}
	
	return 0;
}

public any Native_IsActive(Handle plugin, int numParams)
{
	return !g_bSingleplayerMode;
}

// ---------------------------
// ADMIN SELECTION HELPERS
// ---------------------------

bool CanManageSelectedAdmins(int client)
{
	if (!client || !IsClientInGame(client)) return false;
	return CheckCommandAccess(client, "sm_adminsec", ADMFLAG_ROOT);
}

int NormalizeSteamID(const char[] input)
{
	char temp[64];
	strcopy(temp, sizeof(temp), input);
	TrimString(temp);
	
	if (strlen(temp) == 17 && StrContains(temp, "7656119") == 0)
	{
		char lowerStr[10];
		strcopy(lowerStr, 10, temp[8]);
		
		int lower = StringToInt(lowerStr);
		int base_lower = 960265728;
		
		if (lower < base_lower)
		{
			lower += 1000000000;
		}
		
		return lower - base_lower;
	}
	
	if (StrContains(temp, "STEAM_") == 0)
	{
		char parts[3][16];
		ExplodeString(temp, ":", parts, 3, 16);
		int A = StringToInt(parts[1]);
		int B = StringToInt(parts[2]);
		return (B * 2) + A;
	}
	
	if (StrContains(temp, "U:1:") != -1)
	{
		ReplaceString(temp, sizeof(temp), "[", "");
		ReplaceString(temp, sizeof(temp), "]", "");
		char parts[3][16];
		ExplodeString(temp, ":", parts, 3, 16);
		return StringToInt(parts[2]);
	}
	
	return StringToInt(temp);
}

int GetClientByAccountID(int targetAccountID)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && IsClientAuthorized(i))
		{
			if (GetSteamAccountID(i) == targetAccountID)
			{
				return i;
			}
		}
	}
	return 0;
}

int GetRealClientCount()
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && !IsFakeClient(i))
		{
			count++;
		}
	}
	return count;
}

void ApplyAdminFlag(int client)
{
	if (!IsClientInGame(client)) return;
	
	SetUserFlagBits(client, GetUserFlagBits(client) | ADMFLAG_GENERIC);
}

void RemoveAdminFlag(int client)
{
	if (!IsClientInGame(client)) return;
	
	if (!g_bTempAdmins[client] && !g_bPersistentAdmins[client])
	{
		SetUserFlagBits(client, GetUserFlagBits(client) & ~ADMFLAG_GENERIC);
	}
}

void StripAllAdminFlags(int client)
{
	AdminId id = GetUserAdmin(client);
	if (id != INVALID_ADMIN_ID)
	{
		for (int flag = 0; flag < 20; flag++)
		{
			SetAdminFlag(id, view_as<AdminFlag>(flag), false);
		}
	}
	SetUserFlagBits(client, 0);
}

// ---------------------------
// ADMIN COMMAND HANDLERS
// ---------------------------

public Action Command_AdminSec(int client, int args)
{
	if (!CanManageSelectedAdmins(client))
	{
		ReplyToCommand(client, " \x04[Admin]\x01 You do not have permission to use this command.");
		return Plugin_Handled;
	}
	
	if (g_bSingleplayerMode)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Singleplayer Mod aktifken yeni admin eklenemez.");
		return Plugin_Handled;
	}
	
	if (args < 1)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Usage: !adminsec <SteamID>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArgString(arg, sizeof(arg));
	TrimString(arg);
	
	int accountID = NormalizeSteamID(arg);
	if (accountID <= 0)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Invalid SteamID format.");
		return Plugin_Handled;
	}
	
	int target = GetClientByAccountID(accountID);
	if (target > 0)
	{
		g_bTempAdmins[target] = true;
		ApplyAdminFlag(target);
		ReplyToCommand(client, " \x04[Admin]\x01 Player \x0B%N\x01 added as temporary admin for this session.", target);
	}
	else
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Player not found / Player is not connected.");
	}
	
	return Plugin_Handled;
}

public Action Command_AdminSecKal(int client, int args)
{
	if (!CanManageSelectedAdmins(client))
	{
		ReplyToCommand(client, " \x04[Admin]\x01 You do not have permission to use this command.");
		return Plugin_Handled;
	}
	
	if (g_bSingleplayerMode)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Singleplayer Mod aktifken yeni admin eklenemez.");
		return Plugin_Handled;
	}
	
	if (args < 1)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Usage: !adminseckal <SteamID>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArgString(arg, sizeof(arg));
	TrimString(arg);
	
	int accountID = NormalizeSteamID(arg);
	if (accountID <= 0)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Invalid SteamID format.");
		return Plugin_Handled;
	}
	
	if (g_db != null)
	{
		char query[256];
		Format(query, sizeof(query), "REPLACE INTO admin_selection_admins (account_id) VALUES (%d)", accountID);
		g_db.Query(SQL_CheckError, query);
		
		ReplyToCommand(client, " \x04[Admin]\x01 Player added to persistent admin list (AccountID: %d).", accountID);
		
		int target = GetClientByAccountID(accountID);
		if (target > 0)
		{
			g_bPersistentAdmins[target] = true;
			ApplyAdminFlag(target);
		}
	}
	else
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Database not connected.");
	}
	return Plugin_Handled;
}

public Action Command_AdminSecKaldir(int client, int args)
{
	if (!CanManageSelectedAdmins(client))
	{
		ReplyToCommand(client, " \x04[Admin]\x01 You do not have permission to use this command.");
		return Plugin_Handled;
	}
	
	if (args < 1)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Usage: !adminseckaldir <SteamID>");
		return Plugin_Handled;
	}
	
	char arg[64];
	GetCmdArgString(arg, sizeof(arg));
	TrimString(arg);
	
	int accountID = NormalizeSteamID(arg);
	if (accountID <= 0)
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Invalid SteamID format.");
		return Plugin_Handled;
	}
	
	if (g_db != null)
	{
		char query[256];
		Format(query, sizeof(query), "DELETE FROM admin_selection_admins WHERE account_id = %d", accountID);
		g_db.Query(SQL_CheckError, query);
		
		ReplyToCommand(client, " \x04[Admin]\x01 Player removed from admin list (AccountID: %d).", accountID);
		
		int target = GetClientByAccountID(accountID);
		if (target > 0)
		{
			g_bPersistentAdmins[target] = false;
			RemoveAdminFlag(target);
		}
	}
	else
	{
		ReplyToCommand(client, " \x04[Admin]\x01 Database not connected.");
	}
	return Plugin_Handled;
}

public Action Command_MultiplayerMod(int client, int args)
{
	if (g_bSingleplayerMode)
	{
		if (g_SingleplayerHostAccountID != 0 && GetSteamAccountID(client) != g_SingleplayerHostAccountID)
		{
			ReplyToCommand(client, " \x04[Admin]\x01 You do not have permission to use this command.");
			return Plugin_Handled;
		}
		
		g_bSingleplayerMode = false;
		g_SingleplayerHostAccountID = 0;
		ServerCommand("sm_reloadadmins");
		ReplyToCommand(client, " \x04[Admin]\x01 BAŞARILI!");
		PrintToChatAll(" \x04[Admin]\x01 Multiplayer Mod AKTIF! Ozel admin sistemi tekrar aktif.");
		
		if (g_db != null)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && !IsFakeClient(i) && IsClientAuthorized(i))
				{
					int accountID = GetSteamAccountID(i);
					if (accountID > 0)
					{
						char query[256];
						Format(query, sizeof(query), "SELECT account_id FROM admin_selection_admins WHERE account_id = %d", accountID);
						g_db.Query(SQL_OnAdminLoad, query, GetClientUserId(i));
					}
				}
			}
		}
	}
	else
	{
		if (!CanManageSelectedAdmins(client))
		{
			ReplyToCommand(client, " \x04[Admin]\x01 You do not have permission to use this command.");
			return Plugin_Handled;
		}
		
		// Diğer oyuncular varsa engel olmak yerine direkt atacağız
		
		g_bSingleplayerMode = true;
		g_SingleplayerHostAccountID = GetSteamAccountID(client);
		ReplyToCommand(client, " \x04[Admin]\x01 BAŞARILI!");
		PrintToChatAll(" \x04[Admin]\x01 Singleplayer Mod AKTIF! Tum ozel admin yetkileri gizlendi, baska oyuncu katilamaz.");
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				if (g_bTempAdmins[i] || g_bPersistentAdmins[i])
				{
					RemoveAdminFlag(i);
				}
				g_bTempAdmins[i] = false;
				g_bPersistentAdmins[i] = false;
				
				if (!IsFakeClient(i))
				{
					StripAllAdminFlags(i);
					if (i != client)
					{
						KickClient(i, "Sunucu Singleplayer moduna alindi. Baska oyuncular atildi.");
					}
				}
			}
		}
	}
	
	return Plugin_Handled;
}
