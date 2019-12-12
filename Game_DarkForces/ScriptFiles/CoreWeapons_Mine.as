//Weapon setup.
void Mine_Setup()
{
	Weapon_Register(6, "I.M. Mines");
	//Primary Fire
	Weapon_IntParameter(WPARAM_START_FRAME,    0);
	Weapon_IntParameter(WPARAM_MAX_FRAME,     16);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 2);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   2);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 2);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	   2);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     1);
	Weapon_IntParameter(WPARAM_DAMAGE,		  10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   0);
	Weapon_IntParameter(WPARAM_LIGHTUP_ON_FIRE,0);
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_MINE);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_THROW);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 0.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.0f);
	
	//Secondary Fire
	Weapon_IntParameter(WPARAM_START_FRAME|WPARAM_SEC_ATTRIB,    0);
	Weapon_IntParameter(WPARAM_MAX_FRAME|WPARAM_SEC_ATTRIB,     16);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC|WPARAM_SEC_ATTRIB, 2);
	Weapon_IntParameter(WPARAM_FRAME_DELAY|WPARAM_SEC_ATTRIB,	 2);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC|WPARAM_SEC_ATTRIB, 2);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY|WPARAM_SEC_ATTRIB,	 2);
	Weapon_IntParameter(WPARAM_AMMO_COUNT|WPARAM_SEC_ATTRIB,     1);
	Weapon_IntParameter(WPARAM_DAMAGE|WPARAM_SEC_ATTRIB,	    10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY|WPARAM_SEC_ATTRIB,    0);
	Weapon_IntParameter(WPARAM_LIGHTUP_ON_FIRE|WPARAM_SEC_ATTRIB,0);
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS|WPARAM_SEC_ATTRIB, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT|WPARAM_SEC_ATTRIB,    0);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE|WPARAM_SEC_ATTRIB, AMMO_MINE);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE|WPARAM_SEC_ATTRIB, WEAPON_FTYPE_THROW);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE|WPARAM_SEC_ATTRIB, PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED|WPARAM_SEC_ATTRIB, 0.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE|WPARAM_SEC_ATTRIB,  0.0f);
	
	//Callbacks
	Weapon_OnFrame_CB("Mine_Place");
	Weapon_OnRender_CB("Mine_OnRender");
	
	//Frames.
	Weapon_AddFrame("CLAY1.BM");
	Weapon_AddFrame("CLAY2.BM");
	Weapon_AddFrame("RHAND1.BM");
}

//Render
void Mine_OnRender()
{
	if ( Player_GetAmmo(AMMO_DETONATOR) > 0 )
	{
		weapon_FinalFrame = 0;
		weapon_FinalX =  96.0f-48.0f*(visual_AspectScale-1.0f);
		weapon_FinalY =  37.0f;

		if ( weapon_Frame > -1 && weapon_Frame < 8 )
		{
			weapon_FinalY += 15.0f*weapon_Frame;
			weapon_FinalFrame++;
		}
		else if ( weapon_Frame > -1 )
		{
			weapon_FinalY = weapon_FinalY+15.0f*7.0f - 15.0f*(weapon_Frame-8);
		}
	}
	else
	{
		weapon_FinalFrame = 2;	//hand
		weapon_FinalX =  128.0f-48.0f*(visual_AspectScale-1.0f);
		weapon_FinalY =  68.0f;
	}
}

//Callbacks
void Mine_Place()
{
	if ( weapon_Frame == 7 )
	{
		int projHandle;
		if ( Player_SecFireActive() )
			projHandle = Map_AddObject("FRAME", "WMINE.FME", "LAND_MINE_PROX", 0);
		else
			projHandle = Map_AddObject("FRAME", "WMINE.FME", "LAND_MINE_AUTO", 0);
		float px, py, pz;
		Player_GetLoc(px, py, pz);
		Obj_SetLoc_Handle(projHandle, px, py, pz);

		//Play Sound...
		Sound_Play3D_Loc("CLAYMOR1.VOC", 1.0f, px, py, pz);
	}
}