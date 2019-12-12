#pragma once
#include "angelscript.h"
#include "scriptstring.h"

#include <string>
using namespace std;

typedef int SHANDLE;

class ScriptSystem
{
public:
	enum
	{
		//Script modules.
		SCR_MODULE_LOGICS=0,
		SCR_MODULE_WEAPON,
		//Script sections.
		SCR_SECTION_CORE=0,
		SCR_SECTION_USER,
	} ScriptModules_e;
public:
	//Intialize and Destroy
	static bool Init();
	static void Destroy();
	static void Update();

	//Register functions and variables from the engine.
	static bool RegisterFunc(const char *decl, const asUPtr& pFunc);
	static bool RegisterVar(const char *decl, void *pVar);

	//Load the game scripts.
	static bool LoadScript(int nModule, int nSection, const char *pszFile, bool bBuildModule=true);
	static bool ReloadScript(int nModule, int nSection, const char *pszFile, bool bBuildModule=true);
	static int FindAndLoadIncludes(const char *inScript, int inLength, char *outScript, int nModule, int nSection);

	//Get Script function ID by name.
	static SHANDLE GetFunc(int nModule, const char *pszFunc);
	//Set the current script function to execute.
	static void SetCurFunction(SHANDLE hFunc);
	//Execute the current script function.
	static void ExecuteFunc();

	//Global memory store that can be accessed by the scripts...
	static void SetGlobalStoreVal(int var, float val);
	static float GetGlobalStoreVal(int var);
	//Timers
	static void SetTimer(int timer, int delay);
	static int GetTimer(int timer);
	static void System_Print(string &szItem);
	static void System_PrintIndex(int idx);
	static void System_StartString();
	static void System_EndString();
	static void System_AppendString(string& szStr);
	static void System_AppendFloat(float fVal);
	static void System_AppendInt(int iVal);
};
