#include <sourcemod>
#include <sdktools>
public void OnPluginStart() {
    RegConsoleCmd("sm_testnative11", CmdNative);
}

public Action CmdNative(int client, int args) {
    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        
        int decalEnt = CreateEntityByName("info_decal");
        if (decalEnt != -1) {
            DispatchKeyValue(decalEnt, "texture", "decals/sprays/crown_nodrips");
            TeleportEntity(decalEnt, end, ang, NULL_VECTOR);
            DispatchSpawn(decalEnt);
            AcceptEntityInput(decalEnt, "Activate");
            PrintToChat(client, "Spawned info_decal!");
        }
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
