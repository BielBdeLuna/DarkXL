#include "Console.h"
#include "Font.h"
#include <sstream>
#include <iostream>

enum
{
	COLOR_BLACK=0,
	COLOR_RED,
	COLOR_GREEN,
	COLOR_DKGREEN,
	COLOR_YELLOW,
	COLOR_BLUE,
	COLOR_CYAN,
	COLOR_PURPLE,
	COLOR_ORANGE,
	COLOR_WHITE,
};

Vector4 m_aColorTable[]=
{
	Vector4(0.0f, 0.0f, 0.0f, 1.0f),
	Vector4(1.0f, 0.0f, 0.0f, 1.0f),
	Vector4(0.0f, 1.0f, 0.0f, 1.0f),
	Vector4(0.0f, 0.5f, 0.0f, 1.0f),
	Vector4(1.0f, 1.0f, 0.0f, 1.0f),
	Vector4(0.0f, 0.0f, 1.0f, 1.0f),
	Vector4(0.0f, 1.0f, 1.0f, 1.0f),
	Vector4(1.0f, 0.0f, 1.0f, 1.0f),
	Vector4(1.0f, 0.5f, 0.0f, 1.0f),
	Vector4(1.0f, 1.0f, 1.0f, 1.0f),
};

Console::Console(void)
{
	m_DefaultCommand = NULL;
	m_MaxCommands = 32;
	m_MaxTextLines = 256;
	m_pFont = NULL;
	m_nCommandHistory = -1;
	m_nScrollOffs = 0;
	m_bActive = false;
	m_bPaused = false;
	m_fAnimDropDown = 0.0f;
	m_fAnimDelta = 0.0f;
	m_nBlinkFrame = 0;
	m_CaretPos = 0;

	m_bEchoCommands = true;
	m_hBackground = 0;

	m_Color.Set(0.125f, 0.125f*1.5f, 0.125f, 0.85f);
}

Console::~Console(void)
{
}

bool Console::_Compare_nocase(ConsoleItem first, ConsoleItem second)
{
	int cmp = stricmp( first.name.c_str(), second.name.c_str() );
	return (cmp < 0) ? true : false;
}

void Console::AddItem(const string& itemName, void *ptr, ConsoleItemType type, const string& itemHelp)
{
	ConsoleItem item;
	item.name = itemName;
	item.help = itemHelp;
	item.type = type;
	if ( type == CTYPE_FUNCTION )
		item.func = (ConsoleFunction)ptr;
	else
		item.varPtr = ptr;

	m_ItemList.push_back(item);
	m_ItemList.sort( _Compare_nocase );
}

void Console::RemoveItem(const string& itemName)
{
	//add ability to remove an item, later...
}

void Console::SetDefaultCommand(ConsoleFunction func)
{
	m_DefaultCommand = func;
}

void Console::Print(const string& text)
{
	m_TextBuffer.push_back(text);
	if ( m_TextBuffer.size() > m_MaxTextLines )
	{
		m_TextBuffer.erase( m_TextBuffer.begin() );
	}
}

void Console::PrintCommandHelp(const string& cmd)
{
	bool bCmdFound = false;
	list<ConsoleItem>::const_iterator iter;
	for (iter = m_ItemList.begin(); iter != m_ItemList.end(); ++iter)
	{
		if ( (*iter).name == cmd )
		{
			Print("^8---------------------------------------------------");
			Print("^8" + (*iter).name + ": ");
			Print("^2" + (*iter).help);
			Print("^8---------------------------------------------------");
			bCmdFound = true;
			break;
		}
	}
	if ( bCmdFound == false )
	{
		Print("^1'" + cmd + "' Not Found, no help available.");
	}
}

void Console::PassKey(char key)
{
	if ( m_bActive == false )
		return;

	if ( key >= ' ' && key <= '}' && key != '`' )
	{
		if ( m_CaretPos == m_CommandLine.length() )
			m_CommandLine += key;
		else
			m_CommandLine.insert(m_CommandLine.begin()+m_CaretPos, (char)key);

		if ( m_CaretPos < m_CommandLine.length() ) m_CaretPos++;
	}
}

