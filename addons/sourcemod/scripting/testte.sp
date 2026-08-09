#include <sourcemod>
#include <sdktools>
public void OnPluginStart() {
    RegConsoleCmd("sm_listte", CmdListTE);
}
public Action CmdListTE(int client, int args) {
    PrintToServer("TE List check doesn't easily expose names...");
    return Plugin_Handled;
}
