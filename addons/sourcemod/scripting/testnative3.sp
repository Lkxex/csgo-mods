#include <sourcemod>
#include <sdktools>

public void OnPluginStart() {
    RegConsoleCmd("sm_testnative3", CmdNative);
}

public Action CmdNative(int client, int args) {
    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        
        int ent = CreateEntityByName("info_projecteddecal");
        if (ent != -1) {
            DispatchKeyValue(ent, "texture", "decals/custom_gen/crown");
            DispatchKeyValue(ent, "Distance", "256"); // Try setting distance
            TeleportEntity(ent, end, ang, NULL_VECTOR);
            DispatchSpawn(ent);
            AcceptEntityInput(ent, "Activate");
            PrintToChat(client, "Spawned info_projecteddecal!");
        }
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
