#include <sourcemod>
public void OnPluginStart() {
    char input[] = "76561198438576666";
    int accountID = Steam64ToAccountID(input);
    PrintToServer("AccountID: %d", accountID);
}

int Steam64ToAccountID(const char[] steam64) {
    if (strlen(steam64) != 17) return 0;
    
    char upperStr[9];
    char lowerStr[10];
    
    strcopy(upperStr, 9, steam64); // copies first 8 chars + null
    strcopy(lowerStr, 10, steam64[8]); // copies remaining 9 chars + null
    
    int upper = StringToInt(upperStr);
    int lower = StringToInt(lowerStr);
    
    int base_upper = 76561197;
    int base_lower = 960265728;
    
    if (lower < base_lower) {
        lower += 1000000000;
        upper -= 1;
    }
    
    int diff_upper = upper - base_upper;
    int diff_lower = lower - base_lower;
    
    // diff_upper should be 0 because 76561198 - 1 = 76561197
    return (diff_upper * 1000000000) + diff_lower;
}
