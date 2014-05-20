#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

#include mod\_button_monitoring;
#include mod\_permissions;
#include mod\_menu_sys;

//	add eventually...
//self printf( "Welcome, %1 to the %2", self.name, "Lobby!" );

init()
{
	//shaders
    foreach( shader in strTok( "menu_button_selection_bar,gradient_fadein_fadebottom", ",") )
        precacheShader( shader );
		
	//set variables...
	level.allowMovement = true; //set this to false in another gametype if you would like to disallow free-movement in mod menus
	level.numTextCache = 0; //the number of settexts used in menu. (map_restart if this > total_allowed)
	
	level.test = 0; //DELETE THIS... FOR DEBUGING ONLY
	
	//editable dvars
	level.jumpHeight = "Default";
	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player thread initButtons();
		player thread menu_init();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
	}
}
