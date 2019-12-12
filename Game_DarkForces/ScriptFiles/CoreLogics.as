/*
*******obj variables********
obj_Speed
obj_dY
obj_HP
obj_Shields
obj_Radius
obj_Frame
obj_Delay
obj_FrameDelay
obj_Alive
obj_Action
obj_Alerted
obj_Yaw
obj_dir_x
obj_dir_y
obj_dir_z
obj_loc_x
obj_loc_y
obj_loc_z
obj_uMsg
*******player variables********
*******obj Functions********
Obj_SetMoveDir(float x, float y, float z)
Obj_SetFlag(flag)
Obj_ClearFlag(flag)
Obj_UpdateLoc()
Obj_SetProjectileData(string &type, string &projGraphic, string &projImpactGraph, string &fireSnd, string &hitSnd, int nDamage, float fSplashRng)
*******sprite/wax functions*****
Sprite_GetFrameCnt(action, view)
*******logic Functions**********
Logic_AddMsgMask(mask)
*******map Functions**********
Map_AddObject(type, file, logic, rot)
float Map_GetFloorHeight()
float Map_GetCeilingHeight()
*/

const float dt = 1.0f/60.0f;
//for now I have to duplicate engine enums...
/*******Screen Flash Colors****/
const int PLAYER_FLASH_RED	=0;
const int PLAYER_FLASH_GREEN=1;
const int PLAYER_FLASH_BLUE	=2;
/*******STD. VALUES*********/
const int FALSE = 0;
const int TRUE  = 1;
const float PI     = 3.141592653589793238f;
const float TWO_PI = 6.283185307179586477f;
/*******MESSAGE ENUMS*******/
const int MSG_NRML_DAMAGE	= 1;	//called when an object recieves "normal" damage (such as blaster fire).
const int MSG_MELEE_DAMAGE	= 2;	//called when an object recieves "melee" damage (such as Kyle's fist).
const int MSG_ALERT			= 4;	//called when an object is "alerted"
const int MSG_ANIM_LOOP		= 8;	//called when an animation loops, this can be used for transitions.
const int MSG_PICKUP		= 16;	//called when the player collides with a pickup.
const int MSG_MASTER_ON		= 32;	//sent to logics of objects in a sector when it recieves the master on message (INF).
const int MSG_OBJ_DEAD		= 64;	//the logic was setup to handle an object's death.
const int MSG_PROXIMITY     = 128;	//sent to a logic, when an object is nearby (use with player collision flag to make it only the player).
/*******OBJECT FLAGS*******/
const int OFLAGS_COLLIDE_PLAYER		= 1;
const int OFLAGS_COLLIDE_PROJECTILE = 2;
const int OFLAGS_COLLIDE_OBJECTS    = 8;
const int OFLAGS_COLLIDE_PICKUP		= 16;
const int OFLAGS_COLLIDE_PROXIMITY  = 32;
const int OFLAGS_ENEMY				= 64;
const int OFLAGS_INVISIBLE			= 1024;
/*******AMMO TYPES********/
const int AMMO_ENERGY		= 0;
const int AMMO_DETONATOR	= 1;
const int AMMO_POWER		= 2;
const int AMMO_MINE			= 3;
const int AMMO_MORTOR		= 4;
const int AMMO_PLASMA		= 5;
const int AMMO_MISSLE		= 6;
/*******Animation Actions*********/
const int Anim_Moving      = 0;
const int Anim_Attacking   = 1;
const int Anim_Dying_Melee = 2;
const int Anim_Dying_Nrml  = 3;
const int Anim_Dead		   = 4;
const int Anim_Idle		   = 5;
const int Anim_PAttack_FT  = 6;	//Primary attack follow through
const int Anim_Sec_Attack  = 7;	//Secondary attack
const int Anim_SAttack_FT  = 8;	//Secondary attack follow through.
const int Anim_Injured     = 12;

/***********AI Routines*************/
const int AI_State = 0;
const int AI_Prev_State = 1;
const int AI_Sec_State = 1;
const int AI_Reaction = 2;
const int AI_Dir = 3;
const int AI_Sound = 4;
const int AI_ProjGraph = 5;
const int AI_ShootFT = 6;
const int AI_Flags = 7;
const int AI_Attack = 8;
const int AI_Melee_Attack = 9;
const int AI_Min_Reaction = 10;
const int AI_Walk_Delay = 11;
const int AI_Shoot_Cone = 12;
const int AI_Shoot_Height = 13;
const int AI_Shoot_Delay = 14;
const int AI_MaxAttackRange = 15;

//list of general AI states.
const int AI_State_Look  = 0;			//look for the player but don't move - default state for standard enemies.
const int AI_State_Chase = 1;			//chase the player.
const int AI_State_Wander = 2;			//wander around	- default state for generators.
const int AI_State_Attack_Melee = 3;	//melee attack.
const int AI_State_Attack_Range = 4;	//range attack (blaster, thermal detonator, etc.)
const int AI_State_Wander_UG = 5;		//wander state for units that travel underground - ie the sewer bugs...
const int AI_State_Remote = 6;			//special code for the Remote.
const int AI_State_Transition = 256;

//list of general AI flags.
const int AI_Flags_None = 0;
const int AI_Flags_Allow_Double_Shoot = 1;
const int AI_Flags_Has_Melee = 2;
const int AI_Flags_Floating = 4;
const int AI_Flags_NoAlert = 8;
const int AI_Flags_NoRangeAttck = 16;
const int AI_Flags_Underground = 32;
const int AI_Flags_SingleAttckOnly = 64;
const int AI_Flags_FloatOnWater = 128;
const int AI_Flags_Melee_Random = 256;	//Don't always attack when in range, random chance.
const int AI_Flags_ShootExp = 512;
const int AI_Flags_MeleeWhileInjured = 1024;

const int AI_Flags_JustFiredTwice = 2048;

//misc. values.
const float MeleeRange = 8.0f;
const float MinRngAttackDist = 3.0f;

//Setup for AI.
void L_AI_SetupLogic()
{
	Logic_AddMsgMask(MSG_NRML_DAMAGE);
	Logic_AddMsgMask(MSG_MELEE_DAMAGE);
	Logic_AddMsgMask(MSG_ALERT);
}

void L_AI_SetupObj(int HP, int inital_AI_state, int fireSound, int projGraph, int aiRngAttck, int aiMeleeAttck, bool bShootFT, int aiFlags)
{
	Obj_SetMoveDir( obj_dir_x, obj_dir_y, 0.0f );
    obj_Speed = 0.1f;
    obj_dY = 0.015f;
	obj_HP = HP;
	obj_Radius = 2.0f;
	obj_Height = 7.8f;
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PROJECTILE);
	Obj_SetFlag(OFLAGS_COLLIDE_OBJECTS);
	Obj_SetFlag(OFLAGS_ENEMY);
	Obj_EnableAnim(1);
	
	//put into the "idle" action...
	obj_Action = Anim_Idle;
	obj_Frame = 0;
	obj_Delay = 15;
	obj_FrameDelay = 15;
	
	Obj_SetLocalVar(AI_State, inital_AI_state);
	Obj_SetLocalVar(AI_Prev_State, inital_AI_state);
	Obj_SetLocalVar(AI_Reaction, 5);
	Obj_SetLocalVar(AI_Sound, fireSound);
	Obj_SetLocalVar(AI_ProjGraph, projGraph);
	Obj_SetLocalVar(AI_ShootFT, bShootFT?1:0);
	Obj_SetLocalVar(AI_Flags, aiFlags);
	Obj_SetLocalVar(AI_Attack, aiRngAttck);
	Obj_SetLocalVar(AI_Melee_Attack, aiMeleeAttck);
	Obj_SetLocalVar(AI_Min_Reaction, Sprite_GetFrameCnt(Anim_Moving, 0)*5);//*15);
	Obj_SetLocalVar(AI_Walk_Delay, 15);
	Obj_SetLocalVar(AI_Shoot_Cone, 0.05f);
	Obj_SetLocalVar(AI_Shoot_Height, 0.0f);
	Obj_SetLocalVar(AI_Shoot_Delay, 15);
	Obj_SetLocalVar(AI_MaxAttackRange, 512);
	
}

