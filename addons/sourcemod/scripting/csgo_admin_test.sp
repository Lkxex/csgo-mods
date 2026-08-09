#include <sourcemod>
#include <admin_selection>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Admin Selection API Test",
	author = "Assistant",
	description = "Tests the admin selection API",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_admintest", Command_AdminTest, "Tests if you are an admin according to Admin Selection");
}

public Action Command_AdminTest(int client, int args)
{
	if (!client || !IsClientInGame(client)) return Plugin_Handled;
	
	if (LibraryExists("admin_selection"))
	{
		if (AdminSelection_IsAdmin(client))
		{
			PrintToChat(client, " \x04[Admin Selection]\x01 You ARE recognized as an admin!");
		}
		else
		{
			PrintToChat(client, " \x04[Admin Selection]\x01 You are NOT an admin.");
		}
	}
	else
	{
		PrintToChat(client, " \x04[Admin Selection]\x01 The admin_selection API is not loaded.");
	}
	
	return Plugin_Handled;
}
