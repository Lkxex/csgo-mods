#if defined _sendproxy_included
 #endinput
#endif
#define _sendproxy_included

enum SendPropType
{
	Prop_Int = 0,
	Prop_Float,
	Prop_Vector,
	Prop_String,
	Prop_Array,
	Prop_DataTable
};

typeset SendProxyCallback
{
	function Action (int entity, const char[] propname, int &iValue, int element, int client);
	function Action (int entity, const char[] propname, float &flValue, int element, int client);
	function Action (int entity, const char[] propname, float vecValue[3], int element, int client);
	function Action (int entity, const char[] propname, char[] sValue, int element, int client);
};

native void SendProxy_Hook(int entity, const char[] propname, SendPropType type, SendProxyCallback callback);
native void SendProxy_Unhook(int entity, const char[] propname, SendProxyCallback callback);

public Extension __ext_sendproxy = 
{
	name = "SendProxy Manager",
	file = "sendproxy.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};