int ChooseMoveDir(int nPlayerRel)
{
	int f, l, r, b, dir;
	float px, py, pz, dx, dy;
	
	if ( nPlayerRel > 0 )
	{
		Player_GetLoc(px, py, pz);
		dx = px-obj_loc_x;
		dy = py-obj_loc_y;
		
		dir = Math_GetClosestDir(dx, dy);
	}
	else
	{
		//pick a direction at random...
		int r = Math_Rand();
		//8 directions, pick one...
		dir = r % 8;
	}
	
	Math_GetDir(dir, dx, dy);
	f = dir;
	
	//is this direction blocked?
	float p1_x = dx*obj_Speed + obj_loc_x;
	float p1_y = dy*obj_Speed + obj_loc_y;
	if ( Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
	{
		//right or left?
		int dirTry;
		int r = Math_Rand();
		int a, b;
		if ( r < 50 ) { a = -1; b = +1; }
		else { a = +1; b = -1; }
		l = a; r = b;
		
		dirTry = dir+a;
		if ( dirTry > 7 ) dirTry -= 8;
		if ( dirTry < 0 ) dirTry += 8;
			
		Math_GetDir(dirTry, dx, dy);
		p1_x = dx*obj_Speed + obj_loc_x;
		p1_y = dy*obj_Speed + obj_loc_y;
		if ( Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
		{
			dirTry = dir+b; 
			if ( dirTry > 7 ) dirTry -= 8;
			if ( dirTry < 0 ) dirTry += 8;
			
			Math_GetDir(dirTry, dx, dy);
			p1_x = dx*obj_Speed + obj_loc_x;
			p1_y = dy*obj_Speed + obj_loc_y;
			if ( Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
			{
				//left and right is blocked, try going backwards...
				r = Math_Rand();
				
				if ( r < 25 ) { dirTry = dir+3; }
				else if (r < 75) { dirTry = dir+4; }
				else { dirTry = dir+5; }
				
				if ( dirTry > 7 ) dirTry -= 8;
				if ( dirTry < 0 ) dirTry += 8;
				
				b = dirTry;
				Math_GetDir(dirTry, dx, dy);
				p1_x = dx*obj_Speed + obj_loc_x;
				p1_y = dy*obj_Speed + obj_loc_y;
				if ( Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
				{
					//we'll try all the other directions now...
					for (int i=0; i<8; i++)
					{
						if ( i == f || i == l || i == r || i == b ) { continue; }
						
						Math_GetDir(i, dx, dy);
						p1_x = dx*obj_Speed + obj_loc_x;
						p1_y = dy*obj_Speed + obj_loc_y;
						
						if ( !Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
						{
							Obj_LookAt(p1_x, p1_y, obj_loc_z, 1.0f, 0);
							return i;
						}
					}
					
					//can't move...
					return -1;
				}
				else
				{
					Obj_LookAt(p1_x, p1_y, obj_loc_z, 1.0f, 0);
					return dirTry;
				}
			}
			else
			{
				Obj_LookAt(p1_x, p1_y, obj_loc_z, 1.0f, 0);
				return dirTry;
			}
		}
		else
		{
			Obj_LookAt(p1_x, p1_y, obj_loc_z, 1.0f, 0);
			return dirTry;
		}
	}
	Obj_LookAt(p1_x, p1_y, obj_loc_z, 1.0f, 0);
	return dir;
}

//Chase the player.
void L_AI_Chase(bool bTransition)
{
	if ( bTransition )
	{
		obj_Action = Anim_Moving;
		obj_Frame = 0;
		obj_Delay = Obj_GetLocalVar(AI_Walk_Delay);//15;
		obj_FrameDelay = Obj_GetLocalVar(AI_Walk_Delay);//15;
		Obj_SetLocalVar( AI_Reaction, Obj_GetLocalVar(AI_Min_Reaction));
		Obj_SetLocalVar(AI_Prev_State, Obj_GetLocalVar(AI_State));
		Obj_SetLocalVar(AI_State, AI_State_Chase);
		
		//pick a direction.
		Obj_SetLocalVar( AI_Dir, ChooseMoveDir(1) );
		
		if ( Obj_GetLocalVarI(AI_Flags)&AI_Flags_Underground > 0 )
		{
			Obj_SetFlag(OFLAGS_INVISIBLE);
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
		}
	}
	
	int reaction = Obj_GetLocalVar(AI_Reaction);
	reaction--;
	if ( reaction <= 0 )
	{
		if ( Obj_GetLocalVarI(AI_Flags)&AI_Flags_Underground > 0 )
		{
			Obj_ClearFlag(OFLAGS_INVISIBLE);
			Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_SetFlag(OFLAGS_COLLIDE_PROJECTILE);
		}
		
		Obj_SetLocalVar(AI_Reaction, 5);
		//we'll either attack or pick a direction to move in.
		float d = Obj_GetDistFromPlayer();
		if ( d < MeleeRange && (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Has_Melee)>0 )
		{
			//change of attack?
			int r = Math_Rand();
			int chance = 100;
			if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Melee_Random)>0 )
			{
				chance = 20;
			}
			//try melee attack if possible.
			if ( ( r < chance || chance == 100 ) && Map_HasPlayerLOS() == 1 )
			{
				Obj_SetLocalVar(AI_Prev_State, Obj_GetLocalVar(AI_State));
				Obj_SetLocalVar(AI_State,AI_State_Attack_Melee|AI_State_Transition);
				return;
			}
			else
			{
				//change direction.
				Obj_SetLocalVar( AI_Reaction, Obj_GetLocalVar(AI_Min_Reaction));
				//pick a direction.
				Obj_SetLocalVar( AI_Dir, ChooseMoveDir(1) );
			}
		}
		else
		{
			int r = Math_Rand();
			//the chance of shooting is proportional to the distance from the player.
			int t = d*0.5f;
			//units will always shoot atleast roughly half the time.
			if ( t > 60 ) t = 60;
			
			if ( r > t && Map_HasPlayerLOS() == 1 && d > MinRngAttackDist && d < Obj_GetLocalVar(AI_MaxAttackRange) && (Obj_GetLocalVarI(AI_Flags)&AI_Flags_NoRangeAttck)==0 )
			{
				Obj_SetLocalVar(AI_Prev_State, Obj_GetLocalVar(AI_State));
				Obj_SetLocalVar(AI_State,AI_State_Attack_Range|AI_State_Transition);
				return;
			}
			else
			{
				//change direction.
				Obj_SetLocalVar( AI_Reaction, Obj_GetLocalVar(AI_Min_Reaction));
				//pick a direction.
				Obj_SetLocalVar( AI_Dir, ChooseMoveDir(1) );
				
				if ( Obj_GetLocalVarI(AI_Flags)&AI_Flags_Underground > 0 )
				{
					Obj_SetFlag(OFLAGS_INVISIBLE);
					Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
					Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
				}
			}
		}
	}
	else
	{
		Obj_SetLocalVar(AI_Reaction, reaction);
	}
	
	//continue moving in the current direction unless it is blocked.
	float p1_x, p1_y;
	int dir = Obj_GetLocalVar(AI_Dir);
	if (dir == -1)
	{
		dir = ChooseMoveDir(1);
		if (dir > 0)
		{
			p1_x = obj_loc_x + obj_dir_x*obj_Speed;
			p1_y = obj_loc_y + obj_dir_y*obj_Speed;
			Obj_SetLocalVar( AI_Dir, dir );
		}
		else
		{
			if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
			{
				//try moving down a little...
				obj_loc_z -= 0.02f;
				Obj_UpdateLoc();
			}
		}
	}
	else
	{
		p1_x = obj_loc_x + obj_dir_x*obj_Speed;
		p1_y = obj_loc_y + obj_dir_y*obj_Speed;
		if ( Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
		{
			dir = ChooseMoveDir(1);
			if ( dir > 0 )
			{
				p1_x = obj_loc_x + obj_dir_x*obj_Speed;
				p1_y = obj_loc_y + obj_dir_y*obj_Speed;
			}
			else if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
			{
				//try moving down a little...
				obj_loc_z -= 0.02f;
				Obj_UpdateLoc();
			}
			Obj_SetLocalVar( AI_Dir, dir );
		}
	}
	
	if ( dir > -1 )
	{
		//this will move toward (p1_x, p1_y) and colliding in the process.
		//treat drops as solid unless its a floating unit.
		float z = obj_loc_z;
		Map_CollideObj(p1_x, p1_y, obj_Radius, TRUE, (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 ? FALSE : TRUE, TRUE);
		
		if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
		{
			obj_loc_z = z;
			Obj_UpdateLoc();
		}
	}
	else if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
	{
		//try moving down a little...
		obj_loc_z -= 0.02f;
		Obj_UpdateLoc();
	}
	
	//move down toward the player...
	if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
	{
		float px, py, pz;
		float ground_height = Map_GetFloorHeight(0, -1);
		float ceil_height = Map_GetCeilingHeight(-1);
		Player_GetLoc(px, py, pz);
		
		if ( obj_loc_z > pz+5.0f && obj_loc_z >= ground_height + 5.04f)
		{
			//try moving down a little...
			obj_loc_z -= 0.02f;
			Obj_UpdateLoc();
		}
		
		if ( obj_loc_z < pz+3.0f && obj_loc_z <= ceil_height-4.04f )
		{
			//try moving up a little...
			obj_loc_z += 0.02f;
			Obj_UpdateLoc();
		}
	}
}

//Wander around, player has not been sighted yet.
void L_AI_Wander(bool bTransition)
{
	if ( bTransition )
	{
		if ( Obj_GetLocalVarI(AI_Flags)&AI_Flags_Underground > 0 )
		{
			L_AI_Wander_UG(true);
			return;
		}
	
		obj_Action = Anim_Moving;
		obj_Frame = 0;
		obj_Delay = Obj_GetLocalVar(AI_Walk_Delay);//15;
		obj_FrameDelay = Obj_GetLocalVar(AI_Walk_Delay);//15;
		Obj_SetLocalVar( AI_Reaction, Obj_GetLocalVar(AI_Min_Reaction));
		Obj_SetLocalVar(AI_Prev_State, Obj_GetLocalVar(AI_State));
		Obj_SetLocalVar(AI_State, AI_State_Wander);
		
		//pick a direction.
		Obj_SetLocalVar( AI_Dir, ChooseMoveDir(0) );
	}
	int reaction = Obj_GetLocalVar(AI_Reaction);
	reaction--;
	if ( reaction <= 0 )
	{
		Obj_SetLocalVar( AI_Reaction, Obj_GetLocalVar(AI_Min_Reaction));
		//pick a direction.
		Obj_SetLocalVar( AI_Dir, ChooseMoveDir(0) );
	}
	else
	{
		Obj_SetLocalVar(AI_Reaction, reaction);
	}
	//continue moving in the current direction unless it is blocked.
	float p1_x, p1_y;
	int dir = Obj_GetLocalVar(AI_Dir);
	if (dir == -1)
	{
		dir = ChooseMoveDir(0);
		if (dir > 0)
		{
			p1_x = obj_loc_x + obj_dir_x*obj_Speed;
			p1_y = obj_loc_y + obj_dir_y*obj_Speed;
			Obj_SetLocalVar( AI_Dir, dir );
		}
		else
		{
			if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
			{
				//try moving down a little...
				obj_loc_z -= 0.02f;
				Obj_UpdateLoc();
			}
		}
	}
	else
	{
		p1_x = obj_loc_x + obj_dir_x*obj_Speed;
		p1_y = obj_loc_y + obj_dir_y*obj_Speed;
		if ( Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
		{
			dir = ChooseMoveDir(0);
			if ( dir > 0 )
			{
				p1_x = obj_loc_x + obj_dir_x*obj_Speed;
				p1_y = obj_loc_y + obj_dir_y*obj_Speed;
			}
			else if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
			{
				//try moving down a little...
				obj_loc_z -= 0.02f;
				Obj_UpdateLoc();
			}
			Obj_SetLocalVar( AI_Dir, dir );
		}
	}
	
	if ( dir > -1 )
	{
		//this will move toward (p1_x, p1_y) and colliding in the process.
		//treat drops as solid unless its a floating unit.
		float z = obj_loc_z;
		Map_CollideObj(p1_x, p1_y, obj_Radius, TRUE, (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 ? FALSE : TRUE, TRUE);
		
		if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
		{
			obj_loc_z = z;
			Obj_UpdateLoc();
		}
	}
	else if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
	{
		//try moving down a little...
		obj_loc_z -= 0.02f;
		Obj_UpdateLoc();
	}
}

//Attempt to attack from range.
bool L_AI_Attack(bool bMelee, bool bTransition, int meleeSnd, int meleeDmg)
{
	//let the game know this enemy is attacking, so iMuse can be used appropriately.
	Obj_EnemyAttacking();
	if ( bTransition )
	{
		Obj_SetLocalVar(AI_State, bMelee?AI_State_Attack_Melee:AI_State_Attack_Range);
	}
	
	if ( bMelee )
	{
		//melee attack now...
		if ( bTransition )
		{
			obj_Action = Obj_GetLocalVarI(AI_Melee_Attack);
			obj_Frame = 0;
			obj_Delay = Obj_GetLocalVarI(AI_Shoot_Delay);
			obj_FrameDelay = Obj_GetLocalVarI(AI_Shoot_Delay);
			
			//play sound.
				 if ( meleeSnd == 0 ) Sound_Play3D("INTSTUN.VOC", 1.0f);
			else if ( meleeSnd == 1 ) Sound_Play3D("CREATUR2.VOC", 1.0f);
			else if ( meleeSnd == 2 ) Sound_Play3D("AXE-1.VOC", 1.0f);
			else if ( meleeSnd == 3 ) Sound_Play3D("KELL-5.VOC", 1.0f);
			else if ( meleeSnd == 4 ) Sound_Play3D("SWORD-1.VOC", 1.0f);
		}
		else
		{
			if ( obj_Action == Obj_GetLocalVarI(AI_Melee_Attack) && obj_Frame == 0 && obj_Delay == Obj_GetLocalVarI(AI_Shoot_Delay) )
			{
				//melee...
				float d = Obj_GetDistFromPlayer();
				if ( d < MeleeRange )
				{
					Player_DmgHealth(meleeDmg);
				}
					
				//am I still in melee range? if so continue to attack...
				if ( d < MeleeRange && (Obj_GetLocalVarI(AI_Flags)&AI_Flags_SingleAttckOnly)==0 )
				{
					//play sound.
					     if ( meleeSnd == 0 ) Sound_Play3D("INTSTUN.VOC", 1.0f);
					else if ( meleeSnd == 1 ) Sound_Play3D("CREATUR2.VOC", 1.0f);
					else if ( meleeSnd == 2 ) Sound_Play3D("AXE-1.VOC", 1.0f);
					else if ( meleeSnd == 3 ) Sound_Play3D("KELL-5.VOC", 1.0f);
					else if ( meleeSnd == 4 ) Sound_Play3D("SWORD-1.VOC", 1.0f);
					return true;
				}
				else
				{
					L_AI_Chase(true);
					return false;
				}
			}
		}
	}
	else
	{
		if ( bTransition )
		{
			obj_Action = Obj_GetLocalVarI(AI_Attack);
			obj_Frame = 0;
			obj_Delay = Obj_GetLocalVarI(AI_Shoot_Delay);
			obj_FrameDelay = Obj_GetLocalVarI(AI_Shoot_Delay);
		}
		else
		{
			if ( obj_Action == Obj_GetLocalVarI(AI_Attack) && obj_Frame == 0 && obj_Delay == Obj_GetLocalVarI(AI_Shoot_Delay) )
			{
				//shoot...
				if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_ShootExp) != 0 )
				{
					//Add an explosion at the player's position...
					if ( Map_HasPlayerLOS() == 1 )
					{
						float px, py, pz;
						Player_GetLoc(px, py, pz);
						//the direction from the object to the player.
						float dx = px - obj_loc_x;
						float dy = py - obj_loc_y;
						float nx, ny;
						Math_Normalize(dx, dy, nx, ny);
						//bias the explosion away from the player by 0.5 DFU, so that it is actually visible.
						px = px - nx*0.1f;
						py = py - ny*0.1f;
						//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
						Map_AddExplosion(px, py, pz, 10.0f, 30.0f, 0.0f, 1.0f, "CONCEXP.WAX", "CONCUSS5.VOC", false, Player_GetSector());
					}
				}
				else if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_NoRangeAttck)==0 )
				{
					int shoot = Obj_ShootPlayer( 0, Obj_GetLocalVar(AI_Shoot_Cone), Obj_GetLocalVar(AI_Sound), Obj_GetLocalVarI(AI_Shoot_Height) );	//use blaster bolts...
					if ( shoot == 0 )
					{
						L_AI_Chase(true);
						return false;
					}
				}
					
				if ( Obj_GetLocalVar(AI_ShootFT) > 0 )
				{
					obj_Frame = 0;
					obj_Delay = 15;
					obj_FrameDelay = 15;
					obj_Action = Anim_PAttack_FT;
				}
				else if ( obj_Speed > 0.3f && Map_HasPlayerLOS() == 1 )
				{
					obj_Action = Obj_GetLocalVarI(AI_Attack);
					obj_Frame = 0;
					obj_Delay = Obj_GetLocalVarI(AI_Shoot_Delay);
					obj_FrameDelay = Obj_GetLocalVarI(AI_Shoot_Delay);
				}
				else
				{
					L_AI_Chase(true);
					return false;
				}
			}
			else if ( obj_Action == Anim_PAttack_FT )
			{
				if ( obj_Frame == 0 && obj_Delay == 15 )
				{
					//we're done, now go back to chasing...
					int r = Math_Rand();
					//if we've already fired twice in a row, we can't do it again.
					if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_JustFiredTwice)>0 )
					{
						//Make sure to clear the flag so we can fire twice in a row again in the future.
						Obj_SetLocalVar( AI_Flags, Math_ClearBit(Obj_GetLocalVar(AI_Flags), AI_Flags_JustFiredTwice) );
						r = 100;
					}
					
					if ( (r<33) && (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Allow_Double_Shoot)>0 )
					{
						obj_Action = Obj_GetLocalVarI(AI_Attack);
						obj_Frame = 0;
						obj_Delay = Obj_GetLocalVarI(AI_Shoot_Delay);
						obj_FrameDelay = Obj_GetLocalVarI(AI_Shoot_Delay);
						
						//Note that we've fired twice in a row so that we don't fire again atleast until another chase sequence.
						Obj_SetLocalVar( AI_Flags, Obj_GetLocalVarI(AI_Flags)|AI_Flags_JustFiredTwice );
					}
					else
					{
						//Reposition ourselves... unless we're turrents.:)
						L_AI_Chase(true);
						return false;
					}
				}
			}
		}
	}
	return true;
}

void L_AI_Wander_UG(bool bTransition)
{
	//States: Looking around, moving under ground, attacking.
	if ( bTransition )
	{
		obj_Action = 12;
		obj_Frame = 0;
		obj_Delay = 10;
		obj_FrameDelay = 10;
		Obj_SetLocalVar(AI_Reaction, Sprite_GetFrameCnt(12, 0)*obj_FrameDelay);
		Obj_SetLocalVar(AI_Sec_State, 0);
		Obj_SetLocalVar(AI_State, AI_State_Wander_UG);
		
		//pick a direction.
		Obj_SetLocalVar( AI_Dir, ChooseMoveDir(0) );
	}
	
	int reaction = Obj_GetLocalVar(AI_Reaction);
	reaction--;
	if ( reaction <= 0 )
	{
		//2 possible states: come up for "air" and move
		if ( Obj_GetLocalVarI(AI_Sec_State) < 2 && (obj_Action != Anim_Attacking) )
		{
			//go ahead and move now...
			obj_Action = Anim_Idle;
			Obj_SetLocalVar(AI_Sec_State, 2);
			int r = Math_Rand();
			Obj_SetLocalVar(AI_Reaction, 60+r*2);
			
			Obj_SetFlag(OFLAGS_INVISIBLE);
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
			
			obj_Frame = 0;
			obj_Delay = 15;
			obj_FrameDelay = 15;
	
			int dir = ChooseMoveDir(0);
			Obj_SetLocalVar( AI_Dir, dir );
		}
		else
		{
			if ( obj_Action == Anim_Attacking )
			{
				//let the game know this enemy is attacking, so iMuse can be used appropriately.
				Obj_EnemyAttacking();
	
				obj_Action = Anim_PAttack_FT;
				obj_FrameDelay = 10;
				
				//go ahead and do the attack and sound now...
				float d = Obj_GetDistFromPlayer();
				float px, py, pz;
				Player_GetLoc(px, py, pz);
				if ( d < MeleeRange && Math_Abs(obj_loc_z-pz)<7.0f )
				{
					Player_DmgHealth(20);
				}
				Sound_Play3D("CREATUR2.VOC", 1.0f);
			}
			else
			{
				//come up for "air" and look around or attack.
				//are we close enough to try a melee attack?
				float d = Obj_GetDistFromPlayer();
				if ( d < MeleeRange && Map_IsPlayerInSector(obj_Radius)==1 )
				{
					obj_Action = Anim_Attacking;
					Obj_SetLocalVar(AI_Sec_State, 1);
					obj_FrameDelay = 10;
				}
				else
				{
					obj_Action = 12;
					Obj_SetLocalVar(AI_Sec_State, 0);
					obj_FrameDelay = 10;
				}
			}
			obj_Frame = 0;
			obj_Delay = obj_FrameDelay;
			Obj_SetLocalVar(AI_Reaction, Sprite_GetFrameCnt(obj_Action, 0)*obj_FrameDelay);
			
			Obj_ClearFlag(OFLAGS_INVISIBLE);
			Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_SetFlag(OFLAGS_COLLIDE_PROJECTILE);
		}
	}
	else
	{
		if ( Obj_GetLocalVarI(AI_Sec_State) == 2 )
		{
			int dir = Obj_GetLocalVarI( AI_Dir );
			if ( dir > -1 )
			{
				float dx, dy;
				Math_GetDir(dir, dx, dy);
				
				float p1_x = obj_loc_x + dx*obj_Speed;
				float p1_y = obj_loc_y + dy*obj_Speed;
			
				//this will move toward (p1_x, p1_y) and colliding in the process.
				//treat drops as solid unless its a floating unit.
				float z = obj_loc_z;
				Map_CollideObj(p1_x, p1_y, obj_Radius, TRUE, TRUE, FALSE);
				obj_loc_z = z;
				Obj_UpdateLoc();
			}
			
			if ( reaction < 55 )
			{
				//if the player is close enough and its moved far enough, then come up to attack...
				float d = Obj_GetDistFromPlayer();
				float px, py, pz;
				Player_GetLoc(px, py, pz);
				if ( d < MeleeRange && Math_Abs(obj_loc_z-pz)<7.0f )
				{
					if ( Map_IsPlayerInSector(obj_Radius)==1 )
					{
						//let the game know this enemy is attacking, so iMuse can be used appropriately.
						Obj_EnemyAttacking();
						
						obj_Action = Anim_Attacking;
						Obj_SetLocalVar(AI_Sec_State, 1);
						obj_FrameDelay = 10;
						
						obj_Frame = 0;
						obj_Delay = obj_FrameDelay;
						Obj_SetLocalVar(AI_Reaction, Sprite_GetFrameCnt(obj_Action, 0)*obj_FrameDelay);
						
						Obj_ClearFlag(OFLAGS_INVISIBLE);
						Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
						Obj_SetFlag(OFLAGS_COLLIDE_PROJECTILE);
					}
				}
			}
		}
		else if ( Obj_GetLocalVarI(AI_Sec_State) == 0 )
		{
			float d = Obj_GetDistFromPlayer();
			if ( d < MeleeRange )
			{
				if ( Map_IsPlayerInSector(obj_Radius)==1 )//Map_HasPlayerLOS() == 1 )
				{
					obj_Action = Anim_Attacking;
					Obj_SetLocalVar(AI_Sec_State, 1);
					obj_FrameDelay = 10;
					
					obj_Frame = 0;
					obj_Delay = obj_FrameDelay;
					
					reaction = Sprite_GetFrameCnt(obj_Action, 0)*obj_FrameDelay;
				}
			}
		}
		Obj_SetLocalVar(AI_Reaction, reaction);
	}
}

void L_AI_Remote(bool bTransition)
{
	if ( obj_Action == Anim_Dead ) { return; }
	
	//States: Looking around, moving under ground, attacking.
	if ( bTransition )
	{
		obj_Action = Anim_Moving;
		obj_Frame = 0;
		obj_Delay = 10;
		obj_FrameDelay = 10;
		Obj_SetLocalVar(AI_Reaction, 60);
		Obj_SetLocalVar(AI_Sec_State, 0);
		Obj_SetLocalVar(AI_State, AI_State_Remote);
		
		//pick a direction.
		Obj_SetLocalVar( AI_Dir, ChooseMoveDir(1) );
		
		Obj_ClearFlag(OFLAGS_INVISIBLE);
		Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
		Obj_SetFlag(OFLAGS_COLLIDE_PROJECTILE);
	}
	
	int reaction = Obj_GetLocalVar(AI_Reaction);
	reaction--;
	if ( reaction <= 0 )
	{
		//if player is close enough... shoot and move or just move...
		float d = Obj_GetDistFromPlayer();
		if ( d < 120 )
		{
			if ( Map_HasPlayerLOS() == 1 )
			{
				reaction = 60;
			}
			else
			{
				reaction = 240;
			}
		}
	}
	else
	{
		Obj_SetLocalVar(AI_Reaction, reaction);
	}
	
	//continue moving in the current direction unless it is blocked.
	float p1_x, p1_y;
	int dir = Obj_GetLocalVar(AI_Dir);
	if (dir == -1)
	{
		dir = ChooseMoveDir(1);
		if (dir > 0)
		{
			p1_x = obj_loc_x + obj_dir_x*obj_Speed;
			p1_y = obj_loc_y + obj_dir_y*obj_Speed;
			Obj_SetLocalVar( AI_Dir, dir );
		}
	}
	else
	{
		p1_x = obj_loc_x + obj_dir_x*obj_Speed;
		p1_y = obj_loc_y + obj_dir_y*obj_Speed;
		if ( Map_IsPathBlocked(p1_x, p1_y, obj_Radius, TRUE) )
		{
			dir = ChooseMoveDir(1);
			if ( dir > 0 )
			{
				p1_x = obj_loc_x + obj_dir_x*obj_Speed;
				p1_y = obj_loc_y + obj_dir_y*obj_Speed;
			}
			else if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
			{
				//try moving down a little...
				obj_loc_z -= 0.02f;
				Obj_UpdateLoc();
			}
			Obj_SetLocalVar( AI_Dir, dir );
		}
	}
	
	if ( dir > -1 )
	{
		//this will move toward (p1_x, p1_y) and colliding in the process.
		//treat drops as solid unless its a floating unit.
		float z = obj_loc_z;
		Map_CollideObj(p1_x, p1_y, obj_Radius, TRUE, (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 ? FALSE : TRUE, TRUE);
		
		obj_loc_z = z;
		Obj_UpdateLoc();
	}
	else
	{
		//try moving down a little...
		obj_loc_z -= 0.02f;
		Obj_UpdateLoc();
	}
	
	//move down toward the player...
	{
		float px, py, pz;
		float ground_height = Map_GetFloorHeight(0, -1);
		float ceil_height = Map_GetCeilingHeight(-1);
		Player_GetLoc(px, py, pz);
		
		if ( obj_loc_z > pz+5.0f && obj_loc_z >= ground_height + 5.04f)
		{
			//try moving down a little...
			obj_loc_z -= 0.02f;
			Obj_UpdateLoc();
		}
		
		if ( obj_loc_z < pz+3.0f && obj_loc_z <= ceil_height-4.04f )
		{
			//try moving up a little...
			obj_loc_z += 0.02f;
			Obj_UpdateLoc();
		}
	}
}

float ceil_dist = 5.0f;
int L_AI_RunAIState(int meleeSnd, int meleeDmg)
{
	int ret = 0;
	//I'm dead, there is nothing to do now. Eventually updates for this AI should just be shut off.
	if ( obj_Action == Anim_Dead ) 
	{ 
		float ground_height = Map_GetFloorHeight( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_FloatOnWater)>0 ? 1 : 0, -1 );
		//force gravity if this isn't a flying/floating unit.
		bool bUpdate = false;
		if ( obj_loc_z > ground_height )
		{
			obj_loc_z -= 0.4f;
			bUpdate = true;
		}
		if ( obj_loc_z < ground_height )
		{
			obj_loc_z = ground_height;
			bUpdate = true;
		}
		if (bUpdate) Obj_UpdateLoc();
		return 0; 
	}
	
	bool bTrans = Math_IsBitSet( Obj_GetLocalVar(AI_State), AI_State_Transition );
	if ( bTrans )
	{
		Obj_SetLocalVar( AI_State, Math_ClearBit(Obj_GetLocalVar(AI_State), AI_State_Transition) );
	}
	
	int state = Obj_GetLocalVarI(AI_State);
	if ( obj_Action != Anim_Dying_Melee && obj_Action != Anim_Dying_Nrml && (obj_Action != Anim_Injured || state==AI_State_Wander_UG || state==AI_State_Remote) )
	{
		switch (state)
		{
			case AI_State_Look:
				obj_Action = Anim_Idle;
				break;
			case AI_State_Chase:
				L_AI_Chase(bTrans);
				break;
			case AI_State_Wander:
				L_AI_Wander(bTrans);
				break;
			case AI_State_Attack_Melee:
				L_AI_Attack(true, bTrans, meleeSnd, meleeDmg);
				break;
			case AI_State_Attack_Range:
				L_AI_Attack(false, bTrans, -1, 0);
				break;
			case AI_State_Wander_UG:
				L_AI_Wander_UG(bTrans);
				break;
			case AI_State_Remote:
				L_AI_Remote(bTrans);
				break;
		}
	}
	else if ( obj_Action == Anim_Dying_Melee && obj_Frame >= Sprite_GetFrameCnt(Anim_Dying_Melee, 0)-1 && obj_Delay < 1 )
	{
		obj_Action = Anim_Dead; 
		ret = 1;
	}
	else if ( obj_Action == Anim_Dying_Nrml && obj_Frame >= Sprite_GetFrameCnt(Anim_Dying_Nrml, 0)-1 && obj_Delay < 1 )
	{
		obj_Action = Anim_Dead;
		ret = 1;
	}
	else if ( state != AI_State_Wander_UG && state != AI_State_Remote && obj_Action == Anim_Injured && obj_Frame >= Sprite_GetFrameCnt(Anim_Injured, 0)-1 && obj_Delay < 1 )
	{
		if ( obj_Alive == 0 ) { obj_Action = Anim_Dead; ret = 1; }
		else
		{
			float d = Obj_GetDistFromPlayer();
			if ( d < MeleeRange && (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Has_Melee)>0 )
			{
				//try melee attack if possible.
				L_AI_Attack(true, true, meleeSnd, meleeDmg);
			}
			else if ( (Obj_GetLocalVarI(AI_Flags)&AI_Flags_NoRangeAttck)==0 )
			{
				L_AI_Attack(false, true, -1, 0);
			}
			else
			{
				L_AI_Chase(true);
			}
		}
	}
	
	//fall to the ground if this is a ground based unit.
	float ground_height = Map_GetFloorHeight( ((Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 || (Obj_GetLocalVarI(AI_Flags)&AI_Flags_FloatOnWater)>0) ? 1 : 0, -1 );
	if ( obj_Action != Anim_Dying_Nrml && obj_Action != Anim_Dying_Melee && obj_Action != Anim_Dead && (Obj_GetLocalVarI(AI_Flags)&AI_Flags_Floating)>0 )
	{
		float ceil_height = Map_GetCeilingHeight(-1);
		if ( obj_loc_z < ground_height + 5.0f )
		{
			obj_loc_z += 0.4f;
		}
		if ( obj_loc_z > ceil_height-ceil_dist )
		{
			obj_loc_z = ceil_height-ceil_dist;
		}
	}
	else
	{
		//force gravity if this isn't a flying/floating unit.
		if ( obj_loc_z > ground_height )
		{
			obj_loc_z -= 0.4f;
		}
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
	}
	Obj_UpdateLoc();
	
	//Did I just die?
	return ret;
}

bool L_AI_SendMsg(bool bSwapDeathAnim, int nDeathSnd, int nDmgSnd, int nAlertSnd)
{
	bool bJustDied = false;
	if ( obj_Alive == 1 )
	{
		switch (obj_uMsg)
		{
			case MSG_NRML_DAMAGE:
				obj_HP -= msg_nVal;
				if ( obj_HP <= 0 )
				{
					obj_HP = 0;
					obj_Alive = 0;
					obj_Frame = 0;
					obj_Delay = 6;
					obj_FrameDelay = 6;
					obj_Action = bSwapDeathAnim ? Anim_Dying_Melee : Anim_Dying_Nrml;

					Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
					Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
					Obj_ClearFlag(OFLAGS_COLLIDE_OBJECTS);
					
					//-----------death---------------
					     if ( nDeathSnd == 0 ) Sound_Play3D("ST-DIE-1.VOC", 1.0f);
					else if ( nDeathSnd == 1 ) Sound_Play3D("EX-SMALL.VOC", 1.0f);
					else if ( nDeathSnd == 2 ) Sound_Play3D("PROBALM.VOC",  1.0f);
					else if ( nDeathSnd == 3 ) { Sound_Play3D("REMOTE-2.VOC", 1.0f); obj_Action = Anim_Dead; }
					else if ( nDeathSnd == 4 ) Sound_Play3D("CREATDIE.VOC", 1.0f);
					else if ( nDeathSnd == 5 ) Sound_Play3D("REEYEE-3.VOC", 1.0f);
					else if ( nDeathSnd == 6 ) Sound_Play3D("GAMOR-1.VOC",  1.0f);
					else if ( nDeathSnd == 7 ) Sound_Play3D("BOSSKDIE.VOC", 1.0f);
					else if ( nDeathSnd == 8 ) Sound_Play3D("KELL-7.VOC",   1.0f);
					else if ( nDeathSnd == 9 ) Sound_Play3D("PHASE1C.VOC",  1.0f);
					else if ( nDeathSnd == 10) Sound_Play3D("PHASE2C.VOC",  1.0f);
					else if ( nDeathSnd == 11) Sound_Play3D("PHASE3C.VOC",  1.0f);
					else if ( nDeathSnd == 12) Sound_Play3D("BOBA-4.VOC",   1.0f);
					
					bJustDied = true;
					Obj_JustDied();
				}
				else
				{
					int r = Math_Rand();
					if ( obj_Speed > 0.3f )
					{
						//hack for DT's...
						r = 0;
					}
					if ( nDmgSnd != 1 && ((Obj_GetLocalVarI(AI_Flags)&AI_Flags_MeleeWhileInjured)!=0 || r < 30) ) 
					{ 
						obj_Frame = 0;
						obj_Delay = 15;
						obj_Action = Anim_Injured; 
					}
					
					//-----------damage sound---------------
						 if ( nDmgSnd == 0 ) Sound_Play3D("ST-HRT-1.VOC", 1.0f);
					else if ( nDmgSnd == 1 ) Sound_Play3D("CREATHRT.VOC", 100.0f);
					else if ( nDmgSnd == 2 ) Sound_Play3D("REEYEE-2.VOC", 1.0f);
					else if ( nDmgSnd == 3 ) Sound_Play3D("GAMOR-2.VOC",  1.0f);
					else if ( nDmgSnd == 4 ) Sound_Play3D("GAMOR-3.VOC",  1.0f);
					else if ( nDmgSnd == 5 ) Sound_Play3D("KELL-5.VOC",  1.0f);
					else if ( nDmgSnd == 6 ) Sound_Play3D("PHASE1B.VOC",  1.0f);
					else if ( nDmgSnd == 7 ) Sound_Play3D("PHASE2B.VOC",  1.0f);
					else if ( nDmgSnd == 8 ) Sound_Play3D("PHASE3B.VOC",  1.0f);
					else if ( nDmgSnd == 9 ) Sound_Play3D("BOBA-3.VOC",   1.0f);
				}
			break;
			case MSG_MELEE_DAMAGE:
				//hack for now... double Melee damage.
				if ( nDeathSnd == 8 )
					obj_HP -= msg_nVal;
					
				obj_HP -= msg_nVal;
				if ( obj_HP <= 0 )
				{
					obj_HP = 0;
					obj_Alive = 0;
					obj_Frame = 0;
					obj_Delay = 6;
					obj_FrameDelay = 6;
					obj_Action = bSwapDeathAnim ? Anim_Dying_Nrml : Anim_Dying_Melee;

					Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
					Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
					Obj_ClearFlag(OFLAGS_COLLIDE_OBJECTS);
					
					//-----------death---------------
					     if ( nDeathSnd == 0 ) Sound_Play3D("ST-DIE-1.VOC", 1.0f);
					else if ( nDeathSnd == 1 ) Sound_Play3D("EX-SMALL.VOC", 1.0f);
					else if ( nDeathSnd == 2 ) Sound_Play3D("PROBALM.VOC",  1.0f);
					else if ( nDeathSnd == 3 ) { Sound_Play3D("REMOTE-2.VOC", 1.0f); obj_Action = Anim_Dead; }
					else if ( nDeathSnd == 4 ) Sound_Play3D("CREATDIE.VOC", 1.0f);
					else if ( nDeathSnd == 5 ) Sound_Play3D("REEYEE-3.VOC", 1.0f);
					else if ( nDeathSnd == 6 ) Sound_Play3D("GAMOR-1.VOC",  1.0f);
					else if ( nDeathSnd == 7 ) Sound_Play3D("BOSSKDIE.VOC", 1.0f);
					else if ( nDeathSnd == 8 ) Sound_Play3D("KELL-7.VOC",   1.0f);
					else if ( nDeathSnd == 9 ) Sound_Play3D("PHASE1C.VOC",  1.0f);
					else if ( nDeathSnd == 10) Sound_Play3D("PHASE2C.VOC",  1.0f);
					else if ( nDeathSnd == 11) Sound_Play3D("PHASE3C.VOC",  1.0f);
					else if ( nDeathSnd == 12) Sound_Play3D("BOBA-4.VOC",   1.0f);
					
					bJustDied = true;
					Obj_JustDied();
				}
				else
				{
					int r = Math_Rand();
					if ( obj_Speed > 0.3f )
					{
						//hack for DT's...
						r = 0;
					}
					if ( nDmgSnd != 1 && ((Obj_GetLocalVarI(AI_Flags)&AI_Flags_MeleeWhileInjured)==0||r<30) ) 
					{ 
						obj_Frame = 0;
						obj_Delay = 25;
						obj_FrameDelay = 25;
						obj_Action = Anim_Injured; 
						
						obj_loc_z += 0.5f;
						Obj_UpdateLoc();
					}
					
					//-----------damage sound---------------
					     if ( nDmgSnd == 0 ) Sound_Play3D("ST-HRT-1.VOC", 1.0f);
					else if ( nDmgSnd == 1 ) Sound_Play3D("CREATHRT.VOC", 100.0f);
					else if ( nDmgSnd == 2 ) Sound_Play3D("REEYEE-2.VOC", 1.0f);
					else if ( nDmgSnd == 3 ) Sound_Play3D("GAMOR-2.VOC",  1.0f);
					else if ( nDmgSnd == 4 ) Sound_Play3D("GAMOR-3.VOC",  1.0f);
					else if ( nDmgSnd == 5 ) Sound_Play3D("KELL-5.VOC",   1.0f);
					else if ( nDmgSnd == 6 ) Sound_Play3D("PHASE1B.VOC",  1.0f);
					else if ( nDmgSnd == 7 ) Sound_Play3D("PHASE2B.VOC",  1.0f);
					else if ( nDmgSnd == 8 ) Sound_Play3D("PHASE3B.VOC",  1.0f);
					else if ( nDmgSnd == 9 ) Sound_Play3D("BOBA-3.VOC",   1.0f);
				}
			break;
			case MSG_ALERT:
			{
				if ( System_GetTimer(0) == 0 && (Obj_GetLocalVarI(AI_Flags)&AI_Flags_NoAlert)==0 )
				{
					if ( nAlertSnd == 0 )
					{
						int nAlert = System_GetGlobalVar(0);
						//play alert sound...
						switch (nAlert)
						{
							case 0:
								Sound_Play3D("RANSTO01.VOC", 100.0f);
							break;
							case 1:
								Sound_Play3D("RANSTO02.VOC", 100.0f);
							break;
							case 2:
								Sound_Play3D("RANSTO03.VOC", 100.0f);
							break;
							case 3:
								Sound_Play3D("RANSTO04.VOC", 100.0f);
							break;
							case 4:
								Sound_Play3D("RANSTO05.VOC", 100.0f);
							break;
							case 5:
								Sound_Play3D("RANSTO06.VOC", 100.0f);
							break;
							case 6:
								Sound_Play3D("RANSTO07.VOC", 100.0f);
							break;
							case 7:
								Sound_Play3D("RANSTO08.VOC", 100.0f);
							break;
						}
						
						nAlert = (nAlert+1)%8;
						System_SetGlobalVar(0, nAlert);
					}
					else if ( nAlertSnd == 1 )
					{
						Sound_Play3D("INTALERT.VOC", 100.0f);
					}
					else if ( nAlertSnd == 2 )
					{
						Sound_Play3D("PROBE-1.VOC", 100.0f);
					}
					else if ( nAlertSnd == 3 )
					{
						Sound_Play3D("REEYEE-1.VOC", 100.0f);
					}
					else if ( nAlertSnd == 4 )
					{
						Sound_Play3D("GAMOR-3.VOC", 100.0f);
					}
					else if ( nAlertSnd == 5 )
					{
						Sound_Play3D("BOSSK-1.VOC", 100.0f);
					}
					else if ( nAlertSnd == 6 )
					{
						Sound_Play3D("KELL-1.VOC", 100.0f);
					}
					else if ( nAlertSnd == 7 )
					{
						Sound_Play3D("PHASE1A.VOC", 100.0f);
					}
					else if ( nAlertSnd == 8 )
					{
						Sound_Play3D("PHASE2A.VOC", 100.0f);
					}
					else if ( nAlertSnd == 9 )
					{
						Sound_Play3D("PHASE3A.VOC", 100.0f);
					}
					else if ( nAlertSnd == 10 )
					{
						Sound_Play3D("BOBA-1.VOC", 100.0f);
					}
					//Reset the timer so we don't play alert sounds too often.
					System_SetTimer(0, 120);	//60 ticks per second, 2 second delay: 5*60 = 120
				}
				if ( obj_Action != Anim_Injured )
				{
					L_AI_Chase(true);
				}
			}
			break;
		}
	}
	return bJustDied;
}

/***********SPECIFIC ENEMY LOGICS***********/
//
// Logic STORM1
//
void L_STORM1_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_STORM1_SetupObj()
{
    L_AI_SetupObj(20, AI_State_Look, 1, 0, Anim_Attacking, Anim_Sec_Attack, false, AI_Flags_None);
}

void L_STORM1_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IST-GUNI.FME", "RIFLE", 0);
	}
}

