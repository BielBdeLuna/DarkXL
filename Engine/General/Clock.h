#pragma once

#include "globals.h"

class Clock
{
public:
	static bool Init();
	static void StartTimer(int timerID=0);
	static float GetDeltaTime(float fMax, int timerID=0);
	static u64 GetDeltaTime_uS(int timeID=0);

	static float m_fDeltaTime;
	static float m_fRealDeltaTime;
	static int m_nDeltaTicks;
};
