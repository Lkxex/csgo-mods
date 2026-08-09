#include <sourcemod>
#include <sdktools>

public void OnPluginStart() {
    RegConsoleCmd("sm_testgen", CmdTestGen);
}

public void OnMapStart() {
    char vmtPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, vmtPath, sizeof(vmtPath), "../materials/decals/custom_gen/crown.vmt");
    
    // Create directory if not exists
    char dir[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, dir, sizeof(dir), "../materials/decals/custom_gen");
    if (!DirExists(dir)) {
        CreateDirectory(dir, 511);
    }
    
    File f = OpenFile(vmtPath, "w");
    if (f != null) {
        f.WriteLine("\"LightmappedGeneric\"");
        f.WriteLine("{");
        f.WriteLine("\t\"$basetexture\" \"decals/sprays/default/crown_nodrips\"");
        f.WriteLine("\t\"$translucent\" 1");
        f.WriteLine("\t\"$decal\" 1");
        f.WriteLine("\t\"$decalscale\" 0.25");
        f.WriteLine("}");
        delete f;
    }
    
    AddFileToDownloadsTable("materials/decals/custom_gen/crown.vmt");
    PrecacheDecal("decals/custom_gen/crown", true);
}

public Action CmdTestGen(int client, int args) {
    float pos[3]; GetClientEyePosition(client, pos);
    float ang[3]; GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, TraceFilter);
    if(TR_DidHit(tr)) {
        float end[3]; TR_GetEndPosition(end, tr);
        
        TE_Start("World Decal");
        TE_WriteVector("m_vecOrigin", end);
        TE_WriteNum("m_nIndex", PrecacheDecal("decals/custom_gen/crown", true));
        TE_SendToAll();
        PrintToChat(client, "Spawned TE World Decal using generated VMT!");
    }
    delete tr;
    return Plugin_Handled;
}
public bool TraceFilter(int entity, int contentsMask) { return false; }
