#include <sourcemod>
public void OnPluginStart() {
    AddCommandListener(Command_SprayMenu, "+spray_menu");
}
public Action Command_SprayMenu(int client, const char[] command, int argc) {
    PrintToChat(client, "You pressed T (+spray_menu)!");
    return Plugin_Handled;
}
