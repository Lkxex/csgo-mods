#include <sourcemod>
#include <sdktools>

public void OnPluginStart()
{
	RegConsoleCmd("sm_testrules", Cmd_TestRules);
}

public Action Cmd_TestRules(int client, int args)
{
	int ent = FindEntityByClassname(-1, "cs_gamerules");
	int ent2 = FindEntityByClassname(-1, "cs_gamerules_proxy");
	PrintToChat(client, "cs_gamerules: %d, cs_gamerules_proxy: %d", ent, ent2);
	return Plugin_Handled;
}
