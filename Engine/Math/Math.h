#pragma once

#include <math.h>

class Math
{
public:
	static inline unsigned int RoundNextPow2(unsigned int x)
	{
		x = x-1;
		x = x | (x>>1);
		x = x | (x>>2);
		x = x | (x>>4);
		x = x | (x>>8);
		x = x | (x>>16);
		return x + 1;
	}

	static inline float saturate(float x)
	{
		return x > 0.0f ? ((x < 1.0f) ? x : 1.0f) : 0.0f;
	}

	static inline float sign(float x)
	{
		return x >= 0.0f ? 1.0f : -1.0f;
	}

	static inline float signZero(float x, float e)
	{
		float r = 0.0f;
		if ( fabsf(x) > e )
		{
			r = (x > 0.0f) ? 1.0f : -1.0f;
		}
		return r;
	}

	static inline float clamp(float x, float a, float b)
	{
		float c = (x>a) ? x : a;
		c = (c<b) ? c : b;

		return c;
	}

	static void ClosestPointToLine2D(float x, float y, float x0, float y0, float x1, float y1, float& ix, float& iy)
	{
		float d2 = (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0);
		float lu;
		if ( d2 <= 0.00000001f ) { ix = x; iy = y; return; }
		
		float ood = 1.0f/sqrtf(d2);
		lu = ( (x - x0)*(x1-x0) + (y-y0)*(y1-y0) ) / d2;
		lu = Math::clamp(lu, 0.0f, 1.0f);
		ix = x0 + lu*(x1-x0);
		iy = y0 + lu*(y1-y0);

		float dx, dy;
		dx = ix - x; dy = iy - y;
		d2 = dx*dx + dy*dy;
	}

	static float DistPointLine2D_Sqr(float x, float y, float x0, float y0, float x1, float y1)
	{
		float d2 = (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0);
		float lu;
		if ( d2 <= 0.00000001f ) { return 0.0f; }
		
		float ood = 1.0f/sqrtf(d2);
		lu = ( (x - x0)*(x1-x0) + (y-y0)*(y1-y0) ) / d2;
		lu = Math::clamp(lu, 0.0f, 1.0f);
		float ix = x0 + lu*(x1-x0);
		float iy = y0 + lu*(y1-y0);

		float dx, dy;
		dx = ix - x; dy = iy - y;
		d2 = dx*dx + dy*dy;

		return d2;
	}
};
