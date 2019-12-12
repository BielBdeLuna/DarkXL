#include "ScriptSystem.h"
#include "Windows.h"
#include "System.h"
#include "DXL_Console.h"
#include <stdio.h>

asIScriptEngine *m_Engine;
asIScriptContext *m_pContext;
float m_afGlobalStore[32];
int m_aTimers[32];

void _MessageCallback(const asSMessageInfo *msg, void *param)
{
	const char *type = "ERR ";
	if( msg->type == asMSGTYPE_WARNING ) 
		type = "WARN";
	else if( msg->type == asMSGTYPE_INFORMATION ) 
		type = "INFO";

	char szDebugOut[256];
	sprintf(szDebugOut, "%s (%d, %d) : %s : %s\n", msg->section, msg->row, msg->col, type, msg->message);
	OutputDebugString(szDebugOut);

	sprintf(szDebugOut, "^1ScriptError: %s (%d, %d) : %s : %s\n", msg->section, msg->row, msg->col, type, msg->message);

	DXL_Console::Print(szDebugOut);
}

bool ScriptSystem::Init()
{
	// Create the script engine
	m_Engine = asCreateScriptEngine(ANGELSCRIPT_VERSION);
	if( m_Engine == NULL )
	{
		return false;
	}

	// The script compiler will write any compiler messages to the callback.
	m_Engine->SetMessageCallback( asFUNCTION(_MessageCallback), 0, asCALL_CDECL );

	// Register the script string type
	// Look at the implementation for this function for more information  
	// on how to register a custom string type, and other object types.
	// The implementation is in "/add_on/scriptstring/scriptstring.cpp"
	RegisterScriptString(m_Engine);

	m_pContext = NULL;

	memset(m_afGlobalStore, 0, sizeof(float)*32);
	memset(m_aTimers, 0, sizeof(int)*32);
	
	return true;
}

void ScriptSystem::Destroy()
{
	if (m_pContext) m_pContext->Release();
	if (m_Engine)   m_Engine->Release();
}

bool ScriptSystem::RegisterFunc(const char *decl, const asUPtr& pFunc)
{
	int r = m_Engine->RegisterGlobalFunction(decl, pFunc, asCALL_CDECL); 
	return (r >= 0) ? true : false;
}

bool ScriptSystem::RegisterVar(const char *decl, void *pVar)
{
	int r = m_Engine->RegisterGlobalProperty(decl, pVar); 
	return (r >= 0) ? true : false;
}

const char *pszModules[]=
{
	"MODULE_LOGICS",
	"MODULE_WEAPONS",
};

const char *pszSections[]=
{
	"SECTION_CORE",
	"SECTION_USER",
};

bool ScriptSystem::ReloadScript(int nModule, int nSection, const char *pszFile, bool bBuildModule)
{
	FILE *f = fopen(pszFile, "rb");
	if ( !f ) { return false; }

	// Determine the size of the file	
	fseek(f, 0, SEEK_END);
	int length = ftell(f);
	fseek(f, 0, SEEK_SET);

	char *script = new char[length];
	char *final_script = new char[length];
	fread(script, length, 1, f);
	fclose(f);

	//discard existing script code for this module.
	m_Engine->Discard(pszModules[nModule]);

	//now look for #includes.
	length = FindAndLoadIncludes(script, length, final_script, nModule, nSection);

	// Compile the script
	m_Engine->AddScriptSection(pszModules[nModule], pszSections[nSection], final_script, length);
	if ( bBuildModule )
	{
		m_Engine->Build(pszModules[nModule]);
	}

	delete [] script;
	delete [] final_script;

	if ( !m_pContext )
	{
		m_pContext = m_Engine->CreateContext();
	}

	return true;
}

