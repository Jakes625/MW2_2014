#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

test2()
{
	level.test = !level.test;
	
	self iPrintLnBold( level.test );
}

test3(arg)
{
	level.jumpHeight = arg;
	var = 45;
	switch( arg )
	{
		case "High":
			var = 999;
		break;
		case "Medium":
			var = 250;
		break;
		case "Default":
			var = 45;
		break;
	}
	setdvar( "jump_height", var );
}
