#include "Clock.h"
#include <windows.h>
#include <stdio.h>

#define SEC_TO_uS 1000000.0

float Clock::m_fDeltaTime;
float Clock::m_fRealDeltaTime;
int Clock::m_nDeltaTicks;

static LARGE_INTEGER _Timer_Freq;
static u64 _Start_Tick[16];
LONGLONG _GetCurTickCnt();

bool Clock::Init()
{
	BOOL bRet = QueryPerformanceFrequency(&_Timer_Freq);
	return (bRet) ? true : false;
}

void Clock::StartTimer(int timerID/*=0*/)
{
	assert( timerID < 16 );
	_Start_Tick[timerID] = _GetCurTickCnt();
}

float Clock::GetDeltaTime(float fMax, int timerID/*=0*/)
{
	assert( timerID < 16 );
	u64 End = _GetCurTickCnt();

	float fTimeDelta = (float)( (double)(End - _Start_Tick[timerID]) / (double)(_Timer_Freq.QuadPart) );
	if ( fTimeDelta > fMax ) { fTimeDelta = fMax; }

	return fTimeDelta;
}

u64 Clock::GetDeltaTime_uS(int timerID/*=0*/)
{
	u64 End = _GetCurTickCnt();
	double quadPart_uS = (double)(_Timer_Freq.QuadPart) / SEC_TO_uS;
	return (u64)( (double)(End - _Start_Tick[timerID]) / quadPart_uS );
}

LONGLONG _GetCurTickCnt()
{
	LARGE_INTEGER lcurtick;
	QueryPerformanceCounter(&lcurtick);

	return lcurtick.QuadPart;
}
