#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#pragma newdecls required

ArrayList RestrictedNames;

public Plugin myinfo =  {
    name = "Name filter",
    author = "SUPER TIMOR",
    description = "",
    version = "1.0.0",
    url = "https://goBoosting.pl"
};

public void OnPluginStart() {
    RestrictedNames = new ArrayList(ByteCountToCells(MAX_NAME_LENGTH));
    RegAdminCmd("sm_reloadnamesconfig", CMD_ReloadConfig, ADMFLAG_ROOT);
    HookEvent("player_spawn", Event_PlayerSpawn);
    LoadConfig();
}

public Action CMD_ReloadConfig(int client, int args) {
    if(!IsValidClient(client))
        return Plugin_Handled;
        
    LoadConfig();
    
    return Plugin_Handled;
}

public void OnClientPutInServer(int client) {
    if(!IsValidClient(client) || !IsClientInGame(client))
        return;
    
    CheckClientNickname(client);
}

public Action Event_PlayerSpawn(Event event, char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!IsValidClient(client))
        return Plugin_Continue;
    
    CheckClientNickname(client);
    
    return Plugin_Continue;
}

void CheckClientNickname(int client) {
    if(!IsValidClient(client) || !IsClientInGame(client))
        return;
        
    char clientNickname[MAX_NAME_LENGTH];
    char buffer[MAX_NAME_LENGTH];
    GetClientName(client, clientNickname, sizeof(clientNickname));
    for(int i = 0; i < RestrictedNames.Length; i++) {
        RestrictedNames.GetString(i, buffer, sizeof(buffer));
        if(StrContains(clientNickname, buffer) != -1) {
            ChangeClientNickname(client, buffer);
        }
    }
}

void ChangeClientNickname(int client, char[] stringToRemove) {
    if(!IsValidClient(client) || !IsClientInGame(client))
        return;
    
    char clientNickname[MAX_NAME_LENGTH];
    GetClientName(client, clientNickname, sizeof(clientNickname));
    ReplaceStringEx(clientNickname, sizeof(clientNickname), stringToRemove, "", -1, -1, false);
    SetClientName(client, clientNickname);
}

public void OnMapStart() {
    LoadConfig();
}

void LoadConfig() {
    RestrictedNames.Clear();
    char sFilePath[PLATFORM_MAX_PATH];
    char line[512];
    
    BuildPath(Path_SM, sFilePath, sizeof(sFilePath), "configs/namefilter.cfg");
    
    Handle file = OpenFile(sFilePath, "rt");
    if(file != INVALID_HANDLE) {
        while(!IsEndOfFile(file)) {
            if(!ReadFileLine(file, line, sizeof(line))) {
                break;
            }
            
            TrimString(line);
            if(strlen(line) > 0) {
                if(StrContains(line, "//") != -1)
                    continue;
                    
                RestrictedNames.PushString(line);
            }
        }
        CloseHandle(file);
    }
}

public bool IsValidClient(int client) {
    if(client >= 1 && client <= MaxClients && IsClientInGame(client))
        return true;

    return false;
}