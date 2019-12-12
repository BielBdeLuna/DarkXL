#pragma once
#include <math.h>

#include "Vector3.h"
#include "Vector4.h"

class Object;

class Light
{
public:
	Light(void);
	~Light(void) {;}

	void Init(Vector3& rvPos, Vector3& rvColor, float fRadius);
	void PackRenderData();
	void SetParent(Object *parent) { m_pParent = parent; }
	bool Update();	//returns true if the light is changing sector...

	Vector3 m_vPos;
	Vector3 m_vRelPos;
	Vector4 m_vColor;
	Vector4 m_vPosScale;
	float m_fRadius;
	float m_fOORadius;
	int m_nSector;

	Object *m_pParent;
};
