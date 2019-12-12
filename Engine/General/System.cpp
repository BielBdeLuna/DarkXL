#include "System.h"
#include "Map.h"
#include "DXL_Console.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

bool System::m_bMissionComplete=false;
bool System::m_abGoalComplete[16];
int System::m_nLogLevel = System::LOG_INFO;
char System::m_szText[2048];
float System::m_fTexDispTime=0.0f;
vector<System::TextMsg_t *> System::m_MsgList;

int System::m_anSecretsFound[32];
int System::m_nSecretFoundCnt=0;
int System::m_nTotalSecretCnt=0;

vector<System::MsgHandler_t *> System::m_MsgHandlers;

bool System::PostMsg(int msg, int val/*=0*/)
{
	int i;
	bool bRet=true;
	switch (msg)
	{
		case SYSMSG_RESET:
			m_bMissionComplete = false;
			for (i=0; i<16; i++) { 	m_abGoalComplete[i] = false; }
		break;
		case SYSMSG_COMPLETE:
			if ( m_bMissionComplete )
				bRet = false;
			m_bMissionComplete = true;
			for (int i=0; i<16; i++)
			{
				m_abGoalComplete[i] = true;
			}
		break;
		case SYSMSG_GOALCOMPLETE:
			if ( m_abGoalComplete[val] )
				bRet = false;
			m_abGoalComplete[val] = true;
		break;
	};
	return bRet;
}

bool System::IsGolComplete(int gol)
{
	return m_abGoalComplete[gol];
}

bool System::IsMissionComplete()
{
	return m_bMissionComplete;
}

void System::SetSecretFound(int secID)
{
	for (int s=0; s<m_nSecretFoundCnt; s++)
	{
		if ( m_anSecretsFound[s] == secID )
			return;
	}
	m_anSecretsFound[m_nSecretFoundCnt++] = secID;
}

void System::Update(float dt)
{
	m_fTexDispTime -= dt;
	if ( m_fTexDispTime < 0.0f ) m_fTexDispTime = 0.0f;
}

FILE *m_fLogFile = NULL;

bool System::InitLogFile()
{
	//setup variables and stuff.
	for (int i=0; i<16; i++)
	{
		char szGoalName[64];
		sprintf(szGoalName, "g_goal%02d_complete", i);
		DXL_Console::RegisterCmd(szGoalName, &m_abGoalComplete[i], Console::CTYPE_BOOL, "Is the goal complete (0/1)?");
	}
	DXL_Console::RegisterCmd("g_mission_complete", &m_bMissionComplete, Console::CTYPE_BOOL, "Are all the mission objectives complete (0/1)?");

	m_fLogFile = fopen("DXL_Log.rtf", "wc");
	if ( m_fLogFile )
	{
		//RTF header.
		//fprintf(m_fLogFile, "{\\rtf1\\ansi\\deff0{\\fonttbl{\\f0 Courier New;}}\\fs20\n");
		fprintf(m_fLogFile, "{\\rtf1\\ansi\\ansicpg1252\\deff0\\deflang1033{\\fonttbl{\\f0\\fswiss\\fcharset0 Courier New;}}\n");
		//Color table
		fprintf(m_fLogFile, "{\\colortbl ;");
		fprintf(m_fLogFile, "\\red255\\green255\\blue255;");	//White
		fprintf(m_fLogFile, "\\red128\\green128\\blue128;");	//Grey
		fprintf(m_fLogFile, "\\red255\\green0\\blue0;");		//Red
		fprintf(m_fLogFile, "\\red0\\green255\\blue0;");		//Green
		fprintf(m_fLogFile, "\\red0\\green0\\blue255;");		//Blue
		fprintf(m_fLogFile, "\\red0\\green255\\blue255;");		//Cyan
		fprintf(m_fLogFile, "\\red255\\green255\\blue0;");		//Yellow
		fprintf(m_fLogFile, "\\red255\\green0\\blue255;");		//Magenta
		fprintf(m_fLogFile, "\\red128\\green0\\blue0;");		//Dark Red
		fprintf(m_fLogFile, "\\red0\\green128\\blue0;");		//Dark Green
		fprintf(m_fLogFile, "\\red0\\green0\\blue128;");		//Dark Blue
		fprintf(m_fLogFile, "\\red255\\green128\\blue128;");	//Light Red
		fprintf(m_fLogFile, "\\red128\\green255\\blue128;");	//Light Green
		fprintf(m_fLogFile, "\\red128\\green128\\blue255;");	//Light Blue
		fprintf(m_fLogFile, "\\red255\\green128\\blue0;");		//Orange
		fprintf(m_fLogFile, "}\n");

		fflush(m_fLogFile);

		LogMsg("DarkXL Alpha, Build 9.08", System::LOG_LightRed);
		Log(LogInfo, "Log File Open");

		return true;
	}
	return false;
}

