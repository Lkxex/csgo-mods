#include <sourcemod>

public void OnPluginStart()
{
    RegConsoleCmd("sm_music_test1", Command_Test1);
    RegConsoleCmd("sm_music_test2", Command_Test2);
}

public Action Command_Test1(int client, int args)
{
    ClientCommand(client, "playgamesound Music.StopAllMusic");
    ClientCommand(client, "playgamesound Music.RoundMVP");
    ReplyToCommand(client, "Fired playgamesound Music.RoundMVP");
    return Plugin_Handled;
}

public Action Command_Test2(int client, int args)
{
    ClientCommand(client, "playgamesound Music.StopAllMusic");
    ClientCommand(client, "playgamesound Music.MVP");
    ReplyToCommand(client, "Fired playgamesound Music.MVP");
    return Plugin_Handled;
}
