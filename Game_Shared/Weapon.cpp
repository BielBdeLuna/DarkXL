#include "Weapon.h"
#include "Object.h"
#include "Math.h"
#include "Map.h"
#include "Object.h"

/**************Statics****************/
Weapon *Weapon::s_WeaponList[Weapon::MAX_WEAPON_COUNT];
int Weapon::s_WeaponCount=0;

float Weapon::s_FinalX;
float Weapon::s_FinalY;
float Weapon::s_fWeaponOffsX;
float Weapon::s_fWeaponOffsY;
int Weapon::s_FinalFrame;
int Weapon::s_Cycle;
int Weapon::s_CycleDir;

/**************Implementation**********/
Weapon::Weapon(void)
{
	memset( &m_GameData,    0, sizeof(WeaponStats_t) );
	memset( &m_GameDataSec, 0, sizeof(WeaponStats_t) );
	m_RenderData.finalX = 0;
	m_RenderData.finalY = 0;
	m_RenderData.finalFrame = 0;
	m_RenderData.bLightUpOnFire = 1;
	m_RenderData.OnRender = (SHANDLE)0;
	m_bSecFire = false;
}

Weapon::~Weapon(void)
{
	//free allocated render frames.
	vector<RenderFrame_t *>::iterator iFrame = m_RenderData.Frames.begin();
	vector<RenderFrame_t *>::iterator eFrame = m_RenderData.Frames.end();
	for (; iFrame != eFrame; ++iFrame)
	{
		RenderFrame_t *pFrame = *iFrame;
		if ( pFrame )
		{
			delete pFrame;
		}
	}
}

bool Weapon::CallRenderFunc()
{
	if ( m_RenderData.OnRender >= 0 )
	{
		//Is there a render callback?
		ScriptSystem::SetCurFunction( m_RenderData.OnRender );
		ScriptSystem::ExecuteFunc();

		//Now the variables should be filled out by the script system.
		m_RenderData.finalX = s_FinalX;
		m_RenderData.finalY = s_FinalY;
		m_RenderData.finalFrame = (short)s_FinalFrame;

		return true;
	}
	return false;
}

void Weapon::AddFrame(const char *pszImageFile, Map *pMap)
{
	RenderFrame_t *frame = new RenderFrame_t;
	float t[2];
	int it[2];
	frame->hFrame = pMap->LoadTextureFromGOB(pszImageFile, t[0], t[1], it[0], it[1]);
	frame->width = Map::m_BM_Tex.SizeX; frame->height = Map::m_BM_Tex.SizeY;
	frame->fRelWidth  = (float)Map::m_BM_Tex.SizeX / Math::RoundNextPow2(Map::m_BM_Tex.SizeX);
	frame->fRelHeight = (float)Map::m_BM_Tex.SizeY / Math::RoundNextPow2(Map::m_BM_Tex.SizeY);

	m_RenderData.Frames.push_back( frame );
}

