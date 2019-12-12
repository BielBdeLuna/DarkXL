#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers
#include <windows.h>
#include "Input.h"
#include "DXL_Console.h"

char Input::m_aKeyState[512];
vector<Input::KeyDownCB_t *> Input::m_KeyDownCB;
float Input::m_fMouseX;
float Input::m_fMouseY;

void Input::Init()
{
	memset(m_aKeyState, 0, 512);
	m_fMouseX = 0.0f;
	m_fMouseY = 0.0f;
}

void Input::Destroy()
{
	vector<KeyDownCB_t *>::iterator iter = m_KeyDownCB.begin();
	vector<KeyDownCB_t *>::iterator end  = m_KeyDownCB.end();
	for (; iter != end; ++iter)
	{
		delete (*iter);
	}
	m_KeyDownCB.clear();
}

void Input::SetKeyDown(int key)
{
	//now fire off any callbacks...
	vector<KeyDownCB_t *>::iterator iter = m_KeyDownCB.begin();
	vector<KeyDownCB_t *>::iterator end  = m_KeyDownCB.end();
	for (; iter != end; ++iter)
	{
		KeyDownCB_t *pKeyDownCB = *iter;

		bool bFireCB = true;
		if ( (pKeyDownCB->nFlags&KDCb_FLAGS_NOREPEAT) && (m_aKeyState[key] != 0) )
			bFireCB = false;

		if ( bFireCB )
		{
			pKeyDownCB->pCB(key);
		}
	}
	m_aKeyState[key] = 1;
	if ( key == VK_LSHIFT || key == VK_RSHIFT )
	{
		m_aKeyState[VK_SHIFT] = 1;
	}

	DXL_Console::SetKeyDown_VirtualKey(key);
}

void Input::SetKeyUp(int key)
{
	m_aKeyState[key] = 0;
}

void Input::ClearAllKeys()
{
	for (int key=0; key<512; key++)
	{
		m_aKeyState[key] = 0;
	}
}

void Input::SetMousePos(float x, float y)
{
	m_fMouseX = x;
	m_fMouseY = y;

	//char szTmp[64];
	//sprintf(szTmp, "%2.1f, %2.1f\n", m_fMouseX, m_fMouseY);
	//OutputDebugString(szTmp);
}

bool Input::AddKeyDownCallback(Input_KeyDownCB pCB, int nFlags)
{
	KeyDownCB_t *pKeyDownCB = new KeyDownCB_t;
	if (pKeyDownCB == NULL)
		return false;

	pKeyDownCB->pCB    = pCB;
	pKeyDownCB->nFlags = nFlags;
	m_KeyDownCB.push_back( pKeyDownCB );

	return true;
}
