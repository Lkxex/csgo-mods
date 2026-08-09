#include <sourcemod>
#include <sdktools>
public void OnPluginStart() {
    RegConsoleCmd("sm_testnative", CmdNative);
}
public Action CmdNative(int client, int args) {
    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        
        int ent = CreateEntityByName("player_decal");
        if (ent != -1) {
            DispatchKeyValue(ent, "player", "1"); // just test
            
            // Try to set definition index for Crown (1700)
            // m_iItemDefinitionIndex is inside CEconEntity
            // player_decal inherits from CBaseEntity, does it have m_iItemDefinitionIndex?
            
            TeleportEntity(ent, end, ang, NULL_VECTOR);
            DispatchSpawn(ent);
            ActivateEntity(ent);
            
            SetEntProp(ent, Prop_Send, "m_unAccountID", GetSteamAccountID(client));
            SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", 1700); 
            SetEntPropFloat(ent, Prop_Send, "m_flCreationTime", GetGameTime());
            SetEntPropVector(ent, Prop_Send, "m_vecOrigin", end);
            
            // To make it face away from wall, calculate normal
            float normal[3];
            TR_GetPlaneNormal(tr, normal);
            SetEntPropVector(ent, Prop_Send, "m_vecRight", normal); // Need proper axis calculation
            
            PrintToChat(client, "Spawned player_decal %d", ent);
        }
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