void Console::PassEnter()
{
	if ( m_bActive == false )
		return;

	if ( m_CommandLine.length() > 0 )
	{
		ParseCommandLine();
		m_CommandLine.clear();
	}
	m_nCommandHistory = -1;
	m_CaretPos = 0;
}

void Console::PassBackspace()
{
	if ( m_bActive == false )
		return;

	size_t length = m_CommandLine.length();
	if ( length > 0 )
	{
		if ( m_CaretPos > 0 )
			m_CommandLine.erase( m_CaretPos-1, 1 );

		if ( m_CaretPos > 0 ) m_CaretPos--;
	}
}

void Console::PassVirtualKey(int key)
{
	if ( key == VK_OEM_3 )
	{
		if ( m_bActive == false )
		{
			m_fAnimDropDown = 0.0f;
			m_fAnimDelta = 0.1f;
			m_bActive = true;
		}
		else
		{
			m_fAnimDropDown = 1.0f;
			m_fAnimDelta = -0.1f;
		}
	}
	if ( m_bActive == false )
		return;

	if ( key == VK_UP )
	{
		if ( m_nCommandHistory != 0 ) m_nCommandHistory--;
		if ( m_nCommandHistory < -1 )
		{
			m_nCommandHistory = m_CommandBuffer.size()-1;
		}
		if ( m_nCommandHistory == -1 )
		{
			m_CommandLine.clear();
		}
		else
		{
			m_CommandLine = m_CommandBuffer[m_nCommandHistory];
		}
		m_CaretPos = m_CommandLine.length();
	}
	else if ( key == VK_DOWN )
	{
		if ( m_nCommandHistory > -1 )
			m_nCommandHistory++;
		
		if ( m_nCommandHistory >= m_CommandBuffer.size() )
			m_nCommandHistory = -1;

		if ( m_nCommandHistory == -1 )
		{
			m_CommandLine.clear();
		}
		else
		{
			m_CommandLine = m_CommandBuffer[m_nCommandHistory];
		}
		m_CaretPos = m_CommandLine.length();
	}
	if ( key == VK_DELETE )
	{
		size_t length = m_CommandLine.length();
		if ( length > 0 )
		{
			if ( m_CaretPos < m_CommandLine.length() )
				m_CommandLine.erase( m_CaretPos, 1 );
		}
	}

	if ( key == VK_LEFT )
	{
		if ( m_CaretPos > 0 ) m_CaretPos--;
	}
	else if ( key == VK_RIGHT )
	{
		if ( m_CaretPos < m_CommandLine.length() ) m_CaretPos++;
	}

	if ( key == VK_PRIOR )
	{
		m_nScrollOffs -= 3;
		if ( m_nScrollOffs < 23-m_TextBuffer.size() )
			m_nScrollOffs = 23-m_TextBuffer.size();
		if ( m_nScrollOffs > 0 )
			m_nScrollOffs = 0;
	}
	else if ( key == VK_NEXT )
	{
		m_nScrollOffs += 3;
		if ( m_nScrollOffs > 0 )
			m_nScrollOffs = 0;
	}
}

void Console::LoadNewBackground(const char *pszBackground)
{
	int nTexWidth, nTexHeight;
	m_hBackground = Driver3D_DX9::LoadTexture(pszBackground, nTexWidth, nTexHeight);
}

