#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

destroyOnAny( elem, a, b, c )
{
    if(!isDefined(a))
        a = "";
    if(!isDefined(b))
        b = "";
    if(!isDefined(c))
        c = "";
    self waittill_any(a,b,c);
    elem destroy();
}
 
createShader(point, rPoint, npoint, rnpoint, x, y, width, height, elem, colour, Alpha, sort)
{
	shader = newClientHudElem(self);
	shader.elemType = "bar";
	shader.horzAlign = point;
	shader.vertAlign = rPoint;
	shader.alignX = npoint;
	shader.alignY = rnpoint;
	shader.x = x;
	shader.y = y;
	shader.sort = sort;
	shader.alpha = Alpha;
	shader.color = colour;
	shader setShader(elem, width, height);
	return shader;
}

setPos( a, b, c, d, e, f )
{
    self.horzAlign 	= a;
    self.vertAlign 	= b;
    self.alignX    	= c;
    self.alignY 	= d;
    self.x			= e;
    self.y 			= f;
}

boolean( var )
{
	if( var == true )
		return "True";
	return "False";
}
