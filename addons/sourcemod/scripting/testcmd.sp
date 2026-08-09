#include <sourcemod>
public void OnPluginStart() {
    AddCommandListener(OnSpray, "player_ping");
    AddCommandListener(OnSpray, "spray");
    AddCommandListener(OnSpray, "+spray_menu");
}
public Action OnSpray(int client, const char[] command, int argc) {
    PrintToServer("Command sent: %s", command);
    return Plugin_Continue;
}
