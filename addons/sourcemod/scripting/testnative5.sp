#include <sourcemod>
#include <sdktools>

public void OnPluginStart() {
    RegConsoleCmd("sm_testnative5", CmdNative);
}

public Action CmdNative(int client, int args) {
    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        float normal[3]; TR_GetPlaneNormal(tr, normal);
        
        int decalIndex = PrecacheDecal("decals/custom_gen/crown", true);
        TE_Start("BSP Decal");
        TE_WriteVector("m_vecOrigin", end);
        TE_WriteNum("m_nEntity", 0); // World
        TE_WriteNum("m_nIndex", decalIndex);
        TE_SendToAll();
        PrintToChat(client, "Spawned TE_BSPDecal!");
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
