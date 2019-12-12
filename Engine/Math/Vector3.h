#pragma once
#include <math.h>

#ifndef VEC_EPS
#define VEC_EPS 0.0001f
#define VEC_EPS_DOUBLE 0.000000001
#endif

#ifndef MINS
#define MINS(s, t) (s)<(t)?(s):(t)
#define MAXS(s, t) (s)>(t)?(s):(t)
#endif

#define SAFE_RCP(a) a = ( (a!=0)?(1.0f/a):(a) )
#define SAFE_RCP_DBL(a) a = ( (a!=0)?(1.0/a):(a) )

class Vector3
{
public:
	Vector3(void) { x = 0.0f; y = 0.0f; z = 0.0f; }
	Vector3(float _x, float _y, float _z) { x = _x; y = _y; z = _z; }
	~Vector3(void) {;}

	float Normalize();
	float Length()
	{
		float d2 = x*x + y*y + z*z;
		if ( d2 > 0.000001f )
		{
			return sqrtf(d2);
		}
		return 0.0f;
	}
	void Cross(Vector3& A, Vector3& B);
	void CrossAndNormalize(Vector3& A, Vector3& B);
	float Dot(Vector3& A) { return this->x*A.x + this->y*A.y + this->z*A.z; }
	float Dot(const Vector3& A) const { return this->x*A.x + this->y*A.y + this->z*A.z; }
	void Set(float _x, float _y, float _z) { x = _x; y = _y; z = _z; }

	inline Vector3 operator+(Vector3& other) { return Vector3(x+other.x, y+other.y, z+other.z); }
	inline Vector3 operator+(Vector3* other) { return Vector3(x+other->x, y+other->y, z+other->z); }
	inline Vector3 operator+(const Vector3& other) { return Vector3(x+other.x, y+other.y, z+other.z); }
	inline Vector3 operator+(const Vector3* other) { return Vector3(x+other->x, y+other->y, z+other->z); }
	inline Vector3 operator+(float other) { return Vector3(x+other, y+other, z+other); }
	inline Vector3 operator+=(Vector3& other) { return Vector3(x+other.x, y+other.y, z+other.z); }
	inline Vector3 operator+=(Vector3* other) { return Vector3(x+other->x, y+other->y, z+other->z); }
	inline Vector3 operator-(Vector3& other) { return Vector3(x-other.x, y-other.y, z-other.z); }
	inline Vector3 operator-(Vector3* other) { return Vector3(x-other->x, y-other->y, z-other->z); }
	inline Vector3 operator-(const Vector3& other) { return Vector3(x-other.x, y-other.y, z-other.z); }
	inline Vector3 operator-(const Vector3* other) { return Vector3(x-other->x, y-other->y, z-other->z); }
	inline Vector3 operator-(float other) { return Vector3(x-other, y-other, z-other); }
	inline Vector3 operator-=(Vector3& other) { return Vector3(x-other.x, y-other.y, z-other.z); }
	inline Vector3 operator-=(Vector3* other) { return Vector3(x-other->x, y-other->y, z-other->z); }
	inline Vector3 operator*(float scale) { return Vector3(x*scale, y*scale, z*scale); }
	inline Vector3 operator*(Vector3& other) { return Vector3(x*other.x, y*other.y, z*other.z); }
	inline Vector3 operator*(Vector3* other) { return Vector3(x*other->x, y*other->y, z*other->z); }
	inline Vector3 operator*(const Vector3& other) { return Vector3(x*other.x, y*other.y, z*other.z); }
	inline Vector3 operator*(const Vector3* other) { return Vector3(x*other->x, y*other->y, z*other->z); }
	inline Vector3 operator*=(Vector3& other) { return Vector3(x*other.x, y*other.y, z*other.z); }
	inline Vector3 operator*=(Vector3* other) { return Vector3(x*other->x, y*other->y, z*other->z); }
	inline Vector3 operator/(float scale) { return Vector3(x/scale, y/scale, z/scale); }
	inline Vector3 operator-() { return Vector3(-x, -y, -z); }

	inline bool operator==(Vector3& other) { return ( fabsf(x-other.x)<VEC_EPS && fabsf(y-other.y)<VEC_EPS && fabsf(z-other.z)<VEC_EPS )?(true):(false); }
	inline bool operator!=(Vector3& other) { return ( fabsf(x-other.x)>VEC_EPS || fabsf(y-other.y)>VEC_EPS || fabsf(z-other.z)>VEC_EPS )?(true):(false); }

	inline float Mag2() { return (x*x+y*y+z*z); }
	inline float Max() { return ( (x>y)?(x>z?x:z):(y>z?y:z) ); }
	inline float Min() { return ( (x<y)?(x<z?x:z):(y<z?y:z) ); }
	inline void Reciprocal() { SAFE_RCP(x); SAFE_RCP(y); SAFE_RCP(z); }
	inline void Lerp(Vector3& v0, Vector3& v1, float fU)
	{
		x = v0.x + fU*(v1.x - v0.x);
		y = v0.y + fU*(v1.y - v0.y);
		z = v0.z + fU*(v1.z - v0.z);
	}
	inline Vector3 MinVec(Vector3& a, Vector3& b) { return Vector3(MINS(a.x, b.x), MINS(a.y, b.y), MINS(a.z, b.z)); }
	inline Vector3 MaxVec(Vector3& a, Vector3& b) { return Vector3(MAXS(a.x, b.x), MAXS(a.y, b.y), MAXS(a.z, b.z)); }

