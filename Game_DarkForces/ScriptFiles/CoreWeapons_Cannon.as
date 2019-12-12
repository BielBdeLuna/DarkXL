//Weapon setup.
void Cannon_Setup()
{
	Weapon_Register(9, "Assault Cannon");
	//Primary Fire
	Weapon_IntParameter(WPARAM_START_FRAME,    1);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   3);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 2);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	   5);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     1);
	Weapon_IntParameter(WPARAM_DAMAGE,		  30);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   8);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  160);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,   220);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, 0);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_PLASMA);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_SINGLE_SHOT);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 210.0f/60.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.0f);
	
	Weapon_StrParameter(WPARAM_HIT_SOUND,		"EX-LRG1.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND,		"PLASMA4.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND,		"PLAS-EMP.VOC");
	Weapon_StrParameter(WPARAM_PROJ_GRAPH_TYPE,	"SPRITE");
	Weapon_StrParameter(WPARAM_PROJ_GRAPHIC,	"WPLASMA.WAX");
	Weapon_StrParameter(WPARAM_PROJ_LOGIC,		"PROJECTILE_SPRITE");		
	Weapon_StrParameter(WPARAM_PROJ_HIT_FX,		"PLASEXP.WAX");
	
	//Secondary Fire
	Weapon_IntParameter(WPARAM_START_FRAME|WPARAM_SEC_ATTRIB,		0);
	Weapon_IntParameter(WPARAM_MAX_FRAME|WPARAM_SEC_ATTRIB,			2);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC|WPARAM_SEC_ATTRIB,	20);
	Weapon_IntParameter(WPARAM_FRAME_DELAY|WPARAM_SEC_ATTRIB,		20);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC|WPARAM_SEC_ATTRIB,	40);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY|WPARAM_SEC_ATTRIB,		40);
	Weapon_IntParameter(WPARAM_AMMO_COUNT|WPARAM_SEC_ATTRIB,		1);
	Weapon_IntParameter(WPARAM_DAMAGE|WPARAM_SEC_ATTRIB,			60);
	Weapon_IntParameter(WPARAM_SPLASH_DMG|WPARAM_SEC_ATTRIB,		60);
	Weapon_IntParameter(WPARAM_SPLASH_RANGE|WPARAM_SEC_ATTRIB,		30);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY|WPARAM_SEC_ATTRIB,		8);	
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X|WPARAM_SEC_ATTRIB,		160);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y|WPARAM_SEC_ATTRIB,		220);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS|WPARAM_SEC_ATTRIB, 0);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE|WPARAM_SEC_ATTRIB,			AMMO_MISSLE);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE|WPARAM_SEC_ATTRIB,	WEAPON_FTYPE_SINGLE_SHOT);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE|WPARAM_SEC_ATTRIB,			PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED|WPARAM_SEC_ATTRIB,		60.0f/60.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE|WPARAM_SEC_ATTRIB,		0.0f);
	
	Weapon_StrParameter(WPARAM_HIT_SOUND|WPARAM_SEC_ATTRIB,			"EX-LRG1.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND|WPARAM_SEC_ATTRIB,		"MISSILE1.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND|WPARAM_SEC_ATTRIB,		"PLAS-EMP.VOC");
	Weapon_StrParameter(WPARAM_PROJ_GRAPH_TYPE|WPARAM_SEC_ATTRIB,	"SPRITE");
	Weapon_StrParameter(WPARAM_PROJ_GRAPHIC|WPARAM_SEC_ATTRIB,		"WMSL.WAX");
	Weapon_StrParameter(WPARAM_PROJ_LOGIC|WPARAM_SEC_ATTRIB,		"PROJECTILE_SPRITE");		
	Weapon_StrParameter(WPARAM_PROJ_HIT_FX|WPARAM_SEC_ATTRIB,		"MISSEXP.WAX");
	
	Weapon_OnRender_CB("Cannon_OnRender");
	
	Weapon_AddFrame("ASSAULT1.BM");
	Weapon_AddFrame("ASSAULT2.BM");
	Weapon_AddFrame("ASSAULT3.BM");
	Weapon_AddFrame("ASSAULT4.BM");
}

//Render
void Cannon_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX =  204.0f-48.0f*(visual_AspectScale-1.0f);
	weapon_FinalY =  39.0f;
	if ( weapon_Frame > -1 && Player_SecFireActive() )
	{
		weapon_FinalX += 20.0f;
		weapon_FinalY += 20.0f;
		weapon_FinalFrame = 2 + weapon_Frame;
		if ( weapon_FinalFrame == 3 )
		{
			weapon_FinalY += 50.0f;
		}
	}
	else if ( Player_IsShooting() && Player_SecFireActive() == false )
	{
		weapon_FinalFrame = 1;
	}
}
