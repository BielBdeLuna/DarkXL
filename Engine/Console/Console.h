#pragma once

#include <string>
#include <vector>
#include <list>
#include "Driver3D_DX9.h"
#include "Vector4.h"

using namespace std;
class Font;
class DXL_Console;

class Console
{
public:
	friend DXL_Console;

	enum ConsoleItemType
	{
		CTYPE_UCHAR=0,
		CTYPE_CHAR,
		CTYPE_UINT,
		CTYPE_INT,
		CTYPE_FLOAT,
		CTYPE_BOOL,
		CTYPE_STRING,
		CTYPE_CSTRING,
		CTYPE_VEC3,
		CTYPE_VEC4,
		CTYPE_FUNCTION,
		CTYPE_COUNT
	};

	typedef void (*ConsoleFunction)(const vector<string>& );

public:
	Console(void);
	~Console(void);

	void AddItem(const string& itemName, void *ptr, ConsoleItemType type, const string& itemHelp);
	void RemoveItem(const string& itemName);

	void SetDefaultCommand(ConsoleFunction func);
	void SetMaxCommands(int maxCmd) { m_MaxCommands = maxCmd; }
	void SetFont(Font *pFont) { m_pFont = pFont; }

	void Print(const string& text);
	void PrintCommandHelp(const string& cmd);

	void PassKey(char key);
	void PassEnter();
	void PassBackspace();
	void PassVirtualKey(int key);

	void Render();

	bool IsActive() { return m_bActive; }
	bool IsPaused() { return m_bPaused; }
	void EnableCommandEcho(bool bEnable) { m_bEchoCommands = bEnable; }

	void PrintCommands(const char *pszText=NULL);
	void LoadNewBackground(const char *pszBackground);

private:
	bool ParseCommandLine();

protected:
	struct ConsoleItem
	{
		string name;
		string help;
		ConsoleItemType type;

		union
		{
			void *varPtr;
			ConsoleFunction func;
		};
	};

	vector<string> m_CommandBuffer;
	list<ConsoleItem> m_ItemList;
	vector<string> m_TextBuffer;

	ConsoleFunction m_DefaultCommand;
	string m_CommandLine;

	unsigned int m_MaxCommands;
	unsigned int m_MaxTextLines;
	bool m_bEchoCommands;
	bool m_bPaused;
	int m_nCommandHistory;
	int m_nScrollOffs;
	int m_nBlinkFrame;
	unsigned int m_CaretPos;
	bool m_bActive;

	float m_fAnimDropDown;
	float m_fAnimDelta;

	DHANDLE m_hBackground;

	Font *m_pFont;
	Vector4 m_Color;

private:
	static bool _Compare_nocase(ConsoleItem first, ConsoleItem second);
};