void L_STORM1_SendMsg()
{
	L_AI_SendMsg(true, 0, 0, 0);
}

//
// Logic TROOP
//
void L_TROOP_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_TROOP_SetupObj()
{
    L_AI_SetupObj(20, AI_State_Look, 1, 0, Anim_Attacking, Anim_Sec_Attack, false, AI_Flags_None);
}

void L_TROOP_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IST-GUNI.FME", "RIFLE", 0);
	}
}

void L_TROOP_SendMsg()
{
	L_AI_SendMsg(true, 0, 0, 0);
}

//
// Logic I_OFFICER
//
void L_I_OFFICER_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER_SetupObj()
{
   L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IENERGY.FME", "ITEMENERGY", 0);
	}
}

void L_I_OFFICER_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICERR
//
void L_I_OFFICERR_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICERR_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICERR_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IKEYR.FME", "RED", 0);
	}
}

void L_I_OFFICERR_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICERB
//
void L_I_OFFICERB_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICERB_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICERB_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IKEYB.FME", "BLUE", 0);
	}
}

void L_I_OFFICERB_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICERY
//
void L_I_OFFICERY_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICERY_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICERY_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IKEYY.FME", "YELLOW", 0);
	}
}

void L_I_OFFICERY_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER1
//
void L_I_OFFICER1_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER1_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER1_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE1", 0);
	}
}