void System::CloseLogFile()
{
	if ( m_fLogFile )
	{
		Log(LogInfo, "Log File Close");
		fprintf(m_fLogFile, "}\n");
		fclose( m_fLogFile );
	}
	m_fLogFile = NULL;
}

const char *m_apszColor[]=
{
	"\\cf1",
	"\\cf1",
	"\\cf2",
	"\\cf3",
	"\\cf4",
	"\\cf5",
	"\\cf6",
	"\\cf7",
	"\\cf8",
	"\\cf9",
	"\\cf10",
	"\\cf11",
	"\\cf12",
	"\\cf13",
	"\\cf14",
	"\\cf15"
};

static char szCommentStore[2048];
static char _tmpStr[2048];

void System::LogMessageF(int nType, const char *pszFunc, int line, const char *pszComment, ...)
{
	if ( nType == LOG_VERBOSE && m_nLogLevel < LOG_VERBOSE )
	{
		return;
	}

	int clr = 0;

	va_list args;
	va_start(args, pszComment);
	_vsnprintf( _tmpStr, 2048, pszComment, args );
	va_end(args);

	int s=0;
	for (s=0; s<(int)strlen(_tmpStr); s++)
	{
		if ( _tmpStr[s] == '\\' )
		{
			szCommentStore[s] = '/';
		}
		else
		{
			szCommentStore[s] = _tmpStr[s];
		}
	}
	szCommentStore[s] = 0;

	char szConsoleMsg[256];
	switch (nType)
	{
		case System::LOG_ERROR:
				fprintf(m_fLogFile, "\\pard \\cf3 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "^1ERROR Func: %s, Line: %d, %s", pszFunc, line, szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_INFO:
				fprintf(m_fLogFile, "\\pard \\cf2 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "%s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_WARNING:
				fprintf(m_fLogFile, "\\pard \\cf15 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "^8WARNING %s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_VERBOSE:
				fprintf(m_fLogFile, "\\pard \\cf5 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "%s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_MSG:
			{
				fprintf(m_fLogFile, "\\pard %s \\b \\i %s \\b0 \\i0 \\par\n", m_apszColor[clr], szCommentStore);
				sprintf(szConsoleMsg, "%s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			}
			break;
	}

	fflush(m_fLogFile);
}

void System::LogMessage(int nType, const char *pszFunc, int line, const char *pszComment, int clr/*=0*/)
{
	if ( nType == LOG_VERBOSE && m_nLogLevel < LOG_VERBOSE )
	{
		return;
	}

	int s=0;
	for (s=0; s<(int)strlen(pszComment); s++)
	{
		if ( pszComment[s] == '\\' )
		{
			szCommentStore[s] = '/';
		}
		else
		{
			szCommentStore[s] = pszComment[s];
		}
	}
	szCommentStore[s] = 0;

	char szConsoleMsg[256];
	switch (nType)
	{
		case System::LOG_ERROR:
				fprintf(m_fLogFile, "\\pard \\cf3 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "^1ERROR Func: %s, Line: %d, %s", pszFunc, line, szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_INFO:
				fprintf(m_fLogFile, "\\pard \\cf2 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "%s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_WARNING:
				fprintf(m_fLogFile, "\\pard \\cf15 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "^8WARNING %s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_VERBOSE:
				fprintf(m_fLogFile, "\\pard \\cf5 \\b <%s %d> \\b0 %s\\par\n", pszFunc, line, szCommentStore);
				sprintf(szConsoleMsg, "%s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			break;
		case System::LOG_MSG:
			{
				fprintf(m_fLogFile, "\\pard %s \\b \\i %s \\b0 \\i0 \\par\n", m_apszColor[clr], szCommentStore);
				sprintf(szConsoleMsg, "%s", szCommentStore);
				DXL_Console::Print(szConsoleMsg);
			}
			break;
	}

	fflush(m_fLogFile);
}

void System::SetTextDisp(const char *pszText)
{
	strcpy(m_szText, pszText);
	m_fTexDispTime = 5.0f;
}

void System::SetTextDispIndex(int index)
{
	for (int i=0; i<(int)m_MsgList.size(); i++)
	{
		if ( m_MsgList[i]->index == index )
		{
			strcpy(m_szText, m_MsgList[i]->szMsg);
			m_fTexDispTime = 5.0f;

			char szConsoleMsg[256];
			sprintf(szConsoleMsg, "^6%s", m_szText);
			DXL_Console::Print(szConsoleMsg);
			break;
		}
	}
}

void System::Msg_ParseLine(char *pszLine)
{
	static char szWorkingStr[2048];
	if ( pszLine[0] == '#' ) { return; }
	strcpy(szWorkingStr, pszLine);

	int l = (int)strlen(szWorkingStr);
	//now remove leading spaces...
	int nSpaceEnd = -1;
	int ii;
	for (ii=0; ii<l; ii++)
	{
		if ( szWorkingStr[ii] > ' ' && szWorkingStr[ii] <= '~' )
		{
			nSpaceEnd = ii-1;
			break;
		}
	}
	if ( nSpaceEnd > -1 )
	{
		nSpaceEnd++;
		for (ii=0; ii<l-nSpaceEnd; ii++)
		{
			szWorkingStr[ii] = szWorkingStr[ii+nSpaceEnd];
		}
		szWorkingStr[ii] = 0;
	}
	if ( szWorkingStr[0] == '#' || szWorkingStr[0] <= ' ' ) { return; }
	if ( szWorkingStr[0] == 'E' && szWorkingStr[1] == 'N' && szWorkingStr[2] == 'D' ) { return; }

	//# space(s) priority: space(s) "msg"
	//first extract the number...
	char szIndex[256];
	int i, strIdx = 0;
	l = (int)strlen(szWorkingStr);
	for (i=0; i<l; i++)
	{
		if ( szWorkingStr[i] > ' ' )
		{
			szIndex[i] = szWorkingStr[i];
			strIdx++;
		}
		else
		{
			strIdx++;
			break;
		}
	}
	szIndex[i] = 0;

	//now extract priority.
	char szPriority[256];
	int nPStart = -1;
	for (i=strIdx; i<l; i++)
	{
		if ( szWorkingStr[i] > ' ' )
		{
			nPStart = i;
			break;
		}
	}
	for (i=nPStart; i<l; i++)
	{
		if ( szWorkingStr[i] != ':' )
		{
			szPriority[i-nPStart] = szWorkingStr[i];
		}
		else
		{
			break;
		}
	}
	szPriority[i-nPStart] = 0;

	//now extract the message itself.
	int nMsgStart = -1;
	for (; i<l; i++)
	{
		if ( szWorkingStr[i] == '"' )
		{
			nMsgStart = i;
			break;
		}
	}

	char szMsg[256];
	for (i=nMsgStart+1; i<l; i++)
	{
		if ( szWorkingStr[i] == '"' )
		{
			break;
		}
		else
		{
			szMsg[i-(nMsgStart+1)] = szWorkingStr[i];
		}
	}
	szMsg[i-(nMsgStart+1)] = 0;

	char *tmp;
	TextMsg_t *pMsg = new TextMsg_t;

	pMsg->index = (short)strtol(szIndex, &tmp, 10);
	pMsg->priority = (short)strtol(szPriority, &tmp, 10);
	strcpy(pMsg->szMsg, szMsg);

	m_MsgList.push_back(pMsg);
}

void System::Init(Map *pMap)
{
	if ( pMap->m_pDarkGOB->OpenFile("TEXT.MSG") )
	{
		long len = pMap->m_pDarkGOB->GetFileLen();
		char *pData = new char[len+1];
		pMap->m_pDarkGOB->ReadFile(pData);
		pMap->m_pDarkGOB->CloseFile();

		//parse pData
		Map::m_pFileData = pData;
		Map::m_nFileSize = len;
		Map::m_nFilePtr = 0;
		int nMsgCnt=0;
		Map::SearchKeyword("MSGS", nMsgCnt);

		//now parse each line...
		char *pszCur = &pData[Map::m_nFilePtr];
		char szLine[256];
		int lineIdx = 0;
		int sl = (int)strlen(pszCur);
		for (int l=0; l<sl; l++)
		{
			if ( pszCur[l] == '\r' || pszCur[l] == '\n' )
			{
				szLine[lineIdx] = 0;
				if ( lineIdx > 0 )
				{
					Msg_ParseLine(szLine);
				}

				lineIdx = 0;
				szLine[lineIdx] = 0;
			}
			else
			{
				szLine[lineIdx] = pszCur[l];
				lineIdx++;
			}
		}

		//free pData
		delete [] pData;
		pData = NULL;
	}
}

void System::Destroy()
{
	if ( m_MsgList.size() > 0 )
	{
		vector<TextMsg_t *>::iterator iter = m_MsgList.begin();
		vector<TextMsg_t *>::iterator end  = m_MsgList.end();
		for (; iter!=end; ++iter)
		{
			TextMsg_t *pMsg = *iter;
			if ( pMsg )
			{
				delete pMsg;
			}
		}
		m_MsgList.clear();
	}

	if ( m_MsgHandlers.size() > 0 )
	{
		vector<MsgHandler_t *>::iterator iter = m_MsgHandlers.begin();
		vector<MsgHandler_t *>::iterator end  = m_MsgHandlers.end();
		for (; iter!=end; ++iter)
		{
			MsgHandler_t *pMsg = *iter;
			if ( pMsg )
			{
				delete pMsg;
			}
		}
		m_MsgHandlers.clear();
	}
}

const char *System::GetTextDisp()
{
	if ( m_fTexDispTime > 0.0f )
	{
		return m_szText;
	}
	return NULL;
}

void System::RegisterMsgHandler(int ID, void *pUserData, MsgHandlerFunc_t msgHandler)
{
	MsgHandler_t *pNewHandler = new MsgHandler_t;
	if ( pNewHandler )
	{
		pNewHandler->ID = ID;
		pNewHandler->msgFunc = msgHandler;
		pNewHandler->pUserData = pUserData;
		m_MsgHandlers.push_back( pNewHandler );
	}
}

void System::PostGameMessage(int ID, void *pData)
{
	vector<MsgHandler_t *>::iterator iter = m_MsgHandlers.begin();
	vector<MsgHandler_t *>::iterator end  = m_MsgHandlers.end();
	for (; iter!=end; ++iter)
	{
		MsgHandler_t *pMsg = *iter;
		if ( pMsg->ID == ID )
		{
			pMsg->msgFunc( pMsg->pUserData, pData );
		}
	}
}
