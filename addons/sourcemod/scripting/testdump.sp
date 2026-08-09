#include <sourcemod>
public void OnPluginStart() {
    ServerCommand("sm_dump_netprops netprops.txt");
}