void L_I_OFFICER1_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER2
//
void L_I_OFFICER2_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER2_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER2_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE2", 0);
	}
}

void L_I_OFFICER2_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER3
//
void L_I_OFFICER3_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER3_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER3_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE3", 0);
	}
}

void L_I_OFFICER3_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER4
//
void L_I_OFFICER4_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER4_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER4_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE4", 0);
	}
}

void L_I_OFFICER4_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER5
//
void L_I_OFFICER5_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER5_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER5_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE5", 0);
	}
}

void L_I_OFFICER5_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER6
//
void L_I_OFFICER6_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER6_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER6_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE6", 0);
	}
}

void L_I_OFFICER6_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER7
//
void L_I_OFFICER7_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER7_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER7_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE7", 0);
	}
}

void L_I_OFFICER7_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER8
//
void L_I_OFFICER8_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER8_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER8_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE8", 0);
	}
}

void L_I_OFFICER8_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic I_OFFICER9
//
void L_I_OFFICER9_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_I_OFFICER9_SetupObj()
{
    L_AI_SetupObj(10, AI_State_Look, 0, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_None);
}

void L_I_OFFICER9_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "DET_CODE.FME", "CODE9", 0);
	}
}

void L_I_OFFICER9_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic COMMANDO
//
void L_COMMANDO_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_COMMANDO_SetupObj()
{
	L_AI_SetupObj(30, AI_State_Look, 1, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_Allow_Double_Shoot);
}

