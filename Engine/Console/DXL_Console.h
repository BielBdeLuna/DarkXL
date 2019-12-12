#pragma once
#include "Console.h"
class Font;

class DXL_Console
{
public:
	static bool Init();
	static void Destroy();

	static void SetBackspace();
	static void SetEnter();
	static void SetKeyDown(int key);
	static void SetKeyDown_VirtualKey(int key);
	static void Render();

	static void RegisterCmd(const string& itemName, void *ptr, Console::ConsoleItemType type, const string& itemHelp);
	static void SetFont(Font *pFont);

	static void Print(const string& szMsg);
	static void PrintF(const char *pszString, ...);

	static bool IsActive();
	static bool IsPaused();

private:
	static Console *s_pConsole;
	static void _DefaultConsoleFunc(const vector<string>& args);
	static void _Echo(const vector<string>& args);
	static void _CmdList(const vector<string>& args);
	static void _Help(const vector<string>& args);
	static void _ConsoleTex(const vector<string>& args);
};
