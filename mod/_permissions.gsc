#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

OPERATOR = 4; //ie: host
ADMINISTRATOR = 3;
VIP = 2;
ACCESS = 1;
NONE = 0;


access_init()
{
	if(self isHost())
		self.menu_access = OPERATOR;
	else
		self.menu_access = NONE;
}

canAccessMenu()
{
	return (self.menu_access > NONE);
}

canAccess( status )
{
	return (self.menu_access >= status);
}
