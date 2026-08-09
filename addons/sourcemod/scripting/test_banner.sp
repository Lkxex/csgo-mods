#include <sourcemod>
#include <sdktools>

public void OnPluginStart()
{
    RegConsoleCmd("sm_testbanner", Command_TestBanner);
}

public Action Command_TestBanner(int client, int args)
{
    int rules = GameRules_GetEntity();
    if (rules != -1)
    {
        int oldStatus = GetEntProp(rules, Prop_Send, "m_iRoundWinStatus");
        SetEntProp(rules, Prop_Send, "m_iRoundWinStatus", 3); // CT win
        
        Event endEvent = CreateEvent("round_end");
        if(endEvent != null)
        {
            endEvent.SetInt("winner", 3);
            endEvent.SetInt("reason", 8);
            endEvent.SetString("message", "#SFUI_Notice_CTs_Win");
            endEvent.FireToClient(client);
        }
        
        Event panelEvent = CreateEvent("cs_win_panel_round");
        if(panelEvent != null)
        {
            panelEvent.FireToClient(client);
        }
        
        // Restore immediately? Maybe delay a tick so it networks?
        // Wait, if it's FireToClient, it's sent immediately. But Prop_Send takes a tick to network.
        // If we restore immediately, it might not network.
        SetEntProp(rules, Prop_Send, "m_iRoundWinStatus", oldStatus);
    }
    return Plugin_Handled;
}