void L_COMMANDO_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IST-GUNI.FME", "RIFLE", 0);
	}
}

void L_COMMANDO_SendMsg()
{
	L_AI_SendMsg(false, 0, 0, 0);
}

//
// Logic BOSSK
//
void L_BOSSK_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_BOSSK_SetupObj()
{
	L_AI_SetupObj(50, AI_State_Look, 1, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_ShootExp);
}

void L_BOSSK_Update()
{
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IST-GUNI.FME", "RIFLE", 0);
	}
}

void L_BOSSK_SendMsg()
{
	L_AI_SendMsg(false, 7, 4, 5);
}

//
// Logic INT_DROID
//
void L_INT_DROID_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_INT_DROID_SetupObj()
{
	L_AI_SetupObj(50, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, true, AI_Flags_Floating|AI_Flags_Has_Melee);
	Obj_SetProjectileData("SPRITE", "WIDBALL.WAX", "WEMISS.WAX", "PROBFIR1.VOC", "EX-TINY1.VOC", 8, 0.0);
}

void L_INT_DROID_Update()
{
	if ( L_AI_RunAIState(0, 5) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IPOWER.FME", "POWER", 0);
	}
}

void L_INT_DROID_SendMsg()
{
	L_AI_SendMsg(false, 1, -1, 1);
}

//
// Logic PROBE_DROID
//
void L_PROBE_DROID_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_PROBE_DROID_SetupObj()
{
	L_AI_SetupObj(50, AI_State_Look, 1, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_Floating|AI_Flags_Allow_Double_Shoot);
	Obj_SetLocalVar(AI_Min_Reaction, Sprite_GetFrameCnt(Anim_Moving, 0)*7);
}

void L_PROBE_DROID_Update()
{
	ceil_dist = 10.0f;
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() )
		{
			float ground_height = Map_GetFloorHeight(0, -1);
			if ( obj_loc_z < ground_height+1.0f )
				Map_AddObject("FRAME", "IPOWER.FME", "POWER", 0);
		}
	}
	ceil_dist = 5.0f;
}

void L_PROBE_DROID_SendMsg()
{
	bool bJustDied = L_AI_SendMsg(false, 2, -1, 2);
	//this enemy explodes after it dies...
	if ( bJustDied )
	{
		//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
		Map_AddExplosion(obj_loc_x, obj_loc_y, Map_GetFloorHeight(0, -1), 10.0f, 20.0f, 1.0f, 0.5f, "MINEEXP.WAX", "EX-SMALL.VOC", false, -1);
	}
}

//
// Logic REMOTE
//
void L_REMOTE_SetupLogic()
{
	//we don't want standard alerts, this unit acts the same even if no players are present.
	//Logic_AddMsgMask(MSG_NRML_DAMAGE);
	//Logic_AddMsgMask(MSG_MELEE_DAMAGE);
}

