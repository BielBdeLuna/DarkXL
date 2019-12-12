#pragma once
#include "globals.h"
#include "ScriptSystem.h"
#include "Driver3D_DX9.h"
#include "Vector4.h"
#include <vector>

using namespace std;
class Map;
class ObjPlayer;

class Weapon
{
public:
	Weapon(void);
	~Weapon(void);

	bool CallRenderFunc();
	void AddFrame(const char *pszImageFile, Map *pMap);
	bool HasSecondaryFire() { return m_bSecFire; }

	inline static Weapon *GetWeapon(u32 wpnIndex);
	inline static void SetWeaponAnim(float dx, float dy);
	static void RenderCurWeapon(float secAmb, float fCamPitch, const Vector4& rvFogColor, ObjPlayer *player);
	static void AddWeapon(int index, Weapon *pWpn);
	static void Init();
	static void DestroyAllWeapons();

public:
	typedef struct
	{
		short startFrame;
		short maxFrame;
		short frameDelaySC;
		short frameDelay;
		short shootDelaySC;
		short shootDelay;

		short ammoType;		//ammo type (AMMO_NONE = no ammo needed)
		short ammoCount;	//number of type needed.

		short primFireType;	//what kind weapon: melee, single shot, multi shot, arc...
		short projType;		//what kind of projectile: none, blaster, 3D object, sprite.
		float projSpeed;	//how far does the projectile travel each frame?
		float coneSize;		//cone size determines accuracy of the weapon. 0 = 100% accurate.
		float fireSpread[2];//project firing spread when firing multiple projectiles at once.
		short dmg;			//the amount of damage when it hits.
		short emptyDelay;	//how many frames before the empty sound triggers again.
		short splashDmg;	//splash damage, for things like exploding projectiles.
		short splashRange;	//range of splash damage.
		char  fireSoundCont;//1 if the firing sound is continuous, 0 if one shot.
		char  cycleCnt;		//number of different points for projectiles to come from, like the Fusion Cutter.

		char hitSnd[16];
		char shootSnd[16];
		char emptySnd[16];
		char projGraphType[16];
		char projGraph[16];
		char projLogic[64];
		char projHitFX[16];

		//muzzle position data.
		short muzzle_BasePosX;	 //Base muzzle position X
		short muzzle_BasePosY;	 //Base muzzle position Y
		short muzzle_AspectOffs; //Aspect scale modification.
		short muzzle_SecOffsX[4];//Secondary offsets, for weapons with multiple muzzle points.
		short muzzle_SecOffsY[4];//Secondary offsets, for weapons with multiple muzzle points.
		bool  bFireAll;			 //Fire from all muzzle positions at once.

		//callbacks.
		SHANDLE OnFrameFunc;
		SHANDLE OnFinalFrameFunc;
	} WeaponStats_t;

	typedef struct
	{
		DHANDLE hFrame;		//the image handle.
		short width;		//the image width.
		short height;		//the image height.
		float fRelWidth;	//Relative width and height.
		float fRelHeight;	//used to determine uv's when image is fit into a pow of 2 texture.
	} RenderFrame_t;

	typedef struct
	{
		//all frame graphics.
		vector<RenderFrame_t *> Frames;
		//render data prepared by the Script-based Render Callback.
		float finalX;
		float finalY;
		short finalFrame;
		//render data.
		char bLightUpOnFire;
		//render callback, positions the weapon and computes the frame.
		SHANDLE OnRender;
	} RenderData_t;

	enum
	{
		MAX_WEAPON_COUNT = 32
	};

	WeaponStats_t m_GameData;
	WeaponStats_t m_GameDataSec;
	RenderData_t  m_RenderData;
	bool m_bSecFire;

	static float s_FinalX;
	static float s_FinalY;
	static float s_fWeaponOffsX;
	static float s_fWeaponOffsY;
	static int s_FinalFrame;
	static int s_Cycle;
	static int s_CycleDir;

	RenderFrame_t *GetCurFrame() { return m_RenderData.Frames[ m_RenderData.finalFrame ]; }

private:
	static Weapon *s_WeaponList[MAX_WEAPON_COUNT];
	static int s_WeaponCount;
};

inline Weapon *Weapon::GetWeapon(u32 wpnIndex)
{
	if ( wpnIndex >= (u32)s_WeaponCount )
		return NULL;

	return s_WeaponList[wpnIndex];
}

inline void Weapon::SetWeaponAnim(float dx, float dy)
{
	s_fWeaponOffsX = dx;
	s_fWeaponOffsY = dy;
}
