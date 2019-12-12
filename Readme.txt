The process of uploading the code has begun and will continue until the Beta is released. 
My current source organization is a little messy, so I'm reorganizing the project files as I upload.
 This means the actual solution files for Microsoft Visual Studio will be the last files uploaded, 
when I rebuild the project using the improved layout. I'll also continue to update this readme as 
I go through this process.

Note that this repository will be read only for the forseeable future, however there will be a 
system setup for code submissions once everything is in place. I will maintain control of the 
repository and project for now, though all the code will be GPL.

--lucius


Source organization, only files uploaded so far (+ = main folder, - = subfolder):

+Engine
Core DarkXL engine files, includes systems such as Rendering, UI, Math, the OS layer and 
so on.

-Console
Engine drop-down console classes.

-Math
Core math library.

-Sound
Core sound system and sound file loaders.


+Game_Shared
Game functionality that is shared across all supported games. This allows for game 
systems, such as weapons, to be shared as much as possible.


+Game_DarkForces
Game functionality that is unique to Dark Forces.

-ScriptFiles
Scripts used for Dark Forces, including Logics, AI, Pickups, Weapon Scripts and so on.


+Game_Blood
Game functionality that is unique to Blood.


+Game_Outlaws
Game functionality that is unique to Outlaws.


... More to come as more of the project files are uploaded ...