void L_REMOTE_SetupObj()
{
	//L_AI_SetupObj(20, AI_State_Remote|AI_State_Transition, 1, 0, Anim_Attacking, Anim_Sec_Attack, true, AI_Flags_Floating|AI_Flags_NoAlert);
	//obj_Speed = 1.0f;
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_REMOTE_Update()
{
	/*
	if ( L_AI_RunAIState(-1, 0) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IPOWER.FME", "POWER", 0);
	}
	*/
}

void L_REMOTE_SendMsg()
{
	//L_AI_SendMsg(false, 3, -1, 3);
}

//
// SEWER1
//
void L_SEWER1_SetupLogic()
{
	//we don't want standard alerts, this unit acts the same even if no players are present.
	Logic_AddMsgMask(MSG_NRML_DAMAGE);
	Logic_AddMsgMask(MSG_MELEE_DAMAGE);
}

void L_SEWER1_SetupObj()
{
	L_AI_SetupObj(30, AI_State_Wander_UG|AI_State_Transition, 1, 0, Anim_Moving, Anim_Attacking, true, AI_Flags_Has_Melee | AI_Flags_SingleAttckOnly | AI_Flags_NoRangeAttck | AI_Flags_Underground | AI_Flags_FloatOnWater);
	obj_Speed = 0.1f;
}

void L_SEWER1_Update()
{
	if ( L_AI_RunAIState(1, 20) == 1 )
	{
		//sewer bugs don't leave anything behind.
		//Map_AddObject("FRAME", "IPOWER.FME", "POWER", 0);
	}
}

void L_SEWER1_SendMsg()
{
	L_AI_SendMsg(false, 4, 1, -1);
}

//
// REE_YEES
//
void L_REE_YEES_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_REE_YEES_SetupObj()
{
	L_AI_SetupObj(30, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, true, AI_Flags_Has_Melee);
	Obj_SetProjectileData("FRAME", "IDET.FME", "DETEXP.WAX", "PROBFIR1.VOC", "EX-SMALL.VOC", 20, 20.0);
	Obj_SetLocalVar(AI_MaxAttackRange, 75);
}

void L_REE_YEES_Update()
{
	if ( L_AI_RunAIState(0, 10) == 1 )
	{
		if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_REE_YEES_SendMsg()
{
	L_AI_SendMsg(false, 5, 2, 3);
}

//
// REE_YEES2
//
void L_REE_YEES2_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_REE_YEES2_SetupObj()
{
	L_AI_SetupObj(30, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, true, AI_Flags_Has_Melee | AI_Flags_NoRangeAttck);
	Obj_SetProjectileData("FRAME", "IDET.FME", "DETEXP.WAX", "PROBFIR1.VOC", "EX-SMALL.VOC", 20, 20.0);
}

void L_REE_YEES2_Update()
{
	if ( L_AI_RunAIState(0, 10) == 1 )
	{
		//no DT's, melee only.
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_REE_YEES2_SendMsg()
{
	L_AI_SendMsg(false, 5, 2, 3);
}

//
// G_GUARD
//
void L_G_GUARD_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_G_GUARD_SetupObj()
{
	//add AI_Flags_Melee_Random later...
	L_AI_SetupObj(90, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, true, AI_Flags_Has_Melee | AI_Flags_NoRangeAttck | AI_Flags_SingleAttckOnly | AI_Flags_Melee_Random);
	//Obj_SetProjectileData("FRAME", "IDET.FME", "DETEXP.WAX", "PROBFIR1.VOC", "EX-SMALL.VOC", 20, 20.0);
}

void L_G_GUARD_Update()
{
	if ( L_AI_RunAIState(2, 40) == 1 )
	{
		//no DT's, melee only.
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_G_GUARD_SendMsg()
{
	L_AI_SendMsg(false, 6, 3, 4);
}

//
// D_TROOP1
//
void L_D_TROOP1_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_D_TROOP1_SetupObj()
{
	//add AI_Flags_Melee_Random later...
	L_AI_SetupObj(180, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, true, AI_Flags_Has_Melee | AI_Flags_NoRangeAttck | AI_Flags_MeleeWhileInjured);
	obj_Speed = 0.4f;
	Obj_SetLocalVar(AI_Shoot_Delay, 5.0f);
	Obj_SetLocalVar(AI_Walk_Delay, 10);
}

void L_D_TROOP1_Update()
{
	if ( L_AI_RunAIState(4, 40) == 1 )
	{
		//no DT's, melee only.
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_D_TROOP1_SendMsg()
{
	L_AI_SendMsg(false, 9, 6, 7);
}

//
// D_TROOP2
//
void L_D_TROOP2_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_D_TROOP2_SetupObj()
{
	//add AI_Flags_Melee_Random later...
	L_AI_SetupObj(180, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, false, AI_Flags_Floating|AI_Flags_Allow_Double_Shoot);
	obj_Speed = 0.4f;
	Obj_SetLocalVar(AI_Walk_Delay, 10);
	Obj_SetLocalVar(AI_Shoot_Cone, 0.0f);
	Obj_SetLocalVar(AI_Shoot_Height, 5.0f);
	Obj_SetLocalVar(AI_Shoot_Delay, 1.0f);
	Obj_SetProjectileData("SPRITE", "WPLASMA.WAX", "PLASEXP.WAX", "PLASMA4.VOC", "EX-TINY1.VOC", 30, 0.0);
}

void L_D_TROOP2_Update()
{
	if ( L_AI_RunAIState(4, 40) == 1 )
	{
		//no DT's, melee only.
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_D_TROOP2_SendMsg()
{
	L_AI_SendMsg(false, 10, 7, 8);
}

//
// D_TROOP3
//
void L_D_TROOP3_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_D_TROOP3_SetupObj()
{
	//add AI_Flags_Melee_Random later...
	L_AI_SetupObj(180, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, false, AI_Flags_Floating|AI_Flags_Allow_Double_Shoot);
	obj_Speed = 0.4f;
	Obj_SetLocalVar(AI_Walk_Delay, 10);
	Obj_SetLocalVar(AI_Shoot_Cone, 0.0f);
	Obj_SetLocalVar(AI_Shoot_Height, 5.0f);
	Obj_SetLocalVar(AI_Shoot_Delay, 1.0f);
	Obj_SetLocalVar(AI_Walk_Delay, 10);
	Obj_SetProjectileData("SPRITE", "WPLASMA.WAX", "PLASEXP.WAX", "PLASMA4.VOC", "EX-TINY1.VOC", 30, 0.0);
}

void L_D_TROOP3_Update()
{
	if ( L_AI_RunAIState(4, 40) == 1 )
	{
		//no DT's, melee only.
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_D_TROOP3_SendMsg()
{
	L_AI_SendMsg(false, 11, 8, 9);
}

//
// BOBA_FETT
//
void L_BOBA_FETT_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_BOBA_FETT_SetupObj()
{
	//add AI_Flags_Melee_Random later...
	L_AI_SetupObj(180, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, false, AI_Flags_Floating|AI_Flags_Allow_Double_Shoot);
	obj_Speed = 0.4f;
	Obj_SetLocalVar(AI_Walk_Delay, 10);
	Obj_SetLocalVar(AI_Shoot_Cone, 0.0f);
	Obj_SetLocalVar(AI_Shoot_Height, 5.0f);
	Obj_SetLocalVar(AI_Shoot_Delay, 10.0f);
	Obj_SetLocalVar(AI_Walk_Delay, 10);
	Obj_SetProjectileData("SPRITE", "BOBABALL.WAX", "BULLEXP.WAX", "BOBA-2.VOC", "EX-TINY1.VOC", 30, 0.0);
}

void L_BOBA_FETT_Update()
{
	if ( L_AI_RunAIState(4, 40) == 1 )
	{
		//no DT's, melee only.
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_BOBA_FETT_SendMsg()
{
	L_AI_SendMsg(false, 12, 9, 10);
}

//
// KELL
//
void L_KELL_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_KELL_SetupObj()
{
	//Half HP until the fist damage is beefed up.
	int HP = 180;
	L_AI_SetupObj(HP, AI_State_Look, 1, 0, Anim_Sec_Attack, Anim_Attacking, true, AI_Flags_Has_Melee | AI_Flags_NoRangeAttck | AI_Flags_MeleeWhileInjured);
	obj_Speed = 0.2f;
	obj_Radius = 4.0f;
	Obj_SetLocalVar(AI_Walk_Delay, 10);
}

void L_KELL_Update()
{
	if ( L_AI_RunAIState(3, 20) == 1 )
	{
		//no DT's, melee only.
		//if ( !Obj_In_Water() ) Map_AddObject("FRAME", "IDETS.FME", "DETONATORS", 0);
	}
}

void L_KELL_SendMsg()
{
	L_AI_SendMsg(false, 8, 5, 6);
}

//
// Logic TURRET
//
void L_TURRET_SetupLogic()
{
	L_AI_SetupLogic();
}

void L_TURRET_SetupObj()
{
    obj_Speed = 0.0f;
    obj_dY = 0.015f;
	obj_HP = 70;
	obj_Radius = 2.0f;
	obj_Height = -2.0f;
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PROJECTILE);
	Obj_SetFlag(OFLAGS_COLLIDE_OBJECTS);
	Obj_SetFlag(OFLAGS_ENEMY);
	Obj_EnableAnim(1);
	
	//put into the "idle" action...
	obj_Action = Anim_Idle;
	obj_Frame = 0;
	obj_Delay = 15;
	obj_FrameDelay = 15;
	
	//Shoot delay...
	Obj_SetLocalVar(1, 60);
}

void L_TURRET_Update()
{
	int ret = 0;
	//I'm dead, there is nothing to do now. Eventually updates for this AI should just be shut off.
	if ( obj_Alive == 1 ) 
	{
		float px, py, pz, dx, dy, nx, ny;
		Player_GetLoc(px, py, pz);
		
		dx = px-obj_loc_x;
		dy = py-obj_loc_y;
		
		Math_Normalize(dx, dy, nx, ny);
		
		float angle = obj_Yaw;
		const float TwoPi = 6.283185307179586476925286766559f;
		const float Pi = 3.1415926535897932384626433832795f;
		const float shootEps = 0.1745f;	//about 10 degrees.
		int bShoot = 0;
		if ( Math_Abs(dx) < 80.0f && Math_Abs(dy) < 80.0f )
		{
			if ( Map_HasPlayerLOS() == 1 )
			{
				if ( ny >= 0.0f )
				{
					angle = Math_ACos(-nx);
				}
				else
				{
					angle = TwoPi - Math_ACos(-nx);
				}
				const float PiOver2 = 1.570796326794896619231321692f;
				angle += PiOver2;
				
				if ( angle < 0 ) angle += TwoPi;
				else if ( angle > TwoPi ) angle -= TwoPi;
				
				//now rotate towards the player...
				float dY = angle - obj_Yaw;
				if ( Math_Abs(dY) > Pi )
				{
					if ( dY > 0.0f ) dY -= TwoPi;
					else dY += TwoPi;
				}
				if ( Math_Abs(dY) < shootEps )
				{
					bShoot = 1;
				}
				if ( dY > 0.026f ) dY = 0.026f;
				else if ( dY < -0.026f ) dY = -0.026f;
				obj_Yaw += dY;
			}
		}
		
		float shootDelay = Obj_GetLocalVar(1);		
		if ( shootDelay > 0.0f )
		{
			shootDelay -= 1.0f;
		}
		if ( bShoot == 1 && shootDelay <= 0.0f )
		{
			//now shoot at the player. :)
			Obj_ShootPlayer( 0, 0.0f, 1, Obj_GetLocalVarI(AI_Shoot_Height) );	//use blaster bolts...
			shootDelay = 60.0f;
		}
		Obj_SetLocalVar(1, shootDelay);
	}
}

void L_TURRET_SendMsg()
{
	if ( obj_Alive == 1 )
	{
		switch (obj_uMsg)
		{
			case MSG_NRML_DAMAGE:
				obj_HP -= msg_nVal;
				if ( obj_HP <= 0 )
				{
					obj_HP = 0;
					obj_Alive = 0;
					obj_Frame = 0;
					obj_Action = Anim_Dead;

					Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
					Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
					Obj_ClearFlag(OFLAGS_COLLIDE_OBJECTS);
					
					//-----------death---------------
					//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
					Map_AddExplosion(obj_loc_x, obj_loc_y, obj_loc_z, 10.0f, 0.0f, 0.0f, 0.25f, "MISSEXP.WAX", "EX-SMALL.VOC", false, -1);
					Obj_Delete();
					Obj_JustDied();
				}
			break;
			case MSG_MELEE_DAMAGE:
				obj_HP -= msg_nVal;
				if ( obj_HP <= 0 )
				{
					obj_HP = 0;
					obj_Alive = 0;
					obj_Frame = 0;
					obj_Action = Anim_Dead;

					Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
					Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
					Obj_ClearFlag(OFLAGS_COLLIDE_OBJECTS);
					
					//-----------death---------------
					//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
					Map_AddExplosion(obj_loc_x, obj_loc_y, obj_loc_z, 10.0f, 0.0f, 0.0f, 0.25f, "MISSEXP.WAX", "EX-SMALL.VOC", false, -1);
					Obj_Delete();
					Obj_JustDied();
				}
			break;
			case MSG_ALERT:
			{
			}
			break;
		}
	}
}

/***********GENERATORS*******/
void GeneratorUpdate(string type, string file, string logic)
{
	if ( Obj_GetLocalVar(7) == 0.0f ) { return; }
	if ( Obj_GetLocalVar(0) == 0.0f && Obj_GetLocalVar(8) == 0.0f )
	{
		//start working...
		
		//are there too many still alive?
		if ( Obj_GetLocalVar(9) < Obj_GetLocalVar(2) && Obj_GetLocalVar(8) <= 0.0f )
		{
			//is the player in the correct range?
			float d = Obj_GetDistFromPlayer();
			if ( d >= Obj_GetLocalVar(3) && d <= Obj_GetLocalVar(4) )
			{
				//now make sure there is no LOS to the player.
				if ( Map_HasPlayerLOS() == 0 )
				{
					//now go ahead and generate Probe Droid and set them to wander...
					int hObj = Map_AddObject(type, file, logic, 0);
					Obj_AddObjMsgHandler(hObj, MSG_OBJ_DEAD);
					Obj_QueAddObj_SetLocalVar(AI_State, AI_State_Wander | AI_State_Transition);
					
					int numAlive = Obj_GetLocalVar(9);
					Obj_SetLocalVar(9, numAlive+1);
					
					int numGen = Obj_GetLocalVar(10);
					Obj_SetLocalVar(10, numGen+1);
					
					if ( numGen >= Obj_GetLocalVar(5) )
					{
						//ok we're done here...
						Obj_Delete();
					}
					
					Obj_SetLocalVar(8, Obj_GetLocalVar(1) );
				}
			}
		}
		else if ( Obj_GetLocalVar(8) > 0.0f )
		{
			float interval = Obj_GetLocalVar(8);
			interval -= dt;
			Obj_SetLocalVar(8, interval);
		}
	}
	else
	{
		float delay = Obj_GetLocalVar(0);
		if ( delay == 0.0f )
		{
			float interval = Obj_GetLocalVar(8) - dt;
			if ( interval < 0.0f ) { interval = 0.0f; }
			Obj_SetLocalVar(8, interval);
		}
		else
		{
			delay = delay - dt;
			if ( delay < 0.0f ) { delay = 0.0f; }
			Obj_SetLocalVar(0, delay);
		}
	}
}

void GeneratorSendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_MASTER_ON:
			Obj_SetLocalVar(7, 1.0f);
		break;
		case MSG_OBJ_DEAD:
		{
			//remove the object message handler.
			Obj_RemoveObjMsgHandler(msg_nVal, MSG_OBJ_DEAD);
			//decrease the number alive counter.
			int numAlive = Obj_GetLocalVar(9);
			Obj_SetLocalVar(9, numAlive-1);
		}
		break;
	}
}

void SetupGeneratorLogic()
{
	Logic_AddMsgMask(MSG_MASTER_ON);
	Logic_AddMsgMask(MSG_OBJ_DEAD);
}

//
// GENERATORPROBE_DROID
//
void L_GENERATORPROBE_DROID_SetupLogic()
{
	SetupGeneratorLogic();
}

void L_GENERATORPROBE_DROID_SetupObj()
{
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_GENERATORPROBE_DROID_Update()
{
	GeneratorUpdate("SPRITE", "PROBE.WAX", "PROBE_DROID");
}

void L_GENERATORPROBE_DROID_SendMsg()
{
	GeneratorSendMsg();
}

//
// GENERATORINT_DROID
//
void L_GENERATORINT_DROID_SetupLogic()
{
	SetupGeneratorLogic();
}

void L_GENERATORINT_DROID_SetupObj()
{
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_GENERATORINT_DROID_Update()
{
	GeneratorUpdate("SPRITE", "INTDROID.WAX", "INT_DROID");
}

void L_GENERATORINT_DROID_SendMsg()
{
	GeneratorSendMsg();
}

//
// GENERATORSTORM1
//
void L_GENERATORSTORM1_SetupLogic()
{
	SetupGeneratorLogic();
}

void L_GENERATORSTORM1_SetupObj()
{
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_GENERATORSTORM1_Update()
{
	GeneratorUpdate("SPRITE", "STORMFIN.WAX", "STORM1");
}

void L_GENERATORSTORM1_SendMsg()
{
	GeneratorSendMsg();
}

//
// GENERATORCOMMANDO
//
void L_GENERATORCOMMANDO_SetupLogic()
{
	SetupGeneratorLogic();
}

void L_GENERATORCOMMANDO_SetupObj()
{
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_GENERATORCOMMANDO_Update()
{
	GeneratorUpdate("SPRITE", "COMMANDO.WAX", "COMMANDO");
}

void L_GENERATORCOMMANDO_SendMsg()
{
	GeneratorSendMsg();
}

//
// GENERATORSEWER1
//
void L_GENERATORSEWER1_SetupLogic()
{
	SetupGeneratorLogic();
}

void L_GENERATORSEWER1_SetupObj()
{
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_GENERATORSEWER1_Update()
{
	GeneratorUpdate("SPRITE", "SEWERBUG.WAX", "SEWER1");
}

void L_GENERATORSEWER1_SendMsg()
{
	GeneratorSendMsg();
}

//
// GENERATORG_GUARD
//
void L_GENERATORG_GUARD_SetupLogic()
{
	SetupGeneratorLogic();
}

void L_GENERATORG_GUARD_SetupObj()
{
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_GENERATORG_GUARD_Update()
{
	GeneratorUpdate("SPRITE", "GAMGUARD.WAX", "G_GUARD");
}

void L_GENERATORG_GUARD_SendMsg()
{
	GeneratorSendMsg();
}

//
// GENERATORREE_YEES
//
void L_GENERATORREE_YEES_SetupLogic()
{
	SetupGeneratorLogic();
}

void L_GENERATORREE_YEES_SetupObj()
{
	Obj_SetFlag(OFLAGS_INVISIBLE);
}

void L_GENERATORREE_YEES_Update()
{
	GeneratorUpdate("SPRITE", "REEYEES.WAX", "REE_YEES");
}

void L_GENERATORREE_YEES_SendMsg()
{
	GeneratorSendMsg();
}

/***********DROIDS***********/
//
// Logic MOUSEBOT
//
void L_MOUSEBOT_SetupLogic()
{
	Logic_AddMsgMask(0);
}

void L_MOUSEBOT_SetupObj()
{
	Obj_SetMoveDir( obj_dir_x, obj_dir_y, 0.0f );
	obj_Speed = 0.4f;
	obj_dY = 0.015f;
	Obj_SetLocalVar(0, 0.0f);
	obj_Radius = 2.0f;
}

void L_MOUSEBOT_Update()
{
	//now move around "randomly"
	float p1_x = obj_loc_x + obj_dir_x*obj_Speed;
	float p1_y = obj_loc_y + obj_dir_y*obj_Speed;
	
	Map_SetStepSize(0.0f);
	Map_CollideObj(p1_x, p1_y, obj_Radius, TRUE, TRUE, TRUE);
	Map_RestoreStepSize();

	//we hit all wall, drop or step.
	if ( Map_GetWallHit() > -1 )
	{
		obj_Speed *= -1.0f;
	}

	obj_Yaw += obj_dY;
	if ( obj_Yaw < 0.0f )
	{
		obj_Yaw += TWO_PI;
	}
	else if ( obj_Yaw > TWO_PI )
	{
		obj_Yaw -= TWO_PI;
	}

	int r = Math_Rand();
	if ( r > 99 )
	{
		obj_Speed = -obj_Speed;
	}
	else if ( r > 90 )
	{
		obj_dY = -obj_dY;
	}
	
	//randomly play sounds, make sure there is a delay between when sounds can play.
	float fSoundDelay = Obj_GetLocalVar(0);
	if ( r > 35 && r < 37 && fSoundDelay <= 0.0f )
	{
		Sound_Play3D("EEEK-1.VOC", 0.0625f);
		fSoundDelay = 240.0f;
	}
	else
	{
		fSoundDelay -= 1.0f;
	}
	Obj_SetLocalVar(0, fSoundDelay);

	float dx = Math_Sin(obj_Yaw);
	float dy = Math_Cos(obj_Yaw);
	Obj_SetDir( dx, dy, 0.0f );
	Obj_SetMoveDir( dx, dy, 0.0f );
}

void L_MOUSEBOT_SendMsg()
{
	if ( obj_Alive == 1 )
	{
	}
}

/***********ITEMS***********/
//
// Logic ITEMSHIELD
//
void L_ITEMSHIELD_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}


void L_ITEMSHIELD_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	int light = Map_AddLight(0, 0, 2.0f, 10, 20, 128, 20);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_ITEMSHIELD_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int shields = Player_GetShields();
			if ( shields < 200 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				//now add shields...
				shields += 20;
				if ( shields > 200 ) shields = 200;
				
				Player_SetShields( shields );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(114);
				
				Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// Logic SHIELD
//
void L_SHIELD_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_SHIELD_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	int light = Map_AddLight(0, 0, 2.0f, 10, 20, 128, 20);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_SHIELD_SendMsg()
{
	L_ITEMSHIELD_SendMsg();
}

//
// POWER
//
void L_POWER_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_POWER_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	//int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	//Obj_SetLocalVar(0, light);
	//Obj_AttachLight(light);
}

void L_POWER_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_POWER_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int power = Player_GetAmmo(AMMO_POWER);
			if ( power < 500 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				power += 10;
				if ( power > 500 ) power = 500;
				
				Player_SetAmmo( AMMO_POWER, power );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(201);
				
				//Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// SHELL
//
void L_SHELL_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_SHELL_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	//int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	//Obj_SetLocalVar(0, light);
	//Obj_AttachLight(light);
}

void L_SHELL_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_SHELL_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int shells = Player_GetAmmo(AMMO_MORTOR);
			if ( shells < 50 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				shells += 1;
				if ( shells > 50 ) shells = 50;
				
				Player_SetAmmo( AMMO_MORTOR, shells );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(205);
				
				//Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// SHELLS
//
void L_SHELLS_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_SHELLS_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	//int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	//Obj_SetLocalVar(0, light);
	//Obj_AttachLight(light);
}

void L_SHELLS_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_SHELLS_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int shells = Player_GetAmmo(AMMO_MORTOR);
			if ( shells < 50 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				shells += 5;
				if ( shells > 50 ) shells = 50;
				
				Player_SetAmmo( AMMO_MORTOR, shells );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(206);
				
				//Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// MINE
//
void L_MINE_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_MINE_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	//int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	//Obj_SetLocalVar(0, light);
	//Obj_AttachLight(light);
}

void L_MINE_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_MINE_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int mines = Player_GetAmmo(AMMO_MINE);
			if ( mines < 30 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				mines += 1;
				if ( mines > 30 ) mines = 30;
				
				Player_SetAmmo( AMMO_MINE, mines );
				Player_AddItem("MINES");
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(109);
				
				//Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// MINES
//
void L_MINES_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_MINES_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	//int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	//Obj_SetLocalVar(0, light);
	//Obj_AttachLight(light);
}

void L_MINES_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_MINES_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int mines = Player_GetAmmo(AMMO_MINE);
			if ( mines < 30 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				mines += 5;
				if ( mines > 30 ) mines = 30;
				
				Player_SetAmmo( AMMO_MINE, mines );
				Player_AddItem("MINES");
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(208);
				
				//Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// LAND_MINE
//
void L_LAND_MINE_SetupLogic()
{
	Logic_AddMsgMask(MSG_PROXIMITY);
	Logic_AddMsgMask(MSG_NRML_DAMAGE);
}

void L_LAND_MINE_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PROXIMITY);
	
	//set a 1 second delay before the land mine can fire off.
	Obj_SetLocalVar(0, 60.0f);
	
	//int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	//Obj_SetLocalVar(0, light);
	//Obj_AttachLight(light);
}

void L_LAND_MINE_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
	
	float delay = Obj_GetLocalVar(0);
	if ( delay > 0.0f )
	{
		delay -= 1.0f;
	}
	else
	{
		delay = 0.0f;
	}
	Obj_SetLocalVar(0, delay);
}

void L_LAND_MINE_SendMsg()
{
	if ( Obj_IsFlagSet(OFLAGS_COLLIDE_PROXIMITY) != 0 && Obj_GetLocalVar(0) == 0.0f )
	{
		switch (obj_uMsg)
		{
			case MSG_PROXIMITY:
			{
				//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
				Map_AddExplosion(obj_loc_x, obj_loc_y, Map_GetFloorHeight(0, -1), 40.0f, 60.0f, 1.0f, 1.0f, "MINEEXP.WAX", "EX-SMALL.VOC", true, -1);
			
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PROXIMITY);
		
				//play the trigger sound.			
				Sound_Play2D("BEEP-10.VOC");
			}
			break;
			case MSG_NRML_DAMAGE:
			{
				if ( msg_nVal >= 40 )
				{
					//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
					Map_AddExplosion(obj_loc_x, obj_loc_y, Map_GetFloorHeight(0, -1), 40.0f, 60.0f, 1.0f, 1.0f, "MINEEXP.WAX", "EX-SMALL.VOC", true, -1);
				
					Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
					Obj_ClearFlag(OFLAGS_COLLIDE_PROXIMITY);
			
					//play the trigger sound.			
					Sound_Play2D("BEEP-10.VOC");
				}
			}
			break;
		}
	}
}

//
// LAND_MINE_PROX
//
void L_LAND_MINE_PROX_SetupLogic()
{
	Logic_AddMsgMask(MSG_PROXIMITY);
	Logic_AddMsgMask(MSG_NRML_DAMAGE);
}

void L_LAND_MINE_PROX_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_OBJECTS);
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PROXIMITY);
	
	//set a 1 second delay before the land mine can fire off.
	Obj_SetLocalVar(0, 60.0f);
	
	//int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	//Obj_SetLocalVar(0, light);
	//Obj_AttachLight(light);
}

void L_LAND_MINE_PROX_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
	
	float delay = Obj_GetLocalVar(0);
	if ( delay > 0.0f )
	{
		delay -= 1.0f;
	}
	else
	{
		delay = 0.0f;
	}
	Obj_SetLocalVar(0, delay);
}

void L_LAND_MINE_PROX_SendMsg()
{
	if ( Obj_IsFlagSet(OFLAGS_COLLIDE_PROXIMITY) != 0 && Obj_GetLocalVar(0) <= 0.0f )
	{
		switch (obj_uMsg)
		{
			case MSG_PROXIMITY:
			{
				//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
				Map_AddExplosion(obj_loc_x, obj_loc_y, Map_GetFloorHeight(0, -1), 40.0f, 60.0f, 1.0f, 1.0f, "MINEEXP.WAX", "EX-SMALL.VOC", true, -1);
			
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PROXIMITY);
		
				//play the trigger sound.			
				Sound_Play2D("BEEP-10.VOC");
			}
			break;
			case MSG_NRML_DAMAGE:
			{
				if ( msg_nVal >= 40 )
				{
					//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
					Map_AddExplosion(obj_loc_x, obj_loc_y, Map_GetFloorHeight(0, -1), 40.0f, 60.0f, 1.0f, 1.0f, "MINEEXP.WAX", "EX-SMALL.VOC", true, -1);
				
					Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
					Obj_ClearFlag(OFLAGS_COLLIDE_PROXIMITY);
			
					//play the trigger sound.			
					Sound_Play2D("BEEP-10.VOC");
				}
			}
			break;
		}
	}
}

//
// LAND_MINE_AUTO
//
void L_LAND_MINE_AUTO_SetupLogic()
{
}

void L_LAND_MINE_AUTO_SetupObj()
{
	//set a 3 second delay before the automatically exploding.
	Obj_SetLocalVar(0, 180.0f);
}

void L_LAND_MINE_AUTO_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
	
	float delay = Obj_GetLocalVar(0);
	if ( delay > 0.0f )
	{
		delay -= 1.0f;
		Obj_SetLocalVar(0, delay);
	}
	else
	{
		//EXPLODE!
		//x, y, z, radius, damage, delay, scale, graphic (sprite), sound
		Map_AddExplosion(obj_loc_x, obj_loc_y, Map_GetFloorHeight(0, -1), 40.0f, 60.0f, 0.0f, 1.0f, "MINEEXP.WAX", "EX-SMALL.VOC", false, -1);
		Obj_Delete();
	}
}

//
// MISSILE
//
void L_MISSILE_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_MISSILE_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 0, 5, 128, 0, 0);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_MISSILE_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_MISSILE_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int missles = Player_GetAmmo(AMMO_MISSLE);
			if ( missles < 20 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				missles += 1;
				if ( missles > 20 ) missles = 20;
				
				Player_SetAmmo( AMMO_MISSLE, missles );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(209);
				
				Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// MISSILES
//
void L_MISSILES_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_MISSILES_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 0, 15, 128, 0, 0);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_MISSILES_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_MISSILES_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int missles = Player_GetAmmo(AMMO_MISSLE);
			if ( missles < 20 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				missles += 5;
				if ( missles > 20 ) missles = 20;
				
				Player_SetAmmo( AMMO_MISSLE, missles );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(210);
				
				Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// PLASMA
//
void L_PLASMA_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_PLASMA_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_PLASMA_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_PLASMA_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int plasma = Player_GetAmmo(AMMO_PLASMA);
			if ( plasma < 400 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				plasma += 20;
				if ( plasma > 400 ) plasma = 400;
				
				Player_SetAmmo( AMMO_PLASMA, plasma );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(202);
				
				Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// ITEMENERGY
//
void L_ITEMENERGY_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_ITEMENERGY_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_ITEMENERGY_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_ITEMENERGY_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int energy = Player_GetAmmo(AMMO_ENERGY);
			if ( energy < 500 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				//now add shields...
				energy += 15;
				if ( energy > 500 ) energy = 500;
				
				Player_SetAmmo( AMMO_ENERGY, energy );
				Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(200);
				
				Map_RemoveLight( Obj_GetLocalVar(0) );
			}
		}
		break;
	}
}

//
// ENERGY
//
void L_ENERGY_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_ENERGY_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 0, 5, 0, 0, 128);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_ENERGY_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_ENERGY_SendMsg()
{
	L_ITEMENERGY_SendMsg();
}

//
// DETONATOR
//
void L_DETONATOR_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_DETONATOR_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
}

void L_DETONATOR_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_DETONATOR_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int det = Player_GetAmmo(AMMO_DETONATOR);
			if ( det < 50 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				//now add shields...
				det += 3;
				if ( det > 50 ) det = 50;
				
				Player_SetAmmo( AMMO_DETONATOR, det );
				Player_AddItem("DETONATOR");
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(102);
			}
		}
		break;
	}
}

//
// DETONATORS
//
void L_DETONATORS_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_DETONATORS_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
}

