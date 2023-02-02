#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <zombiereloaded>
#include <cstrike>
#include <sdkhooks>

ConVar g_cvTime;

bool g_bWarmup = true;
int g_iTime = -1;

public Plugin myinfo =
{
	name = "[ZR] Warm Up",
	author = "koen",
	description = "",
	version = "",
	url = "https://github.com/notkoen"
};

public void OnPluginStart()
{
	g_cvTime = CreateConVar("sm_warmup_time", "90", "Length of warmup in seconds", _, true, 30.0);
	HookEvent("round_start", Event_RoundStart);
}

public void OnMapStart()
{
	g_bWarmup = true;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, TakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, TakeDamage);
}

public void Event_RoundStart(Handle event, const char[] name, bool broadcast)
{
	if (!g_bWarmup)
	{
		return;
	}

	CreateTimer(1.0, WarmupTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	g_iTime = g_cvTime.IntValue;
}

public Action TakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (g_bWarmup)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action WarmupTimer(Handle timer)
{
	if (g_iTime >= 0 && g_bWarmup)
	{
		char outp[8];
		int min, sec;
		min = g_iTime / 60;
		sec = g_iTime % 60;
		Format(outp, sizeof(outp), "%d:%s%d", min, sec < 10 ? "0" : "", sec);

		if (g_iTime < 3)
		{
			PrintCenterTextAll("<font color='#FF0000'>Warmup Time -</font> <font color='#FF0000'>%s</font>");
		}
		else if (g_iTime < 15)
		{
			PrintCenterTextAll("<font color='#FF0000'>Warmup Time -</font> <font color='#FFFF00'>%s</font>");
		}
		else
		{
			PrintCenterTextAll("<font color='#00FF00'>Warmup Time -</font> <font color='#00FF00'>%s</font>");
		}

		g_iTime--;
		return Plugin_Continue;
	}

	PrintCenterTextAll("<font color='#FF0000'>Warmup ending...</font>");
	g_bWarmup = false;
	CS_TerminateRound(3.0, CSRoundEnd_GameStart, true);
	return Plugin_Stop;
}

public Action ZR_OnClientInfect(int &client, int &attacker, bool &motherInfect, bool &respawnOverride, bool &respawn)
{
	if (g_bWarmup)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}