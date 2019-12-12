//Weapon setup.
void Rifle_Setup()
{
	Weapon_Register(2, "Stormtrooper Rifle");
	Weapon_IntParameter(WPARAM_START_FRAME,    0);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      2);
	Weapon_IntParameter(WPARAM_FRAME_DELAY_SC, 1);
	Weapon_IntParameter(WPARAM_FRAME_DELAY,	   3);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY_SC, 1);
	Weapon_IntParameter(WPARAM_SHOOT_DELAY,	   2);
	Weapon_IntParameter(WPARAM_AMMO_COUNT,     2);
	Weapon_IntParameter(WPARAM_DAMAGE,		  10);
	Weapon_IntParameter(WPARAM_EMPTY_DELAY,	   8);	
	Weapon_IntParameter(WPARAM_FIRE_SOUND_CONTINUOUS, 0);
	Weapon_IntParameter(WPARAM_CYCLE_COUNT,    0);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_X,  112);
	Weapon_IntParameter(WPARAM_MUZZLE_BASE_Y,   36);
	Weapon_IntParameter(WPARAM_MUZZLE_ASPECT_OFFS, -48);
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_ENERGY);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_SINGLE_SHOT);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_BLASTER);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 210.0f/60.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.025f);	//gives the weapon some inaccuracy
	
	Weapon_StrParameter(WPARAM_HIT_SOUND,	"EX-TINY1.VOC");
	Weapon_StrParameter(WPARAM_SHOOT_SOUND,	"RIFLE-1.VOC");
	Weapon_StrParameter(WPARAM_EMPTY_SOUND,	"RIFLOUT.VOC");
	Weapon_StrParameter(WPARAM_PROJ_HIT_FX,	"EXPTINY.WAX");
	
	Weapon_OnRender_CB("Rifle_OnRender");
	
	Weapon_AddFrame("RIFLE1.BM");
	Weapon_AddFrame("RIFLE2.BM");
}

//Render
void Rifle_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX = 112.0f - 48.0f*(visual_AspectScale-1.0f);
	weapon_FinalY = 36.0f;

	if ( weapon_Frame > -1 )
	{
		weapon_FinalFrame += weapon_Frame;
	}
}