void L_DETONATORS_Update()
{
	float ground_height = Map_GetFloorHeight(0, -1);
	//force gravity if this isn't a flying/floating unit.
	bool bUpdate = false;
	if ( obj_loc_z > ground_height )
	{
		obj_loc_z -= 0.4f;
		bUpdate = true;
	}
	if ( obj_loc_z < ground_height )
	{
		obj_loc_z = ground_height;
		bUpdate = true;
	}
	if (bUpdate) Obj_UpdateLoc();
}

void L_DETONATORS_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			int det = Player_GetAmmo(AMMO_DETONATOR);
			if ( det < 50 )
			{
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				//now add shields...
				det += 5;
				if ( det > 50 ) det = 50;
				
				Player_SetAmmo( AMMO_DETONATOR, det );
				Player_AddItem("DETONATOR");
				Obj_Delete();
				
				Sound_Play2D("KEY.VOC");
				System_PrintIndex(204);
			}
		}
		break;
	}
}

//
// LIFE
//
void L_LIFE_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_LIFE_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 20, 20);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_LIFE_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
			
			Player_AddLife();
				
			Player_QueueFlash( PLAYER_FLASH_BLUE, 0.1f );
			Obj_Delete();
				
			Sound_Play2D("BONUS.VOC");
			System_PrintIndex(310);
			
			Map_RemoveLight( Obj_GetLocalVar(0) );
		}
		break;
	}
}

