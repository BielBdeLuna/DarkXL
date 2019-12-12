#pragma once
#include <vector>
using std::vector;

typedef void (*Input_KeyDownCB)(int);

//static input class
//the Windowing system (Win API on Windows XP/Vista/7, Cocoa on OS X) passes the keyboard and mouse
//messages to this class, which is then used by the game systems.
class Input
{
public:
	//init and destroy, done by the OS layer.
	static void Init();
	static void Destroy();
	//called from the OS layer.
	static void SetKeyDown(int key);
	static void SetKeyUp(int key);
	static void SetMousePos(float x, float y);
	static void ClearAllKeys();
	//can be called by any game system.
	inline static bool IsKeyDown(int key) { return m_aKeyState[key] ? true : false; }
	inline static float GetMouseX() { return m_fMouseX; }
	inline static float GetMouseY() { return m_fMouseY; }

	//setup an event callback. Some systems can get key down events - useful for edit boxes and general text editing.
	//this allows systems to be setup that don't use polling and that are somewhat frame rate independent (depending on the OS).
	static bool AddKeyDownCallback( Input_KeyDownCB pCB, int nFlags=KDCb_FLAGS_NONE );
public:
	enum
	{
		KDCb_FLAGS_NONE = 0,
		KDCb_FLAGS_NOREPEAT = 1,
	} KeyDownCB_Flags_e;
private:
	typedef struct
	{
		Input_KeyDownCB pCB;
		int nFlags;
	} KeyDownCB_t;

	static char m_aKeyState[512];
	static vector<KeyDownCB_t *> m_KeyDownCB;
	static float m_fMouseX;
	static float m_fMouseY;
};
