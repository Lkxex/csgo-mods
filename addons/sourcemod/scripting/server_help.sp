#include <sourcemod>

public Plugin myinfo = 
{
	name = "Server Help Menu",
	author = "Assistant",
	description = "Displays a help menu with server commands.",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	LoadTranslations("server_help.phrases");
	
	RegConsoleCmd("sm_help", Command_Help);
	RegConsoleCmd("sm_yardim", Command_Help);
}

public Action Command_Help(int client, int args)
{
	if(client > 0 && IsClientInGame(client))
	{
		Menu menu = new Menu(HelpMenuHandler);
		
		char title[128];
		Format(title, sizeof(title), "%T", "HelpMenuTitle", client);
		menu.SetTitle(title);
		
		char buffer[128];
		Format(buffer, sizeof(buffer), "%T", "HelpMenuSubtitle", client);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
		
		menu.AddItem("", " ", ITEMDRAW_SPACER);
		
		Format(buffer, sizeof(buffer), "%T", "HelpCommandWS", client);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
		
		Format(buffer, sizeof(buffer), "%T", "HelpCommandGlove", client);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
		
		Format(buffer, sizeof(buffer), "%T", "HelpCommandAgents", client);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
		
		Format(buffer, sizeof(buffer), "%T", "HelpCommandKnife", client);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
		
		menu.AddItem("", "!pin / !coin - Profil Rozeti", ITEMDRAW_DISABLED);
		menu.AddItem("", "!mvp / !music - Müzik Kiti", ITEMDRAW_DISABLED);
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	
	return Plugin_Handled;
}

public int HelpMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	if(action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
}
