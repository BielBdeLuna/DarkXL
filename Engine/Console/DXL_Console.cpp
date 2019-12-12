#include "DXL_Console.h"
#include <windows.h>

Console *DXL_Console::s_pConsole;
static char _tmpStr[512];

void DXL_Console::_DefaultConsoleFunc(const vector<string>& args)
{
	string errorStr;
	errorStr = "^1'" + args[0] + "' is not a recognized command.";

	s_pConsole->Print(errorStr);
}

void DXL_Console::_Echo(const vector<string>& args)
{
	s_pConsole->Print(args[1]);
}

void DXL_Console::_CmdList(const vector<string>& args)
{
	if ( args.size() <= 1 )
		s_pConsole->PrintCommands();
	else
		s_pConsole->PrintCommands(args[1].c_str());
}

void DXL_Console::_ConsoleTex(const vector<string>& args)
{
	if ( args.size() > 1 )
	{
		s_pConsole->LoadNewBackground( args[1].c_str() );
	}
}

void DXL_Console::_Help(const vector<string>& args)
{
	if ( args.size() == 1 )
	{
		s_pConsole->Print("^8--------------------- DarkXL Console Help --------------------");
		s_pConsole->Print("^6To view the list of commands type: cmdlist");
		s_pConsole->Print("^8To get help for a specific command type: help command");
		s_pConsole->Print("^8To select previous commands, use the up and down arrows.");
		s_pConsole->Print("^8To scroll the text window, use the Page Up and Page Down keys.");
		s_pConsole->Print("^8------------------------------------------------------------------------");
	}
	else
	{
		s_pConsole->PrintCommandHelp(args[1]);
	}
}

bool DXL_Console::Init()
{
	s_pConsole = new Console();
	s_pConsole->SetDefaultCommand( _DefaultConsoleFunc );
	s_pConsole->AddItem("echo", _Echo, Console::CTYPE_FUNCTION, "Echo the argument to the console.");
	s_pConsole->AddItem("cmdlist", _CmdList, Console::CTYPE_FUNCTION, "Show all console commands.");
	s_pConsole->AddItem("help", _Help, Console::CTYPE_FUNCTION, 
		"Show console help. If an argument is passed, it shows help for a specific command. '>help cmdList' will show help for the 'cmdList' command");
	s_pConsole->AddItem("con_cmdecho", &s_pConsole->m_bEchoCommands, Console::CTYPE_BOOL, 
		"Sets whether command echo is enabled (0/1). If enabled, the command line is echoed in the console when enter is pressed.");
	s_pConsole->AddItem("g_pause", &s_pConsole->m_bPaused, Console::CTYPE_BOOL, "Pauses the game if set to 1 (0/1).");
	s_pConsole->AddItem("con_color", &s_pConsole->m_Color, Console::CTYPE_VEC4, "Console color (RGBA).");
	s_pConsole->AddItem("con_tex", _ConsoleTex, Console::CTYPE_FUNCTION, "Load a new console background texture.");
	return (s_pConsole ? true : false);
}

void DXL_Console::Destroy()
{
	delete s_pConsole;
}

void DXL_Console::SetBackspace()
{
	s_pConsole->PassBackspace();
}

void DXL_Console::SetEnter()
{
	s_pConsole->PassEnter();
}

void DXL_Console::SetKeyDown(int key)
{
	s_pConsole->PassKey(key);
}

void DXL_Console::SetKeyDown_VirtualKey(int key)
{
	s_pConsole->PassVirtualKey(key);
}

void DXL_Console::Render()
{
	s_pConsole->Render();
}

void DXL_Console::RegisterCmd(const string& itemName, void *ptr, Console::ConsoleItemType type, const string& itemHelp)
{
	s_pConsole->AddItem(itemName, ptr, type, itemHelp);
}

void DXL_Console::SetFont(Font *pFont)
{
	s_pConsole->SetFont( pFont );
}

bool DXL_Console::IsActive() 
{ 
	return s_pConsole->IsActive(); 
}

bool DXL_Console::IsPaused()
{
	return s_pConsole->IsPaused();
}

void DXL_Console::Print(const string& szMsg)
{
	s_pConsole->Print(szMsg);
}

void DXL_Console::PrintF(const char *pszString, ...)
{
	va_list args;
	va_start(args, pszString);
	_vsnprintf( _tmpStr, 512, pszString, args );
	va_end(args);

	s_pConsole->Print(_tmpStr);
}
