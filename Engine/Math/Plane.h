#pragma once

#include "Vector3.h"
#include "Vector4.h"

typedef enum
{
	NEGATIVE = -1,
	ON_PLANE =  0,
	POSITIVE = +1
} HalfSpace_e;

class Plane
{
public:
	inline Plane(float fA=0.0f, float fB=0.0f, float fC=0.0f, float fD=0.0f) { a = fA; b = fB; c = fC; d = fD; }

	float Normalize();

	inline float Distance(Vector3& vPt)
	{
		return a*vPt.x + b*vPt.y + c*vPt.z + d;
	}

	inline HalfSpace_e ClassifyPoint(const Vector3& vPt);

	void Build(Vector3 *vPoints);

	bool Build(const Vector3& v0, const Vector3& v1, const Vector3& v2);

	void FillVec4(Vector4& rvVec) { rvVec.Set(a, b, c, d); }

	float a, b, c, d;
};

class PlaneD
{
public:
	inline PlaneD(double fA=0.0, double fB=0.0, double fC=0.0, double fD=0.0) { a = fA; b = fB; c = fC; d = fD; }

	double Normalize();

	inline double Distance(dVector3& vPt)
	{
		return a*vPt.x + b*vPt.y + c*vPt.z + d;
	}

	inline HalfSpace_e ClassifyPoint(const dVector3& vPt);

	void Build(dVector3 *vPoints);

	bool Build(const dVector3& v0, const dVector3& v1, const dVector3& v2);

	void FillVec4(dVector4& rvVec) { rvVec.Set(a, b, c, d); }

	double a, b, c, d;
};