int ScriptSystem::FindAndLoadIncludes(const char *inScript, int inLength, char *outScript, int nModule, int nSection)
{
	int outLength = inLength;

	//1. look for and load includes
	int incEnd = 0;
	for (int l=0; l<inLength-8; l++)
	{
		if ( inScript[l] == '#' )
		{
			if ( inScript[l+1] == 'i' && inScript[l+7] == 'e' )
			{
				l += 8;
				//now keep looking until a " is found.
				while ( inScript[l] != '"' ) { l++; }
				l++;
				char szInclude[32];
				int c=0;
				while ( inScript[l] != '"' )
				{
					szInclude[c++] = inScript[l];
					l++;
				}
				szInclude[c] = 0;
				l++;
				incEnd = l;

				LoadScript(nModule, nSection, szInclude, false);
			}
		}
	}
	
	//2. copy the script, starting on the line AFTER the last include
	if ( incEnd == 0 )
	{
		memcpy(outScript, inScript, inLength);
	}
	else
	{
		outLength = inLength - incEnd;
		memcpy(outScript, &inScript[incEnd], outLength);
	}

	return outLength;
}

bool ScriptSystem::LoadScript(int nModule, int nSection, const char *pszFile, bool bBuildModule)
{
	FILE *f = fopen(pszFile, "rb");
	if ( !f ) { return false; }

	// Determine the size of the file	
	fseek(f, 0, SEEK_END);
	int length = ftell(f);
	fseek(f, 0, SEEK_SET);

	char *script = new char[length];
	char *final_script = new char[length];
	fread(script, length, 1, f);
	fclose(f);

	//now look for #includes.
	length = FindAndLoadIncludes(script, length, final_script, nModule, nSection);

	// Compile the script
	int ret;
	ret = m_Engine->AddScriptSection(pszModules[nModule], pszSections[nSection], final_script, length);
	if ( bBuildModule )
	{
		ret = m_Engine->Build(pszModules[nModule]);
	}

	delete [] script;
	delete [] final_script;

	if ( !m_pContext )
	{
		m_pContext = m_Engine->CreateContext();
	}

	return true;
}

SHANDLE ScriptSystem::GetFunc(int nModule, const char *pszFunc)
{
	// Do some preparation before execution
	return m_Engine->GetFunctionIDByName(pszModules[nModule], pszFunc);
}

void ScriptSystem::SetCurFunction(SHANDLE hFunc)
{
	// Execute the script function
	m_pContext->Prepare(hFunc);
}

void ScriptSystem::ExecuteFunc()
{
	m_pContext->Execute();
}

void ScriptSystem::SetGlobalStoreVal(int var, float val)
{
	if ( var >= 0 && var < 32 )
	{
		m_afGlobalStore[var] = val;
	}
}

float ScriptSystem::GetGlobalStoreVal(int var)
{
	float ret = 0.0f;

	if ( var >= 0 && var < 32 )
	{
		ret = m_afGlobalStore[var];
	}

	return ret;
}

//Timers
void ScriptSystem::SetTimer(int timer, int delay)
{
	if ( timer >= 0 && timer < 32 )
	{
		m_aTimers[ timer ] = delay;
	}
}

int ScriptSystem::GetTimer(int timer)
{
	if ( timer >= 0 && timer < 32 )
	{
		return m_aTimers[ timer ];
	}
	return 0;
}

void ScriptSystem::System_Print(string &szItem)
{
	System::SetTextDisp( szItem.c_str() );
}

void ScriptSystem::System_PrintIndex(int idx)
{
	System::SetTextDispIndex(idx);
}

char _szTempString[64];

void ScriptSystem::System_StartString()
{
	_szTempString[0] = 0;
}

void ScriptSystem::System_EndString()
{
	System::SetTextDisp(_szTempString);
}

void ScriptSystem::System_AppendString(string& szStr)
{
	sprintf(_szTempString, "%s%s", _szTempString, szStr.c_str());
}

void ScriptSystem::System_AppendFloat(float fVal)
{
	sprintf(_szTempString, "%s%f", _szTempString, fVal);
}

void ScriptSystem::System_AppendInt(int iVal)
{
	sprintf(_szTempString, "%s%d", _szTempString, iVal);
}

void ScriptSystem::Update()
{
	Log(LogVerbose, "ScriptSystem Update");

	for (int i=0; i<32; i++)
	{
		if ( m_aTimers[i] > 0 )
		{
			m_aTimers[i]--;
		}
	}
}