void Console::Render()
{
	if ( m_bActive == false )	
		return;

	if ( m_hBackground == 0 )
	{
		int nTexWidth, nTexHeight;
		m_hBackground = Driver3D_DX9::LoadTexture("ConsoleBackground.png", nTexWidth, nTexHeight);
	}

	if ( m_fAnimDelta != 0.0f )
	{
		m_fAnimDropDown += m_fAnimDelta;
		if ( m_fAnimDelta < 0.0f )
		{
			if ( m_fAnimDropDown <= 0.0f )
			{
				m_fAnimDropDown = 0.0f;
				m_fAnimDelta = 0.0f;
				m_bActive = false;
				return;
			}
		}
		else
		{
			if ( m_fAnimDropDown >= 1.0f )
			{
				m_fAnimDropDown = 1.0f;
				m_fAnimDelta = 0.0f;
			}
		}
	}

	//Draw background.
	Driver3D_DX9::EnableZTest(false);
	Driver3D_DX9::SetShaders(Driver3D_DX9::VS_SHADER_SCREEN, Driver3D_DX9::PS_SHADER_SCREEN);

	{
		float y2 = m_fAnimDropDown*0.48f + (1.0f-m_fAnimDropDown)*1.0f;

		Vector3 polygon[4];
		float u[4] = { 0, 1, 1, 0 };
		float v[4] = { 1-m_fAnimDropDown+0.004f, 1-m_fAnimDropDown+0.004f, 1, 1 };
		Driver3D_DX9::SetAmbientColor(m_Color.x, m_Color.y, m_Color.z, m_Color.w*0.5f);
		polygon[0].Set(0.0f, 1.00f, 0.9f);
		polygon[1].Set(1.0f, 1.00f, 0.9f);
		polygon[2].Set(1.0f, y2, 0.9f);
		polygon[3].Set(0.0f, y2, 0.9f);
		Driver3D_DX9::SetTexture(m_hBackground);
		Driver3D_DX9::RenderPolygon(4, polygon, u, v);

		y2 = m_fAnimDropDown*0.52f;

		float afLineX[] = { 0.0f, 1.0f };
		float afLineY[] = { y2, y2 };
		Driver3D_DX9::RenderLines2D(1, afLineX, afLineY, Vector4(0,0,0,1));
	}

	float aspectScale = Driver3D_DX9::GetAspectScale();
	Driver3D_DX9::EnableAlphaBlend(true);
	Driver3D_DX9::ClampTexCoords(true, true);

	//now print stuff.
	int start = 0;
	if ( m_TextBuffer.size() > 23 )
	{
		start = (int)m_TextBuffer.size() - 23;
		start += m_nScrollOffs;
	}

	float yOffs = -(1.0f-m_fAnimDropDown)*480.0f;

	static char szFinalTextLine[256];
	for (int y=0; y<23 && y<(int)m_TextBuffer.size(); y++)
	{
		const char *pszTextLine = m_TextBuffer[y+start].c_str();
		int l = (int)strlen(pszTextLine);
		int cIdx=0;
		int color = COLOR_WHITE;
		for (int c=0; c<l; c++)
		{
			if ( pszTextLine[c] == '^' && c < l-1 )
			{
				char szColor[2] = { pszTextLine[c+1], 0 };
				//only take the first color for now...
				if (color==COLOR_WHITE) color = atoi(szColor);
				c++;
			}
			else
			{
				szFinalTextLine[cIdx++] = pszTextLine[c];
			}
		}
		szFinalTextLine[cIdx] = 0;

		Driver3D_DX9::Print(szFinalTextLine, 5.0f/1280.0f, (float)(y*20+2+yOffs)/960.0f, &m_aColorTable[color].x);
	}

	Driver3D_DX9::Print(">", 1.0f/1280.0f, (460.0f+yOffs)/960.0f, &m_aColorTable[COLOR_YELLOW].x);
	Driver3D_DX9::Print(m_CommandLine.c_str(), 10.0f/1280.0f, (460.0f+yOffs)/960.0f, &m_aColorTable[COLOR_YELLOW].x);

	if ( m_CaretPos > m_CommandLine.length() )
		m_CaretPos = m_CommandLine.length();

	strcpy(szFinalTextLine, m_CommandLine.c_str());
	if ( szFinalTextLine[m_CaretPos-1] == ' ' )
		 szFinalTextLine[m_CaretPos-1] = '_';
	int scr_w, scr_h;
	Driver3D_DX9::GetScreenSize(scr_w, scr_h);
	float length = Driver3D_DX9::GetLength(szFinalTextLine, m_CaretPos);
	if ( m_nBlinkFrame < 30 )
	{
		Driver3D_DX9::Print("_", 10.0f/1280.0f + length/(float)scr_w, (460.0f+yOffs)/960.0f, &m_aColorTable[COLOR_YELLOW].x);
	}
	else
	{
		Vector4 dkYellow(m_aColorTable[COLOR_YELLOW].x*0.5f, m_aColorTable[COLOR_YELLOW].y*0.5f, m_aColorTable[COLOR_YELLOW].z*0.5f, 1.0f);
		Driver3D_DX9::Print("_", 10.0f/1280.0f + length/(float)scr_w, (460.0f+yOffs)/960.0f, &dkYellow.x);
	}
	m_nBlinkFrame = (m_nBlinkFrame+1)%60;

	char versionStr[64];
	sprintf(versionStr, "DarkXL version %d.%02d", 9, 8);
	Driver3D_DX9::Print(versionStr, 1100.0f/1280.0f, (480.0f+yOffs)/960.0f, &m_aColorTable[COLOR_GREEN].x);

	Driver3D_DX9::EnableZTest(true);
	Driver3D_DX9::EnableAlphaTest(false);
	Driver3D_DX9::ClampTexCoords(false, false);
}