//
// Logic RED
// 
void L_RED_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_RED_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 0);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_RED_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
			
			Player_AddItem("REDKEY");
			Obj_Delete();
			Map_RemoveLight( Obj_GetLocalVar(0) );
			
			Sound_Play2D("BONUS.VOC");
			System_PrintIndex(300);
		}
		break;
	}
}

//
// Logic ITEMRED
// 
void L_ITEMRED_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_ITEMRED_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 0);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_ITEMRED_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
			
			Player_AddItem("REDKEY");
			Obj_Delete();
			Map_RemoveLight( Obj_GetLocalVar(0) );
			
			Sound_Play2D("BONUS.VOC");
			System_PrintIndex(300);
		}
		break;
	}
}

//
// Logic BLUE
// 
void L_BLUE_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_BLUE_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 1.0f, 10, 0, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_BLUE_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
			
			Player_AddItem("BLUEKEY");
			Obj_Delete();
			Map_RemoveLight( Obj_GetLocalVar(0) );
			
			Sound_Play2D("BONUS.VOC");
			System_PrintIndex(302);
		}
		break;
	}
}

//
// Logic ITEMBLUE
// 
void L_ITEMBLUE_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_ITEMBLUE_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 1.0f, 10, 0, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_ITEMBLUE_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
			
			Player_AddItem("BLUEKEY");
			Obj_Delete();
			Map_RemoveLight( Obj_GetLocalVar(0) );
			
			Sound_Play2D("BONUS.VOC");
			System_PrintIndex(302);
		}
		break;
	}
}

//
// Logic YELLOW
// 
void L_YELLOW_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_YELLOW_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 255, 0);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_YELLOW_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
		{
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
			
			Player_AddItem("YELLOWKEY");
			Obj_Delete();
			Map_RemoveLight( Obj_GetLocalVar(0) );
			
			Sound_Play2D("BONUS.VOC");
			System_PrintIndex(301);
		}
		break;
	}
}

//
// Logic CODE1
// 
void L_CODE1_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE1_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE1");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(501);
	}
}

//
// Logic CODE2
// 
void L_CODE2_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE2_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE2");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(502);
	}
}

//
// Logic CODE3
// 
void L_CODE3_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE3_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE3");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(503);
	}
}

//
// Logic CODE4
// 
void L_CODE4_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE4_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE4");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(504);
	}
}

//
// Logic CODE5
// 
void L_CODE5_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE5_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE5");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(505);
	}
}

//
// Logic CODE6
// 
void L_CODE6_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE6_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE6");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(506);
	}
}

//
// Logic CODE7
// 
void L_CODE7_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE7_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE7");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(507);
	}
}

//
// Logic CODE8
// 
void L_CODE8_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE8_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE8");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(508);
	}
}

//
// Logic CODE9
// 
void L_CODE9_SetupObj()
{
	int light = Map_AddLight(0, 0, 1.0f, 10, 255, 0, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_CODE9_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Player_AddItem("CODE9");
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(509);
	}
}

//
// Logic PLANS
// 
void L_PLANS_SetupObj()
{
	int light = Map_AddLight(0, 0, 0, 10, 255, 64, 0);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_PLANS_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 7.0f )
	{
		Player_AddItem("PLANS");
		System_GoalItem(0);
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(400);
	}
}

//
// PHRIK
//
void L_PHRIK_SetupObj()
{
	int light = Map_AddLight(0, 0, 0, 10, 255, 64, 0);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_PHRIK_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 7.0f )
	{
		Player_AddItem("PHRIK");
		System_GoalItem(0);
		Obj_Delete();
		Map_RemoveLight( Obj_GetLocalVar(0) );
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(401);
	}
}

//
// DT_WEAPON
//
void L_DT_WEAPON_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_DT_WEAPON_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
}

void L_DT_WEAPON_SendMsg()
{
	switch (obj_uMsg)
	{
		case MSG_PICKUP:
			Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
			Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
			
			Player_AddItem("DT_WEAPON");
			System_GoalItem(0);
			Obj_Delete();
			
			Sound_Play2D("BONUS.VOC");
			System_PrintIndex(405);
		break;
	}
}

//
// NAVA
//
void L_NAVA_SetupObj()
{
	int light = Map_AddLight(0, 0, 0, 10, 64, 64, 255);
	Obj_SetLocalVar(0, light);
	Obj_AttachLight(light);
}

void L_NAVA_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 7.0f )
	{
		Player_AddItem("NAVA_CARD");
		System_GoalItem(0);
		Map_RemoveLight( Obj_GetLocalVar(0) );
		Obj_Delete();
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(402);
	}
}

//
// PILE
//
void L_PILE_Update()
{
	if ( Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 7.0f )
	{
		Player_AddItem("PILE");
		System_GoalItem(0);
		Map_RemoveLight( Obj_GetLocalVar(0) );
		Obj_Delete();
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(312);
	}
}

//
// DATATAPE
//
void L_DATATAPE_SetupLogic()
{
	Logic_AddMsgMask(MSG_PICKUP);
}

void L_DATATAPE_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PICKUP);
	obj_Radius = 4.0f;
	obj_Height = 1.0f;
}

void L_DATATAPE_Update()
{
	if ( Obj_IsFlagSet(OFLAGS_COLLIDE_PLAYER) != 0 && Obj_GetSqrDistFromPlayer() < obj_Radius*obj_Radius && Obj_GetHeightDistFromPlayer() < 6.0f )
	{
		Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
		Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
		
		Player_AddItem("DATATAPE");
		System_GoalItem(1);
		Obj_Delete();
		
		Sound_Play2D("BONUS.VOC");
		System_PrintIndex(405);
	}
}

void L_DATATAPE_SendMsg()
{
	if ( Obj_IsFlagSet(OFLAGS_COLLIDE_PLAYER) != 0 )
	{
		switch (obj_uMsg)
		{
			case MSG_PICKUP:
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PICKUP);
				
				Player_AddItem("DATATAPE");
				System_GoalItem(1);
				Obj_Delete();
				
				Sound_Play2D("BONUS.VOC");
				System_PrintIndex(405);
			break;
		}
	}
}

/**************MISC************/
//
// Logic UPDATE
// 
void L_UPDATE_Update()
{
	obj_Yaw += Obj_GetLocalVar(1);
}

//
// SCENERY
//
void L_SCENERY_SetupLogic()
{
	Logic_AddMsgMask(MSG_NRML_DAMAGE);
	Logic_AddMsgMask(MSG_MELEE_DAMAGE);
}

void L_SCENERY_SetupObj()
{
	Obj_SetFlag(OFLAGS_COLLIDE_PLAYER);
	Obj_SetFlag(OFLAGS_COLLIDE_PROJECTILE);
	Obj_SetFlag(OFLAGS_COLLIDE_OBJECTS);
	
	obj_Action = 0;
	obj_Radius = 2.0f;
	obj_Height = 10.0f;
	
	int light = -1;
	if ( Obj_CompareName("REDLIT") )
	{
		light = Map_AddLight(0, 0, 0, 20, 255, 0, 0);
		obj_FrameDelay = 5;
	}
	else if ( Obj_CompareName("TALLIT1") )
	{
		light = Map_AddLight(0, 0, 0, 20, 64, 96, 128);
	}
	else if ( Obj_CompareName("LIT1") || Obj_CompareName("LIT2") )
	{
		light = Map_AddLight(0, 0, 0, 20, 64, 96, 128);
	}
	else if ( Obj_CompareName("ICEILIT2") )
	{
		light = Map_AddLight(0, 0, 0, 8, 64, 96, 128);
		Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
		Obj_ClearFlag(OFLAGS_COLLIDE_OBJECTS);
	}

	Obj_SetLocalVar(0, light);	
	if ( light > -1 )	
	{
		Obj_AttachLight(light);
	}
}

void L_SCENERY_SendMsg()
{
	if ( obj_Action == 1 ) { return; }
	switch (obj_uMsg)
	{
		case MSG_NRML_DAMAGE:
				obj_Action = 1;
				obj_Frame = 0;
				obj_Delay = 15;
				obj_FrameDelay = 15;
				
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
				Obj_ClearFlag(OFLAGS_COLLIDE_OBJECTS);
				
				if ( Obj_GetLocalVar(0) > -1 )
				{
					Map_RemoveLight( Obj_GetLocalVar(0) );
					Obj_SetLocalVar(0, -1);	
				}
			break;
		case MSG_MELEE_DAMAGE:
				obj_Action = 1;
				obj_Frame = 0;
				obj_Delay = 15;
				obj_FrameDelay = 15;
				
				Obj_ClearFlag(OFLAGS_COLLIDE_PLAYER);
				Obj_ClearFlag(OFLAGS_COLLIDE_PROJECTILE);
				Obj_ClearFlag(OFLAGS_COLLIDE_OBJECTS);
				
				if ( Obj_GetLocalVar(0) > -1 )
				{
					Map_RemoveLight( Obj_GetLocalVar(0) );
					Obj_SetLocalVar(0, -1);	
				}
			break;
	}
}
