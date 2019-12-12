#include "Light.h"
#include "Object.h"
#include "Driver3D_DX9.h"
#include <math.h>

Light::Light(void)
{
	m_pParent = NULL;
}

void Light::Init(Vector3& rvPos, Vector3& rvColor, float fRadius)
{
	m_fRadius = fRadius;
	if (fRadius > 0.0f)
		m_fOORadius = 1.0f / fRadius;
	else
		m_fOORadius = 0.0f;

	m_vColor.Set(rvColor.x, rvColor.y, rvColor.z, 1.0f);
	m_vPos = rvPos;
	m_vRelPos = rvPos;
}

void Light::PackRenderData()
{
	Driver3D_DX9::TransformPointByCamera(m_vPos.x, m_vPos.y, m_vPos.z, m_vPosScale.x, m_vPosScale.y, m_vPosScale.z);
	m_vPosScale.w = m_fOORadius;
}

bool Light::Update()
{
	bool bChangeSector = false;

	if ( m_pParent )
	{
		int nParSec = m_pParent->GetSector();
		if ( nParSec != m_nSector )
		{
			bChangeSector = true;
		}
		m_vPos = m_vRelPos + m_pParent->m_vLoc;
	}

	return bChangeSector;
}