void Console::PrintCommands(const char *pszText/*=NULL*/)
{
	char szCmdText[256];
	size_t l=0;
	if ( pszText ) 
	{
		l = strlen(pszText);
		if ( pszText[l-1] == '*' || pszText[l-1] == '?' )
			l--;
	}

	list<ConsoleItem>::const_iterator iter;
	for (iter = m_ItemList.begin(); iter != m_ItemList.end(); ++iter)
	{
		if ( pszText != NULL && l > 0 ) 
		{
			if ( strnicmp(pszText, (*iter).name.c_str(), l) != 0 )
				continue;
		}
		sprintf(szCmdText, "^7%s", (*iter).name.c_str());
		Print(szCmdText);
	}
}

bool Console::ParseCommandLine()
{
	ostringstream out;
	string::size_type index = 0;
	vector<string> arguments;
	list<ConsoleItem>::const_iterator iter;

	//add to text buffer - command echo.
	if ( m_bEchoCommands )
		Print("^4>" + m_CommandLine);

	//add to the command buffer.
	m_CommandBuffer.push_back( m_CommandLine );
	if ( m_CommandBuffer.size() > m_MaxCommands )
		m_CommandBuffer.erase( m_CommandBuffer.begin() );

	//tokenize
	int count;
	int prev_index = 0;
	bool bInQuotes = false;
	string::size_type l = m_CommandLine.length();
	for ( string::size_type c=0; c<l; c++ )
	{
		if ( (m_CommandLine.at(c) == ' ' && bInQuotes == false) || c==l-1 )
		{
			count = c-prev_index;
			if ( c == l-1 ) //this will happen for the last argument if no extra space is added.
				count++;

			//remove the quotes from the argument. this makes arguments with and without quotes functionality identical
			//if there are no spaces.
			if ( m_CommandLine.at(prev_index) == '"' )
				prev_index++;
			if ( c > 0 && m_CommandLine.at(c-1) == '"' )
				count-=2;
			else if ( m_CommandLine.at(c) == '"' )
				count-=2;

			arguments.push_back( m_CommandLine.substr(prev_index, count) );
			prev_index = c+1;
		}
		else if ( m_CommandLine.at(c) == '"' )
		{
			bInQuotes = !bInQuotes;
		}
	}

	//execute (must look for a command or variable).
	for (iter = m_ItemList.begin(); iter != m_ItemList.end(); ++iter)
	{
		if ( iter->name == arguments[0] )
		{
			switch (iter->type)
			{
				case CTYPE_UCHAR:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << *((unsigned char *)(*iter).varPtr);
						Print(out.str());
					}
					else
					{
						*((unsigned char *)(*iter).varPtr) = (unsigned char)atoi(arguments[1].c_str());
					}
					return true;
					break;
				case CTYPE_CHAR:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << *((char *)(*iter).varPtr);
						Print(out.str());
					}
					else
					{
						*((char *)(*iter).varPtr) = (char)atoi(arguments[1].c_str());
					}
					return true;
					break;
				case CTYPE_UINT:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << *((unsigned int *)(*iter).varPtr);
						Print(out.str());
					}
					else
					{
						*((unsigned int *)(*iter).varPtr) = (unsigned int)atoi(arguments[1].c_str());
					}
					return true;
					break;
				case CTYPE_INT:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << *((int *)(*iter).varPtr);
						Print(out.str());
					}
					else
					{
						*((int *)(*iter).varPtr) = (int)atoi(arguments[1].c_str());
					}
					return true;
					break;
				case CTYPE_FLOAT:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << *((float *)(*iter).varPtr);
						Print(out.str());
					}
					else
					{
						*((float *)(*iter).varPtr) = (float)atof(arguments[1].c_str());
					}
					return true;
					break;
				case CTYPE_BOOL:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << ( *((bool *)(*iter).varPtr) ? "1" : "0" );
						Print(out.str());
					}
					else
					{
						*((bool *)(*iter).varPtr) = atoi(arguments[1].c_str()) ? true : false;
					}
					return true;
					break;
				case CTYPE_STRING:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << *((string *)(*iter).varPtr);
						Print(out.str());
					}
					else
					{
						*((string *)(*iter).varPtr) = arguments[1];
					}
					return true;
					break;
				case CTYPE_CSTRING:
					if ( arguments.size() > 2) return false;
					else if ( arguments.size() == 1)
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << string((char *)(*iter).varPtr);
						Print(out.str());
					}
					else
					{
						strcpy((char *)(*iter).varPtr, arguments[1].c_str());
					}
					return true;
					break;
				case CTYPE_VEC3:
					if ( arguments.size() > 4 ) return false;
					else if ( arguments.size() != 4 )
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << ((Vector3 *)(*iter).varPtr)->x << " " << ((Vector3 *)(*iter).varPtr)->y << " " << 
							((Vector3 *)(*iter).varPtr)->z;
						Print(out.str());
					}
					else
					{
						((Vector3 *)(*iter).varPtr)->x = (float)atof(arguments[1].c_str());
						((Vector3 *)(*iter).varPtr)->y = (float)atof(arguments[2].c_str());
						((Vector3 *)(*iter).varPtr)->z = (float)atof(arguments[3].c_str());
					}
					return true;
					break;
				case CTYPE_VEC4:
					if ( arguments.size() > 5 ) return false;
					else if ( arguments.size() != 5 )
					{
						out.str("");	//clear stringstream
						out << (*iter).name << " = " << ((Vector4 *)(*iter).varPtr)->x << " " << ((Vector4 *)(*iter).varPtr)->y << " " << 
							((Vector4 *)(*iter).varPtr)->z << " " << ((Vector4 *)(*iter).varPtr)->w;
						Print(out.str());
					}
					else
					{
						((Vector4 *)(*iter).varPtr)->x = (float)atof(arguments[1].c_str());
						((Vector4 *)(*iter).varPtr)->y = (float)atof(arguments[2].c_str());
						((Vector4 *)(*iter).varPtr)->z = (float)atof(arguments[3].c_str());
						((Vector4 *)(*iter).varPtr)->w = (float)atof(arguments[4].c_str());
					}
					return true;
					break;
				case CTYPE_FUNCTION:
					(*iter).func(arguments);
					return true;
					break;
				default:
					m_DefaultCommand(arguments);
					return false;
					break;
			}
		}
	}
	m_DefaultCommand(arguments);
	m_CommandLine.clear();

	return false;
}
