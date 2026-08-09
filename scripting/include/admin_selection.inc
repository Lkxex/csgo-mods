#if defined _admin_selection_included
  #endinput
#endif
#define _admin_selection_included

/**
 * Checks if a player has admin privileges granted by the Admin Selection plugin.
 *
 * @param client    Client index.
 * @return          True if the player is an admin (temporary or persistent), false otherwise.
 */
native bool AdminSelection_IsAdmin(int client);

/**
 * Checks if a player has a specific admin flag granted by the Admin Selection plugin.
 *
 * @param client    Client index.
 * @param flag      AdminFlag to check.
 * @return          True if the player has the flag, false otherwise.
 */
native bool AdminSelection_HasFlag(int client, AdminFlag flag);

/**
 * Gets the bitmask of all admin flags granted by the Admin Selection plugin to a player.
 *
 * @param client    Client index.
 * @return          Bitmask of flags.
 */
native int AdminSelection_GetFlags(int client);

/**
 * Returns whether the Admin Selection plugin is actively managing admins.
 * If false, it means Singleplayer Mode is active, and other plugins should fall back to standard SM admin logic.
 */
native bool AdminSelection_IsActive();


public SharedPlugin __pl_admin_selection = {
	name = "admin_selection",
	file = "csgo_admin_selection.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_admin_selection_SetNatives() {
	MarkNativeAsOptional("AdminSelection_IsAdmin");
	MarkNativeAsOptional("AdminSelection_HasFlag");
	MarkNativeAsOptional("AdminSelection_GetFlags");
	MarkNativeAsOptional("AdminSelection_IsActive");
}
#endif
