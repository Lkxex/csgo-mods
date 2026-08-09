#include <sourcemod>
#include <sdktools>
#include <PTaH>

public void OnPluginStart() {
    RegConsoleCmd("sm_testinv", CmdTestInv);
}
public Action CmdTestInv(int client, int args) {
    CCSPlayerInventory inv = PTaH_GetPlayerInventory(client);
    if (inv != CCSPlayerInventory_NULL) {
        CEconItemView item = inv.GetItemInLoadout(GetClientTeam(client), 54); // 54 is graffiti slot
        if (item != CEconItemView_NULL) {
            PrintToChat(client, "You have a graffiti equipped! DefIndex: %d", item.GetItemDefinition().GetDefinitionIndex());
        } else {
            PrintToChat(client, "No graffiti equipped in slot 54.");
        }
    }
    return Plugin_Handled;
}
