//Weapon setup.
void Pistol_Setup()
{
	Weapon_Register(1, "Bryar Pistol");
	Weapon_IntParameter(WPARAM_START_FRAME,    0);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      3);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 2);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   4);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 8);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	  16);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     1);
	Weapon_IntParameter(WPARAM_DAMAGE,		  10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	  32);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  160);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,   40);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, 0);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_ENERGY);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_SINGLE_SHOT);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_BLASTER);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 210.0f/60.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.0f);
	
	Weapon_StrParameter(WPARAM_HIT_SOUND,	"EX-TINY1.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND,	"PISTOL-1.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND,	"PISTOUT1.VOC");
	Weapon_StrParameter(WPARAM_PROJ_HIT_FX,	"EXPTINY.WAX");
	
	Weapon_OnRender_CB("Pistol_OnRender");
	
	Weapon_AddFrame("PISTOL1.BM");
	Weapon_AddFrame("PISTOL2.BM");
	Weapon_AddFrame("PISTOL3.BM");
}

//Render
void Pistol_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX =  160.0f;
	weapon_FinalY =   40.0f;

	if ( weapon_Frame > -1 )
	{
		int f = weapon_Frame;
		if ( f == 3 ) f = 1;
		weapon_FinalFrame += f;
	}
}
