//Include File for Weapon Scripts.
//This contains all constants used by the weapon scripts.

const float dt = 1.0f/60.0f;
/*******MESSAGE ENUMS*******/
const int MSG_NRML_DAMAGE	= 1;	//called when an object recieves "normal" damage (such as blaster fire).
const int MSG_MELEE_DAMAGE	= 2;	//called when an object recieves "melee" damage (such as Kyle's fist).
const int MSG_ALERT			= 4;	//called when an object is "alerted"
const int MSG_ANIM_LOOP		= 8;	//called when an animation loops, this can be used for transitions.
const int MSG_PICKUP		= 16;	//called when the player collides with a pickup.
const int MSG_MASTER_ON		= 32;	//sent to logics of objects in a sector when it recieves the master on message (INF).
const int MSG_OBJ_DEAD		= 64;	//the logic was setup to handle an object's death.
const int MSG_PROXIMITY     = 128;	//sent to a logic, when an object is nearby (use with player collision flag to make it only the player).

/*******Int Parameters****/
const int WPARAM_START_FRAME			=  0;
const int WPARAM_MAX_FRAME				=  1;
const int WPARAM_FRAME_DELAY_SC			=  2;
const int WPARAM_FRAME_DELAY			=  3;
const int WPARAM_SHOOT_DELAY_SC			=  4;
const int WPARAM_SHOOT_DELAY			=  5;
const int WPARAM_AMMO_TYPE				=  6;
const int WPARAM_AMMO_COUNT				=  7;
const int WPARAM_PRIM_FIRE_TYPE			=  8;
const int WPARAM_PROJ_TYPE				=  9;
const int WPARAM_DAMAGE					= 10;
const int WPARAM_SPLASH_DMG				= 11;
const int WPARAM_SPLASH_RANGE			= 12;
const int WPARAM_EMPTY_DELAY			= 13;
const int WPARAM_FIRE_SOUND_CONTINUOUS	= 14;
const int WPARAM_CYCLE_COUNT			= 15;
const int WPARAM_LIGHTUP_ON_FIRE		= 16;
const int WPARAM_MUZZLE_BASE_X			= 17;
const int WPARAM_MUZZLE_BASE_Y			= 18;
const int WPARAM_MUZZLE_ASPECT_OFFS		= 19;
const int WPARAM_MUZZLE_SEC_OFFSET_0X	= 20;
const int WPARAM_MUZZLE_SEC_OFFSET_0Y	= 21;
const int WPARAM_MUZZLE_SEC_OFFSET_1X	= 22;
const int WPARAM_MUZZLE_SEC_OFFSET_1Y	= 23;
const int WPARAM_MUZZLE_SEC_OFFSET_2X	= 24;
const int WPARAM_MUZZLE_SEC_OFFSET_2Y	= 25;
const int WPARAM_MUZZLE_SEC_OFFSET_3X	= 26;
const int WPARAM_MUZZLE_SEC_OFFSET_3Y	= 27;
const int WPARAM_FIRE_ALL_POINTS		= 28;
/*******Float Parameters*********/
const int WPARAM_PROJ_SPEED				= 29;
const int WPARAM_CONE_SIZE				= 30;
const int WPARAM_FIRE_SPREAD_X			= 31;
const int WPARAM_FIRE_SPREAD_Y			= 32;
/*******String Parameters*******/
const int WPARAM_HIT_SOUND				= 33;
const int WPARAM_SHOOT_SOUND			= 34;
const int WPARAM_EMPTY_SOUND			= 35;
const int WPARAM_PROJ_GRAPH_TYPE		= 36;
const int WPARAM_PROJ_GRAPHIC			= 37;
const int WPARAM_PROJ_LOGIC				= 38;
const int WPARAM_PROJ_HIT_FX			= 39;

const int WPARAM_SEC_ATTRIB				= 256;

/********Ammo Type*********/
const int AMMO_ENERGY	= 0;
const int AMMO_DETONATOR= 1;
const int AMMO_POWER	= 2;
const int AMMO_MINE		= 3;
const int AMMO_MORTOR	= 4;
const int AMMO_PLASMA	= 5;
const int AMMO_MISSLE	= 6;
const int AMMO_NONE		= 7;

/********PrimFireType_e*********/
const int WEAPON_FTYPE_MELEE		= 0;
const int WEAPON_FTYPE_SINGLE_SHOT	= 1;
const int WEAPON_FTYPE_MULTI_SHOT	= 2;
const int WEAPON_FTYPE_THROW		= 3;
const int WEAPON_FTYPE_ARC			= 4;

/********ProjType_e*********/
const int PROJECTILE_NONE		= 0;
const int PROJECTILE_BLASTER	= 1;
const int PROJECTILE_3D			= 2;
const int PROJECTILE_SPRITE		= 3;
