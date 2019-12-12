//Weapon setup.
void Fist_Setup()
{
	Weapon_Register(0, "Fists");
	Weapon_IntParameter(WPARAM_START_FRAME,    0);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 7);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   7);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 5);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	  10);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     0);
	Weapon_IntParameter(WPARAM_DAMAGE,		   0);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   0);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	Weapon_IntParameter(WPARAM_LIGHTUP_ON_FIRE,0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  170);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,   62);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, 0);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_NONE);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_MELEE);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_NONE);
	
	Weapon_OnFinalFrame_CB("Fist_PunchLand");
	Weapon_OnRender_CB("Fist_OnRender");
	
	Weapon_AddFrame("RHAND1.BM");
	Weapon_AddFrame("PUNCH1.BM");
	Weapon_AddFrame("PUNCH2.BM");
	Weapon_AddFrame("PUNCH3.BM");
}

//Render
void Fist_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX =  170.0f;
	weapon_FinalY =   62.0f;

	if ( weapon_Frame > -1 )
	{
		weapon_FinalFrame = 1 + weapon_Frame;
		weapon_FinalX -= 115;
		weapon_FinalY -= 25;
	}
}

//Callbacks
void Fist_PunchLand()
{
	float cx, cy, cz;
	float px, py, pz;
	Camera_GetDir(cx, cy, cz);
	Player_GetLoc(px, py, pz);
	int sector = Player_GetSector();
	int objHandle = Map_FindClosestObjInRange( 6.0f, cx, cy, cz, px, py, pz, sector );
	if ( Obj_IsStillAlive_Handle(objHandle) )
	{
		if ( Obj_SendMessage(objHandle, MSG_MELEE_DAMAGE, 10.0f) )
		{
			//Play Sound...
			Sound_Play3D_Loc("PUNCH.VOC", 1.0f, px, py, pz);
		}
		else if ( Map_CanHitWall( sector, 5.0f ) )
		{
			//Play Sound...
			Sound_Play3D_Loc("PUNCH.VOC", 1.0f, px, py, pz);
		}
		else
		{
			//Play Sound...
			Sound_Play3D_Loc("SWING.VOC", 1.0f, px, py, pz);
		}
		Obj_Alert(objHandle);
	}
	else
	{
		//Look for proximity to a wall...
		if ( Map_CanHitWall( sector, 5.0f ) )
		{
			//Play Sound...
			Sound_Play3D_Loc("PUNCH.VOC", 1.0f, px, py, pz);
		}
		else
		{
			//Play Sound...
			Sound_Play3D_Loc("SWING.VOC", 1.0f, px, py, pz);
		}
	}
}
