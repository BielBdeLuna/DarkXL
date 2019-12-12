//Weapon setup.
void Fusion_Setup()
{
	Weapon_Register(5, "Fusion Cutter");
	////Primary Fire////
	Weapon_IntParameter(WPARAM_START_FRAME,    1);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   6);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 3);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	   6);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     1);
	Weapon_IntParameter(WPARAM_DAMAGE,		  10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   8);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    4);	//cycles between 4 muzzle positions.
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,  36);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, -32);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_0X,  20);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_0Y,  -6);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_1X,  54);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_1Y, -16);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_2X,  90);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_2Y, -24);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_POWER);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_SINGLE_SHOT);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 105.0f/60.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.0f);
	
	Weapon_StrParameter(WPARAM_HIT_SOUND,		"EX-TINY1.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND,		"FUSION1.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND,		"FUSION2.VOC");
	Weapon_StrParameter(WPARAM_PROJ_GRAPH_TYPE,	"SPRITE");
	Weapon_StrParameter(WPARAM_PROJ_GRAPHIC,	"WEMISS.WAX");
	Weapon_StrParameter(WPARAM_PROJ_LOGIC,		"PROJECTILE_SPRITE");		
	Weapon_StrParameter(WPARAM_PROJ_HIT_FX,		"EMISEXP.WAX");
	
	////Secondary Fire////
	Weapon_CopyPrimaryFire();	//shortcut for weapons that have almost the same primary and secondary fire effets, with small differences.
	Weapon_IntParameter(WPARAM_FIRE_ALL_POINTS|WPARAM_SEC_ATTRIB, 1);
	Weapon_IntParameter(WPARAM_AMMO_COUNT|WPARAM_SEC_ATTRIB,      8);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC|WPARAM_SEC_ATTRIB,  6);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY|WPARAM_SEC_ATTRIB,	 18);
	Weapon_FloatParameter(WPARAM_FIRE_SPREAD_X|WPARAM_SEC_ATTRIB, 12.0f);
	Weapon_FloatParameter(WPARAM_FIRE_SPREAD_Y|WPARAM_SEC_ATTRIB,  2.0f);
	
	////Callbacks////
	Weapon_OnRender_CB("Fusion_OnRender");
	
	Weapon_AddFrame("FUSION1.BM");
	Weapon_AddFrame("FUSION2.BM");
	Weapon_AddFrame("FUSION3.BM");
	Weapon_AddFrame("FUSION4.BM");
	Weapon_AddFrame("FUSION5.BM");
	Weapon_AddFrame("FUSION6.BM");
}

//Render
void Fusion_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX =  16.0f - 32.0f*(visual_AspectScale-1.0f);
	weapon_FinalY =  36.0f;

	if ( Player_SecFireActive() )
	{
		if ( weapon_Frame > -1 )
		{
			weapon_FinalY += 4.0f;
			weapon_FinalFrame = 5;
		}
	}
	else if ( weapon_Frame > -1 || Player_IsShooting() )
	{
		if ( weapon_Frame > -1 )
		{
			weapon_FinalY += 4.0f;
		}
		int c = weapon_Cycle-weapon_CycleDir;
		if ( c < 0 ) c += 4;
		if ( c > 3 ) c -= 4;
		weapon_FinalFrame += c+1;
	}
}

