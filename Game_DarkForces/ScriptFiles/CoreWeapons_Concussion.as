//Weapon setup.
void Concussion_Setup()
{
	Weapon_Register(8, "Stouker Concussion Rifle");
	Weapon_IntParameter(WPARAM_START_FRAME,    1);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      5);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 4);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   5);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 6);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	   28);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     4);
	Weapon_IntParameter(WPARAM_DAMAGE,		  10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   8);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  120);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,   37);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, -48);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_POWER);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_MELEE);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_NONE);
	
	Weapon_StrParameter(WPARAM_HIT_SOUND,	"EX-LRG1.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND,	"CONCUSS5.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND,	"CONCUSS1.VOC");
	
	Weapon_OnRender_CB("Concussion_OnRender");
	Weapon_OnFinalFrame_CB("Concussion_Fire");
	
	Weapon_AddFrame("CONCUSS1.BM");
	Weapon_AddFrame("CONCUSS2.BM");
	Weapon_AddFrame("CONCUSS3.BM");
}

//Render
void Concussion_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX =  128.0f-48.0f*(visual_AspectScale-1.0f);
	weapon_FinalY =  37.0f;
	
	if ( weapon_Frame > -1 )
	{
		weapon_FinalX += 64.0f;
		int f = weapon_Frame;
		if ( f <= 3 ) f = 1;
		else f-=2;
		weapon_FinalFrame += f;
	}
}

//Callbacks
void Concussion_Fire()
{
	float cx, cy, cz;
	float px, py, pz;
	float ix, iy, iz;
	Camera_GetDir(cx, cy, cz);
	Player_GetLoc(px, py, pz);
	int sector;
	if ( Map_RayCast(cx, cy, cz, px, py, pz+4.0f, Player_GetSector(), true, ix, iy, iz, sector) )
	{
		iz = Map_GetFloorHeight(0, sector);
		
		int objHandle0, objHandle1, objHandle2;
		Map_FindClosestObjInRange3(20.0f, ix, iy, iz+3.0f, sector, objHandle0, objHandle1, objHandle2);
		float objX, objY, objZ;
		int objSec;
		int expCount = 0;
		if ( objHandle0 > -1 )
		{
			Obj_GetLoc_Handle(objHandle0, objX, objY, objZ);
			objSec = Obj_GetSector_Handle(objHandle0);
			objZ = Map_GetFloorHeight(0, objSec);
			Map_AddExplosion(objX, objY, objZ, 30.0f, 30.0f, 0.0f, 1.0f, "CONCEXP.WAX", "EX-LRG1.VOC", false, objSec);
			expCount++;
		}
		if ( objHandle1 > -1 )
		{
			Obj_GetLoc_Handle(objHandle1, objX, objY, objZ);
			objSec = Obj_GetSector_Handle(objHandle1);
			objZ = Map_GetFloorHeight(0, objSec);
			Map_AddExplosion(objX, objY, objZ, 30.0f, 30.0f, 0.0f, 1.0f, "CONCEXP.WAX", "EX-LRG1.VOC", false, objSec);
			expCount++;
		}
		if ( objHandle2 > -1 )
		{
			Obj_GetLoc_Handle(objHandle2, objX, objY, objZ);
			objSec = Obj_GetSector_Handle(objHandle2);
			objZ = Map_GetFloorHeight(0, objSec);
			Map_AddExplosion(objX, objY, objZ, 30.0f, 30.0f, 0.0f, 1.0f, "CONCEXP.WAX", "EX-LRG1.VOC", false, objSec);
			expCount++;
		}
		if ( expCount == 0 )
		{
			Map_AddExplosion(ix, iy, iz, 30.0f, 30.0f, 0.0f, 1.0f, "CONCEXP.WAX", "EX-LRG1.VOC", false, sector);
		}
		
		//Play Sound...
		Sound_Play3D_Loc("CONCUSS5.VOC", 1.0f, px, py, pz);
	}
}