/***********Implementation - Statics************/
void Weapon::RenderCurWeapon(float secAmb, float fCamPitch, const Vector4& rvFogColor, ObjPlayer *player)
{
	Driver3D_DX9::ClampTexCoords(true, true);

	const float fOO320 = 1.0f / 320.0f;
	const float fOO200 = 1.0f / 200.0f;
	float fPosX=0.5f, fPosY=0.0f;
	float fdX, fdY;
	float aspectScale = Driver3D_DX9::GetAspectScale();
	if ( Driver3D_DX9::Is320x200Enabled() )
	{
		aspectScale = 1.0f;
	}

	int curWpn = player->m_CurWeapon;
	if ( player->m_fSwitchTime < 0.125f ) { curWpn = player->m_NextWeapon; }

	Weapon *pWeapon = Weapon::GetWeapon( curWpn );
	float ambScale = player->IsHeadlampOn() ? 1.0f : secAmb;
	if ( pWeapon )
	{
		pWeapon->CallRenderFunc();
		fPosX =  pWeapon->m_RenderData.finalX/320.0f;
		fPosY = -pWeapon->m_RenderData.finalY/200.0f;

		if ( player->IsShooting() == false )
		{
			fPosX += s_fWeaponOffsX;
			fPosY += s_fWeaponOffsY;
		}

		if ( player->m_fSwitchTime > 0.0f )
		{
			fPosX += 0.1f*player->m_fSwitchParam;
			fPosY -= 0.3f*player->m_fSwitchParam;
		}

		//move weapon based on camera pitch...
		//center = 0...
		//top = PI/2
		//bottom = -PI/2
		float u_p = fabsf(fCamPitch) / (0.78539816339744830961566084581988f);	//+/- 45 degrees...
		if ( u_p > 1.0f ) { u_p = 1.0f; }
		if ( fCamPitch > 0.0f )
		{
			fPosY -= u_p*0.15f;
		}
		else
		{
			fPosY += u_p*0.15f;
		}

		//Render weapon
		if ( player->IsNightVisionOn() && Driver3D_DX9::Is320x200Enabled() == false )
		{
			Driver3D_DX9::SetShaders(Driver3D_DX9::VS_SHADER_SCREEN, Driver3D_DX9::PS_SHADER_SCREEN_NV);
		}
		else if ( Driver3D_DX9::Is320x200Enabled() )
		{
			Driver3D_DX9::SetShaders(Driver3D_DX9::VS_SHADER_SCREEN, Driver3D_DX9::PS_SHADER_SCREEN_PAL);
		}
		else
		{
			Driver3D_DX9::SetShaders(Driver3D_DX9::VS_SHADER_SCREEN, Driver3D_DX9::PS_SHADER_SCREEN_GLOW);
		}

		float texWidth, texHeight;
		Weapon::RenderFrame_t *pFrame = pWeapon->GetCurFrame();
		fdX = (float)pFrame->width  * fOO320 * aspectScale;
		fdY = (float)pFrame->height * fOO200;
		Driver3D_DX9::SetTexture(pFrame->hFrame);
		texWidth  = pFrame->fRelWidth;
		texHeight = pFrame->fRelHeight;

		bool bLightUpWpn = ( player->m_nShootFrame > -1 && pWeapon->m_RenderData.bLightUpOnFire ) ? true : false;
		ambScale = player->IsHeadlampOn() || bLightUpWpn ? 1.0f : secAmb;
		if ( Driver3D_DX9::Is320x200Enabled() == false )
		{
			Vector3 ambColor;
			ambColor.x = (1.0f-ambScale)*rvFogColor.x + ambScale;
			ambColor.y = (1.0f-ambScale)*rvFogColor.y + ambScale;
			ambColor.z = (1.0f-ambScale)*rvFogColor.z + ambScale;
			Driver3D_DX9::SetAmbientColor(ambColor.x, ambColor.y, ambColor.z);
		}
		else
		{
			Driver3D_DX9::SetAmbient(ambScale);
		}
	
		Driver3D_DX9::EnableAlphaBlend(TRUE);

		Vector3 polygon[4];
		float u[4], v[4];

		polygon[0].Set(fPosX,	  fdY+fPosY, 0.9f);
		polygon[1].Set(fPosX+fdX, fdY+fPosY, 0.9f);
		polygon[2].Set(fPosX+fdX, fPosY,	 0.9f);
		polygon[3].Set(fPosX,	  fPosY,	 0.9f);
		u[0] = 0.0f;	 v[0] = 0.0f;
		u[1] = texWidth; v[1] = 0.0f;
		u[2] = texWidth; v[2] = texHeight;
		u[3] = 0.0f;	 v[3] = texHeight;

		Driver3D_DX9::RenderPolygon(4, polygon, u, v);
	}
}

void Weapon::AddWeapon(int index, Weapon *pWpn)
{
	s_WeaponList[index] = pWpn;
	s_WeaponCount = max( s_WeaponCount, index+1 );
}

void Weapon::Init()
{
	s_WeaponCount = 0;
	memset( s_WeaponList, 0, MAX_WEAPON_COUNT*sizeof(Weapon*) );
}

void Weapon::DestroyAllWeapons()
{
	for (int w=0; w<s_WeaponCount; w++)
	{
		if ( s_WeaponList[w] )
		{
			delete s_WeaponList[w];
			s_WeaponList[w] = NULL;
		}
	}

	s_WeaponCount = 0;
}
