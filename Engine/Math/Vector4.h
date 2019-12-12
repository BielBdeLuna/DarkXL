#pragma once
#include <math.h>
#include "Vector3.h"

class Vector4
{
public:
	Vector4(void) { x = 0.0f; y = 0.0f; z = 0.0f; w = 0.0f; }
	Vector4(float _x, float _y, float _z, float _w) { x = _x; y = _y; z = _z; w = _w; }
	~Vector4(void) {;}

	float Normalize();
	float Normalize3();
	float Length()
	{
		float d2 = x*x + y*y + z*z + w*w;
		if ( d2 > 0.000001f )
		{
			return sqrtf(d2);
		}
		return 0.0f;
	}

	float Dot(Vector4& A) { return this->x*A.x + this->y*A.y + this->z*A.z + this->w*A.w; }

	void Set(float _x, float _y, float _z, float _w) { x = _x; y = _y; z = _z; w = _w; }

	Vector3& v3() { m_v3.Set(x, y, z); return m_v3; }

	float x, y, z, w;
	Vector3 m_v3;

	static Vector4 One;
	static Vector4 Half;
	static Vector4 Zero;
};

class dVector4
{
public:
	dVector4(void) { x = 0.0f; y = 0.0f; z = 0.0f; w = 0.0f; }
	dVector4(double _x, double _y, double _z, double _w) { x = _x; y = _y; z = _z; w = _w; }
	~dVector4(void) {;}

	double Normalize();
	double Length()
	{
		double d2 = x*x + y*y + z*z + w*w;
		if ( d2 > 0.000000001 )
		{
			return sqrt(d2);
		}
		return 0.0;
	}

	double Dot(dVector4& A) { return this->x*A.x + this->y*A.y + this->z*A.z + this->w*A.w; }

	void Set(double _x, double _y, double _z, double _w) { x = _x; y = _y; z = _z; w = _w; }

	dVector3& v3() { m_v3.Set(x, y, z); return m_v3; }

	double x, y, z, w;
	dVector3 m_v3;

	static dVector4 One;
	static dVector4 Half;
	static dVector4 Zero;
};