	inline float Distance(Vector3& vec) 
	{ 
		Vector3 diff = Vector3(x-vec.x, y-vec.y, z-vec.z); 
		return (sqrtf(diff.x*diff.x+diff.y*diff.y+diff.z*diff.z));
	}

	float x, y, z;

	static Vector3 One;
	static Vector3 Half;
	static Vector3 Zero;
};

class dVector3
{
public:
	dVector3(void) { x = 0.0f; y = 0.0f; z = 0.0f; }
	dVector3(double _x, double _y, double _z) { x = _x; y = _y; z = _z; }
	~dVector3(void) {;}

	double Normalize();
	double Length()
	{
		double d2 = x*x + y*y + z*z;
		if ( d2 > 0.00000001f )
		{
			return sqrt(d2);
		}
		return 0.0;
	}
	void Cross(dVector3& A, dVector3& B);
	void CrossAndNormalize(dVector3& A, dVector3& B);
	double Dot(dVector3& A) { return this->x*A.x + this->y*A.y + this->z*A.z; }
	double Dot(const dVector3& A) const { return this->x*A.x + this->y*A.y + this->z*A.z; }
	void Set(double _x, double _y, double _z) { x = _x; y = _y; z = _z; }

	inline dVector3 operator+(dVector3& other) { return dVector3(x+other.x, y+other.y, z+other.z); }
	inline dVector3 operator+(dVector3* other) { return dVector3(x+other->x, y+other->y, z+other->z); }
	inline dVector3 operator+(const dVector3& other) { return dVector3(x+other.x, y+other.y, z+other.z); }
	inline dVector3 operator+(const dVector3* other) { return dVector3(x+other->x, y+other->y, z+other->z); }
	inline dVector3 operator+=(dVector3& other) { return dVector3(x+other.x, y+other.y, z+other.z); }
	inline dVector3 operator+=(dVector3* other) { return dVector3(x+other->x, y+other->y, z+other->z); }
	inline dVector3 operator-(dVector3& other) { return dVector3(x-other.x, y-other.y, z-other.z); }
	inline dVector3 operator-(dVector3* other) { return dVector3(x-other->x, y-other->y, z-other->z); }
	inline dVector3 operator-(const dVector3& other) { return dVector3(x-other.x, y-other.y, z-other.z); }
	inline dVector3 operator-(const dVector3* other) { return dVector3(x-other->x, y-other->y, z-other->z); }
	inline dVector3 operator-=(dVector3& other) { return dVector3(x-other.x, y-other.y, z-other.z); }
	inline dVector3 operator-=(dVector3* other) { return dVector3(x-other->x, y-other->y, z-other->z); }
	inline dVector3 operator*(double scale) { return dVector3(x*scale, y*scale, z*scale); }
	inline dVector3 operator*(dVector3& other) { return dVector3(x*other.x, y*other.y, z*other.z); }
	inline dVector3 operator*(dVector3* other) { return dVector3(x*other->x, y*other->y, z*other->z); }
	inline dVector3 operator*(const dVector3& other) { return dVector3(x*other.x, y*other.y, z*other.z); }
	inline dVector3 operator*(const dVector3* other) { return dVector3(x*other->x, y*other->y, z*other->z); }
	inline dVector3 operator*=(dVector3& other) { return dVector3(x*other.x, y*other.y, z*other.z); }
	inline dVector3 operator*=(dVector3* other) { return dVector3(x*other->x, y*other->y, z*other->z); }
	inline dVector3 operator/(double scale) { return dVector3(x/scale, y/scale, z/scale); }
	inline dVector3 operator-() { return dVector3(-x, -y, -z); }

	inline bool operator==(dVector3& other) { return ( fabs(x-other.x)<VEC_EPS_DOUBLE && fabs(y-other.y)<VEC_EPS_DOUBLE && fabs(z-other.z)<VEC_EPS_DOUBLE )?(true):(false); }
	inline bool operator!=(dVector3& other) { return ( fabs(x-other.x)>VEC_EPS_DOUBLE || fabs(y-other.y)>VEC_EPS_DOUBLE || fabs(z-other.z)>VEC_EPS_DOUBLE )?(true):(false); }

	inline double Mag2() { return (x*x+y*y+z*z); }
	inline double Max() { return ( (x>y)?(x>z?x:z):(y>z?y:z) ); }
	inline double Min() { return ( (x<y)?(x<z?x:z):(y<z?y:z) ); }
	inline void Reciprocal() { SAFE_RCP_DBL(x); SAFE_RCP_DBL(y); SAFE_RCP_DBL(z); }
	inline void Lerp(dVector3& v0, dVector3& v1, double fU)
	{
		x = v0.x + fU*(v1.x - v0.x);
		y = v0.y + fU*(v1.y - v0.y);
		z = v0.z + fU*(v1.z - v0.z);
	}
	inline dVector3 MinVec(dVector3& a, dVector3& b) { return dVector3(MINS(a.x, b.x), MINS(a.y, b.y), MINS(a.z, b.z)); }
	inline dVector3 MaxVec(dVector3& a, dVector3& b) { return dVector3(MAXS(a.x, b.x), MAXS(a.y, b.y), MAXS(a.z, b.z)); }

	inline double Distance(dVector3& vec) 
	{ 
		dVector3 diff = dVector3(x-vec.x, y-vec.y, z-vec.z); 
		return (sqrt(diff.x*diff.x+diff.y*diff.y+diff.z*diff.z));
	}

	double x, y, z;

	static dVector3 One;
	static dVector3 Half;
	static dVector3 Zero;
};
