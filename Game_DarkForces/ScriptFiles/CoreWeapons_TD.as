//Weapon setup.
void TD_Setup()
{
	Weapon_Register(3, "Thermal Detonator");
	Weapon_IntParameter(WPARAM_START_FRAME,    0);
	Weapon_IntParameter(WPARAM_MAX_FRAME,      8);
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
	
	Weapon_IntParameter(WPARAM_AMMO_TYPE, AMMO_DETONATOR);
	Weapon_IntParameter(WPARAM_PRIM_FIRE_TYPE, WEAPON_FTYPE_THROW);			
	Weapon_IntParameter(WPARAM_PROJ_TYPE, PROJECTILE_SPRITE);
	
	Weapon_FloatParameter(WPARAM_PROJ_SPEED, 0.0f);
	Weapon_FloatParameter(WPARAM_CONE_SIZE,  0.0f);
	
	Weapon_OnFrame_CB("TD_Throw");
	Weapon_OnRender_CB("TD_OnRender");
	
	Weapon_AddFrame("THERM1.BM");
	Weapon_AddFrame("THERM2.BM");
	Weapon_AddFrame("THERM3.BM");
	Weapon_AddFrame("RHAND1.BM");
}

//Render
void TD_OnRender()
{
	weapon_FinalFrame = 0;
	weapon_FinalX = 160.0f - 48.0f*(visual_AspectScale-1.0f);
	weapon_FinalY =  56.0f;

	if ( weapon_Frame > -1 )
	{
		switch ( weapon_Frame )
		{
			case 0:
					//nothing...
					weapon_FinalY = 56.0f + 200.0f*Math_Clamp((weapon_HeldTime-0.2f)*2.0f, 0.0f, 0.35f);
				break;
			case 1:
					weapon_FinalFrame = 1;
					weapon_FinalY = 56.0f + 200.0f*Math_Clamp((weapon_HeldTime-0.2f)*2.0f, 0.0f, 0.35f);
				break;
			case 2:
					weapon_FinalFrame = 1;
					weapon_FinalY = 56.0f + 200.0f*Math_Clamp((weapon_HeldTime-0.2f)*2.0f, 0.0f, 0.35f);
				break;
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
					weapon_FinalFrame = 2;
					if ( weapon_Frame > 3 ) weapon_HeldTime = 0.0f;
				break;
			case 8:
					weapon_FinalFrame = 1;
					weapon_FinalY += 20.0f;
					weapon_HeldTime = 0.0f;
				break;
		};
	}
	else if ( weapon_HeldTime > 0.0f )
	{
		weapon_FinalY = 56.0f + 200.0f*Math_Clamp((weapon_HeldTime-0.2f)*2.0f, 0.0f, 0.35f);
	}
	if ( Player_GetAmmo(AMMO_DETONATOR) == 0 && weapon_Frame == -1 )
	{
		weapon_FinalFrame = 3;
	}
}

//Callbacks
void TD_Throw()
{
	if ( weapon_Frame == 4 )
	{
		int projHandle = Map_AddObject("FRAME", "IDET.FME", "PROJECTILE_THERMAL_DET", 0);
		//aim at the player..., compute the initial velocity based on the desired time to hit.
		float px, py, pz;
		float cx, cy, cz;
		Camera_GetDir(cx, cy, cz);
		Player_GetLoc(px, py, pz);
		
		float rx =  cy;
		float ry = -cx;
		pz = pz + 3.0f;
		px = px + rx*1.25f;
		py = py + ry*1.25f;
		float t = 0.60f;
		float fOOt = 1.0f / t;
		float fRange = 24.0f;

		if ( weapon_HeldTime > 0.0f )
		{
			float s = weapon_HeldTime * 0.5f;
			if ( s > 1.0f ) { s = 1.0f; }

			fRange = (1.0f-s)*24.0f + (s)*82.0f;
			t = (1.0f-s)*0.60f + (s)*1.0f;
			fOOt = 1.0f / t;
		}

		float dx = cx*fRange*fOOt;
		float dy = cy*fRange*fOOt;
		float dz = cz*fRange*fOOt - global_Gravity*t*0.5f;
		float vx, vy, vz;
		//now extract the direction and magnitude: fSpeed = magnitude, MoveDir = velocity direction.
		float fSpeed = Math_Normalize3D(dx, dy, dz, vx, vy, vz);
		Obj_SetSpeed_Handle(projHandle, fSpeed);
		Obj_SetMoveDir_Handle(projHandle, vx, vy, vz);
		Obj_SetLocalVar_Handle(projHandle, 12, px);
		Obj_SetLocalVar_Handle(projHandle, 13, py);
		Obj_SetLocalVar_Handle(projHandle, 14, pz);
		Obj_SetLocalVar_Handle(projHandle, 15, 0.0f);
	}
}
