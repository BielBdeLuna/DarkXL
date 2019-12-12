#pragma once

#include "GameMessages.h"
#include <vector>
using namespace std;

class Map;

#define Log System::LogMessageF
#define LogInfo System::LOG_INFO, __FUNCTION__, __LINE__
#define LogVerbose System::LOG_VERBOSE, __FUNCTION__, __LINE__
#define LogError System::LOG_ERROR, __FUNCTION__, __LINE__
#define LogWarning System::LOG_WARNING, __FUNCTION__, __LINE__
#define LogMsg(msg, c) System::LogMessage(System::LOG_MSG, NULL, 0, msg, c)

typedef void (*MsgHandlerFunc_t)(void *, void *);

class System
{
public:
	static bool PostMsg(int msg, int val=0);

	static bool IsGolComplete(int gol);
	static bool IsMissionComplete();
	static void SetSecretFound(int secID);
	static void SetSecretCount(int count) { m_nSecretFoundCnt = 0; m_nTotalSecretCnt = count; }
	static int GetSecretFoundCount() { return m_nSecretFoundCnt; }
	static int GetTotalSecretCount() { return m_nTotalSecretCnt;  }

	static bool InitLogFile();
	static void CloseLogFile();
	static void LogMessage(int nType, const char *pszFunc, int line, const char *pszComment, int clr=LOG_Grey);
	static void LogMessageF(int nType, const char *pszFunc, int line, const char *pszComment, ...);
	static void SetLogLevel(int level) { m_nLogLevel = level; }
	static int GetLogLevel() { return m_nLogLevel; }

	static void Init(Map *pMap);
	static void Destroy();

	static void Update(float dt);

	static void SetTextDisp(const char *pszText);
	static void SetTextDispIndex(int index);
	static const char *GetTextDisp();

	static void RegisterMsgHandler(int ID, void *pUserData, MsgHandlerFunc_t msgHandler);
	static void PostGameMessage(int ID, void *pData);
public:
	enum
	{
		SYSMSG_RESET=0,
		SYSMSG_COMPLETE,
		SYSMSG_GOALCOMPLETE,
	} SystemMessages_e;

	enum
	{
		LOG_ERROR=0,
		LOG_WARNING,
		LOG_INFO,
		LOG_VERBOSE,
		LOG_MSG
	} LogMsgType_e;

	enum
	{
		LOG_White=1,
		LOG_Grey,
		LOG_Red,
		LOG_Green,
		LOG_Blue,
		LOG_Cyan,
		LOG_Yellow,
		LOG_Magenta,
		LOG_DarkRed,
		LOG_DarkGreen,
		LOG_DarkBlue,
		LOG_LightRed,
		LOG_LightGreen,
		LOG_LightBlue,
		LOG_Orange
	} LogColors_e;

private:
	typedef struct
	{
		short index;
		short priority;
		char szMsg[64];
	} TextMsg_t;

	struct MsgHandler_t
	{
		int ID;
		void *pUserData;
		MsgHandlerFunc_t msgFunc;
	};

	static bool m_bMissionComplete;
	static bool m_abGoalComplete[16];
	static int m_anSecretsFound[32];
	static int m_nLogLevel;
	static int m_nSecretFoundCnt;
	static int m_nTotalSecretCnt;
	static char m_szText[];
	static vector<TextMsg_t *> m_MsgList;
	static vector<MsgHandler_t *> m_MsgHandlers;

	static float m_fTexDispTime;

	static void Msg_ParseLine(char *pszLine);
};
