#include "CoreWeaponsInc.as"
#include "CoreWeapons_Fist.as"
#include "CoreWeapons_Pistol.as"
#include "CoreWeapons_Rifle.as"
#include "CoreWeapons_TD.as"
#include "CoreWeapons_Repeater.as"
#include "CoreWeapons_Fusion.as"
#include "CoreWeapons_Mine.as"
#include "CoreWeapons_Mortar.as"
#include "CoreWeapons_Concussion.as"
#include "CoreWeapons_Cannon.as"

//Weapon Scripts ENTRY POINT.
//This function sets up all the weapons and setups up all callbacks.
void Weapon_RegisterAll()
{
	//FISTS - File: CoreWeapons_Fist.as
	Fist_Setup();
		
	//BRYAR PISTOL - File: CoreWeapons_Pistol.as
	Pistol_Setup();
	
	//STORMTROOPER RIFLE - File: CoreWeapons_Rifle.as
	Rifle_Setup();
	
	//THERMAL DETONATOR - File: CoreWeapons_TD.as
	TD_Setup();
	
	//IMPERIAL REPEATER - File: CoreWeapons_Repeater.as
	Repeater_Setup();
	
	//FUSION CUTTER - File: CoreWeapons_Fusion.as
	Fusion_Setup();
	
	//LAND MINE - File: CoreWeapons_Mine.as
	Mine_Setup();
	
	//MORTAR LAUNCHER - File: CoreWeapons_Mortar.as
	Mortar_Setup();
	
	//CONCUSSION RIFLE - File: CoreWeapons_Concussion.as
	Concussion_Setup();
		
	//CANNON - File: CoreWeapons_Cannon.as
	Cannon_Setup();
}
