#pragma semicolon 1
#pragma newdecls required

#include <sdktools>

public Plugin myinfo = 
{
	name        = "Voice Command Block",
	author      = "Dysphie",
	description = "Block voice commands from people you've muted",
	version     = "0.1.0",
	url         = ""
};

public void OnPluginStart()
{
	AddTempEntHook("TEVoiceCommand", OnVoiceCmd);
}

public Action OnVoiceCmd(const char[] te_name, const int[] targets, int numTargets, float delay)
{
	int caller = TE_ReadNum("_playerIndex");
	int[] filtered = new int[numTargets];
	int numFiltered;

	for (int i; i < numTargets; i++)
	{
		if (IsValidClient(targets[i]) && !IsClientMuted(targets[i], caller))
		{
			filtered[numFiltered] = targets[i];
			numFiltered++;
		}
	}

	if (numFiltered != numTargets && numFiltered > 0)
	{
		DataPack data = new DataPack();
		data.WriteFloat(delay);
		data.WriteCell(TE_ReadNum("_playerIndex"));
		data.WriteCell(TE_ReadNum("_voiceCommand"));
		data.WriteCell(numFiltered);
		data.WriteCellArray(filtered, numFiltered);

		RequestFrame(RelayVoiceCmd, data);
		return Plugin_Handled;
	}

	return Plugin_Continue;

}

void RelayVoiceCmd(DataPack data)
{
	data.Reset();

	float delay = data.ReadFloat();
	int initiator = data.ReadCell();
	int voiceIndex = data.ReadCell();

	int numTargets = data.ReadCell();
	int[] targets = new int[numTargets];
	data.ReadCellArray(targets, numTargets);

	delete data;

	TE_Start("TEVoiceCommand");
	TE_WriteNum("_playerIndex", initiator);
	TE_WriteNum("_voiceCommand", voiceIndex);
	TE_Send(targets, numTargets, delay);
}

bool IsValidClient(int client)
{
	return 0 < client <= MaxClients && IsClientInGame(client);
}
