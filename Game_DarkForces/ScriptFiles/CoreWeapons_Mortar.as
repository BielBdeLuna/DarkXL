//Weapon setup.
void Mortar_Setup()
{
	Weapon_Register(7, "Packered Morter");
	Weapon_IntParameter(WPARAM_START_FRAME,    0);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      4);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   6);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 3);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	   6);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     1);
	Weapon_IntParameter(WPARAM_DAMAGE,		  10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   8);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  120);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,   37);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, -48);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_MORTOR);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_SINGLE_SHOT);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 77.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.0f);
	
	Weapon_StrParameter(WPARAM_HIT_SOUND,		"EX-SMALL.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND,		"MORTAR4.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND,		"MORTAR9.VOC");
	Weapon_StrParameter(WPARAM_PROJ_GRAPH_TYPE,	"SPRITE");
	Weapon_StrParameter(WPARAM_PROJ_GRAPHIC,	"WSHELL.WAX");
	Weapon_StrParameter(WPARAM_PROJ_LOGIC,		"PROJECTILE_MORTAR");		
	Weapon_StrParameter(WPARAM_PROJ_HIT_FX,		"MORTEXP.WAX");
	
	Weapon_OnRender_CB("Mortar_OnRender");
	
	Weapon_AddFrame("MORTAR1.BM");
	Weapon_AddFrame("MORTAR2.BM");
	Weapon_AddFrame("MORTAR3.BM");
	Weapon_AddFrame("MORTAR4.BM");
}

//Render
void Mortar_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX =  120.0f-48.0f*(visual_AspectScale-1.0f);
	weapon_FinalY =  37.0f;
}
