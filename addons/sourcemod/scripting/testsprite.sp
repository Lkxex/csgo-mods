#include <sourcemod>
#include <sdktools>
public void OnPluginStart() {
    RegConsoleCmd("sm_testsprite", CmdTestSprite);
}
public void OnMapStart() {
    PrecacheModel("materials/decals/sprays/default/crown_nodrips.vmt", true);
}
public Action CmdTestSprite(int client, int args) {
    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        
        int ent = CreateEntityByName("env_sprite_oriented");
        if (ent != -1) {
            DispatchKeyValue(ent, "model", "materials/decals/sprays/default/crown_nodrips.vmt");
            DispatchKeyValue(ent, "scale", "1.0");
            DispatchKeyValue(ent, "rendermode", "5"); // kRenderTransAdd or 1 (kRenderTransColor)
            DispatchKeyValue(ent, "renderamt", "255");
            DispatchKeyValue(ent, "spawnflags", "1"); // Start on
            TeleportEntity(ent, end, ang, NULL_VECTOR);
            DispatchSpawn(ent);
            PrintToChat(client, "Spawned env_sprite_oriented");
        }
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
