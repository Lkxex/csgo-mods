#include <sourcemod>
#include <sdktools>
public void OnPluginStart() {
    RegConsoleCmd("sm_testpdecal", CmdTest);
}
public Action CmdTest(int client, int args) {
    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        int ent = CreateEntityByName("player_decal");
        if (ent != -1) {
            DispatchKeyValue(ent, "texture", "decals/sprays/default/crown_nodrips");
            TeleportEntity(ent, end, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(ent);
            AcceptEntityInput(ent, "Activate");
            PrintToChat(client, "Spawned player_decal");
        } else {
            PrintToChat(client, "Failed to create player_decal");
        }
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
