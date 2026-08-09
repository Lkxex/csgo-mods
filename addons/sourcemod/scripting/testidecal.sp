#include <sourcemod>
#include <sdktools>

int g_DecalEnt[MAXPLAYERS+1];

public void OnPluginStart() {
    RegConsoleCmd("sm_testidecal", CmdTest);
}

public Action CmdTest(int client, int args) {
    if (g_DecalEnt[client] != 0 && IsValidEntity(g_DecalEnt[client])) {
        AcceptEntityInput(g_DecalEnt[client], "Kill");
        PrintToChat(client, "Killed previous decal entity!");
    }

    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        
        int ent = CreateEntityByName("info_decal");
        if (ent != -1) {
            DispatchKeyValue(ent, "texture", "decals/custom_gen/crown");
            TeleportEntity(ent, end, ang, NULL_VECTOR);
            DispatchSpawn(ent);
            AcceptEntityInput(ent, "Activate");
            g_DecalEnt[client] = ent;
            PrintToChat(client, "Spawned info_decal!");
        }
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
