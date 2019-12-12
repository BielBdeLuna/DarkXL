//Weapon setup.
void Repeater_Setup()
{
	////Primary Fire////
	Weapon_Register(4, "Imperial Repeater");
	Weapon_IntParameter(WPARAM_START_FRAME,    1);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 2);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   4);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 1);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	   2);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     1);
	Weapon_IntParameter(WPARAM_DAMAGE,		  10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   8);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 1);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  144);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,   36);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, -48);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_POWER);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_SINGLE_SHOT);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 210.0f/60.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.0f);
	
	Weapon_StrParameter(WPARAM_HIT_SOUND,		"EX-TINY1.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND,		"REPEATER.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND,		"REP-EMP.VOC");
	Weapon_StrParameter(WPARAM_PROJ_GRAPH_TYPE,	"FRAME");
	Weapon_StrParameter(WPARAM_PROJ_GRAPHIC,	"BULLET.FME");
	Weapon_StrParameter(WPARAM_PROJ_LOGIC,		"PROJECTILE_SPRITE");		
	Weapon_StrParameter(WPARAM_PROJ_HIT_FX,		"EXPTINY.WAX");
	
	////Secondary Fire////
	Weapon_CopyPrimaryFire();	//shortcut for weapons that have almost the same primary and secondary fire effets, with small differences.
	Weapon_IntParameter(WPARAM_CYCLE_COUNT|WPARAM_SEC_ATTRIB,	  3);
	Weapon_IntParameter(WPARAM_FIRE_ALL_POINTS|WPARAM_SEC_ATTRIB, 1);
	Weapon_IntParameter(WPARAM_AMMO_COUNT|WPARAM_SEC_ATTRIB,      3);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC|WPARAM_SEC_ATTRIB,  6);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY|WPARAM_SEC_ATTRIB,	 18);
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS|WPARAM_SEC_ATTRIB, 0);
	Weapon_FloatParameter(WPARAM_FIRE_SPREAD_X|WPARAM_SEC_ATTRIB, 128.0f);
	Weapon_FloatParameter(WPARAM_FIRE_SPREAD_Y|WPARAM_SEC_ATTRIB, 128.0f);
		
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X|WPARAM_SEC_ATTRIB,  144);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y|WPARAM_SEC_ATTRIB,   36+2);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_0X|WPARAM_SEC_ATTRIB,  -2);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_0Y|WPARAM_SEC_ATTRIB,  -4);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_1X|WPARAM_SEC_ATTRIB,   2);
	Weapon_IntParameter(WPARAM_MUZZLE_SEC_OFFSET_1Y|WPARAM_SEC_ATTRIB,  -4);
	
	Weapon_StrParameter(WPARAM_SHOOT_SOUND|WPARAM_SEC_ATTRIB, "REPEAT-1.VOC");
	
	////Callbacks////
	Weapon_OnRender_CB("Repeater_OnRender");	
	
	Weapon_AddFrame("AUTOGUN1.BM");
	Weapon_AddFrame("AUTOGUN2.BM");
	Weapon_AddFrame("AUTOGUN3.BM");
}

//Render
void Repeater_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX = 144.0f - 48.0f*(visual_AspectScale-1.0f);
	weapon_FinalY =  36.0f;

	if ( weapon_Frame > -1 )
	{
		weapon_FinalX += 10.0f;
		weapon_FinalY += 2.0f;
		weapon_FinalFrame = weapon_Frame;
	}
	else if ( Player_IsShooting() )
	{
		weapon_FinalX += 10.0f;
		weapon_FinalY += 2.0f;
		weapon_FinalFrame = 1;	//default to 1 when still shooting.
	}
}

