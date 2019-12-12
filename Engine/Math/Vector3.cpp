#include "Vector3.h"
#include <math.h>

Vector3 Vector3::One(1.0f, 1.0f, 1.0f);
Vector3 Vector3::Half(0.5f, 0.5f, 0.5f);
Vector3 Vector3::Zero(0.0f, 0.0f, 0.0f);

dVector3 dVector3::One(1.0, 1.0, 1.0);
dVector3 dVector3::Half(0.5, 0.5, 0.5);
dVector3 dVector3::Zero(0.0, 0.0, 0.0);

float Vector3::Normalize()
{
	float mag2 = x*x + y*y + z*z;
	float mag = 0.0f;
	if ( mag2 > 0.00000001f )
	{
		mag = sqrtf(mag2);
		float oomag = 1.0f / mag;
		x *= oomag;
		y *= oomag;
		z *= oomag;
	}
	return mag;
}

void Vector3::Cross(Vector3& A, Vector3& B)
{
	this->x = A.y*B.z - A.z*B.y;
	this->y = A.z*B.x - A.x*B.z;
	this->z = A.x*B.y - A.y*B.x;
}

void Vector3::CrossAndNormalize(Vector3& A, Vector3& B)
{
	this->x = A.y*B.z - A.z*B.y;
	this->y = A.z*B.x - A.x*B.z;
	this->z = A.x*B.y - A.y*B.x;

	Normalize();
}


double dVector3::Normalize()
{
	double mag2 = x*x + y*y + z*z;
	double mag = 0.0f;
	if ( mag2 > 0.0000000001 )
	{
		mag = sqrt(mag2);
		double oomag = 1.0 / mag;
		x *= oomag;
		y *= oomag;
		z *= oomag;
	}
	return mag;
}

void dVector3::Cross(dVector3& A, dVector3& B)
{
	this->x = A.y*B.z - A.z*B.y;
	this->y = A.z*B.x - A.x*B.z;
	this->z = A.x*B.y - A.y*B.x;
}

void dVector3::CrossAndNormalize(dVector3& A, dVector3& B)
{
	this->x = A.y*B.z - A.z*B.y;
	this->y = A.z*B.x - A.x*B.z;
	this->z = A.x*B.y - A.y*B.x;

	Normalize();
}