#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

#include mod\_button_monitoring;
#include mod\_permissions;
#include mod\_ui;
#include mod\_utils;
#include mod\_funcs;

//menu types
MENU_OPEN = 0;
MENU_AUTO = 1; //auto regenerate.. only needed for players menu

//types
TYPE_EXEC = 0; //just execute like a regular function
TYPE_MENU = 1; //this is a menu (aka submenu), just open it
TYPE_BOOL = 2; //on or off...
TYPE_MULT = 3; //array... multiple items.. "Low", "Medium", "High"
TYPE_MOVE = 4; //movable slider.. not implemented yet.

//menu related stuff
MENU_WIDTH = 480;
MENU_MAX_ITEMS = 18;

loadMenus()
{
	if(self canAccessMenu())
	{
		if(self canAccess(4))
		{
			//host shit..
		}
		
		self createMenu( 1, 0, "Main Menu" );
		
		self addOption( 1, 0, "test #1", TYPE_EXEC, ::test, "test #1" );
		self addOption( 1, 1, "Sub Menu Click", TYPE_MENU, ::open_Menu, 2);
		self addOption( 1, 2, "level.test", TYPE_BOOL, ::test2, level.test );
		self addOption( 1, 3, "Jump Height", TYPE_MULT, ::test3, level.jumpHeight, "Default,Medium,High" );
		
		self createMenu( 2, 1, "Sub Menu Test" );
		self addOption( 2, 0, "test #2", TYPE_EXEC, ::test, "Test #2" );
	}
	else
	{
		self.menus = []; //empty out the array...
	}
}

createMenu( id, parent, title, type )
{
	self.menus[id] = spawnstruct();
	self.menus[id].id = id;
	self.menus[id].parent = parent;
	self.menus[id].title = title;
	self.menus[id].items = [];
	self.menus[id].type = MENU_OPEN;
	
	if(isDefined(type))
		self.menus[id].type = type;
}

addOption( menuid, index, title, type, function, argument, delimeters)
{
	self.menus[menuid].items[index] = spawnstruct();
	self.menus[menuid].items[index].title = title;
	self.menus[menuid].items[index].type = type;
	self.menus[menuid].items[index]._arg = "";
	self.menus[menuid].items[index].func = ::test;
	self.menus[menuid].items[index].exec = self;
	
	if(isDefined(function))
		self.menus[menuid].items[index].func = function;
	
	if(isDefined(argument))
		self.menus[menuid].items[index]._arg = argument;
		
	if(isDefined(delimeters))
		self.menus[menuid].items[index].delims = delimeters; //array (seperated by ',') which value has to fall in between
}

test( arg )
{
	if(!isDefined(arg))
		arg = "test";
	self iprintlnbold( arg );
}

open_Menu( id )
{
	self notify("menu_enter");
	
	self.menu_id = id;
	self.menu_mult_open = false;
	self updateMenuDisplay();
	
	//update the bar position
	self.menu_scroll = 0;		
	self.menu_hud["bar"] setPos( "left_adjustable", "top_adjustable", "left_adjustable", "top_adjustable", -15, (self.menu_scroll * 20) + 62 );
}

createMenuHud()
{
	self.menu_hud["bar"] 	= createShader( "left_adjustable", "top_adjustable", "left_adjustable", "top_adjustable", -15, 62, 326, 20, "menu_button_selection_bar", (0,0,0), 1, 1);
	self.menu_hud["bg"] 	= createShader( "left_adjustable", "FULLSCREEN", "left_adjustable", "FULLSCREEN", -15, 0, 280, 480, "gradient_fadein_fadebottom", (0,0,0), .7, 2);
}

destroyMenuHud()
{
	self.menu_hud["bar"] destroy();
	self.menu_hud["bg"] destroy();
	self.menu_hud["title"] destroy();
	for(i=0;i<MENU_MAX_ITEMS;i++)
		self.menu_hud["text"][i] destroy();
	for(i=0;i<MENU_MAX_ITEMS;i++)
		self.menu_hud["text_sub"][i] destroy();
}

updateMenuDisplay()
{
	self.menu_hud["title"] = self createFontString( "hudBig", 1.2 );
    self.menu_hud["title"] setPos( "left_adjustable", "top_adjustable", "right", "top_adjustable", 260, 32);
    self.menu_hud["title"] setText( self.menus[self.menu_id].title );
    self thread destroyOnAny( self.menu_hud["title"], "menu_enter", "menu_close" );
	
	level.numTextCache++;
	
	for( i = 0; i < self.menus[self.menu_id].items.size; i++ )
	{
		self.menu_hud["text"][i] = self createFontString( "default", 1.6 );
        self.menu_hud["text"][i] setPos( "left_adjustable", "top_adjustable", "right", "top_adjustable", 260, (i * 20) + 62);
		self.menu_hud["text"][i].sort = 2;
		
		self.menu_hud["text"][i] setText( self.menus[self.menu_id].items[i].title );
		
		self thread destroyOnAny( self.menu_hud["text"][i], "menu_enter", "menu_close" );
		
		if( self.menus[self.menu_id].items[i].type == TYPE_BOOL || self.menus[self.menu_id].items[i].type == TYPE_MULT )
		{
			self.menu_hud["text_sub"][i] = self createFontString( "default", 1.6 );
			self.menu_hud["text_sub"][i] setPos( "left_adjustable", "top_adjustable", "left", "top_adjustable", 290, (i * 20) + 62);
			self.menu_hud["text_sub"][i].sort = 2;
			
			if(self.menus[self.menu_id].items[i].type == TYPE_BOOL)
				self.menu_hud["text_sub"][i] setText( "[" + boolean(self.menus[self.menu_id].items[i]._arg) + "]");
			else if(self.menus[self.menu_id].items[i].type == TYPE_MULT)
				self.menu_hud["text_sub"][i] setText( self.menus[self.menu_id].items[i]._arg );
			
			self thread destroyOnAny( self.menu_hud["text_sub"][i], "menu_enter", "menu_close" );
			
			level.numTextCache++;
		}
		
		level.numTextCache++;
	}
}

menu_init()
{
    self endon( "disconnect" );
	
    self.menu_open = false;
    self.menu_id = 1;
	self.menu_mult_open = false;
	
	self access_init();
	
    while(1)
    {
		self loadMenus(); //load menus you can access every frame update.
	
        if(!self.menu_open && self canAccessMenu())
        {
            if(self isButtonPressed("+actionslot 1"))
            {
				self.menu_id = 1;
                self.menu_open = true;
				if(level.allowMovement)
					self freezeControls(true);
				
				//create menus & load default "main"
				self createMenuHud();
				self open_Menu( self.menu_id );
				
            }
        }
        else if(self.menu_open && self canAccessMenu())
        {
            if(self isButtonPressed("+actionslot 1"))
            {
				self.menu_scroll--;
				if(self.menu_scroll < 0)
					self.menu_scroll = 0;
				
				self.menu_hud["bar"] setPos( "left_adjustable", "top_adjustable", "left_adjustable", "top_adjustable", -15, (self.menu_scroll * 20) + 62 );
                //self playLocalSound( "mouse_over" );
            }
            else if(self isButtonPressed("+actionslot 2"))
            {
				self.menu_scroll++;
				if(self.menu_scroll > self.menus[self.menu_id].items.size - 1)
					self.menu_scroll = self.menus[self.menu_id].items.size - 1;
				
				self.menu_hud["bar"] setPos( "left_adjustable", "top_adjustable", "left_adjustable", "top_adjustable", -15, (self.menu_scroll * 20) + 62 );
            }
            else if(self isButtonPressed("+stance"))
            {
				if(self.menus[self.menu_id].parent == 0)
				{
					self.menu_id = 0;
					self.menu_open = false;
					self destroyMenuHud();
					
					if(level.allowMovement)
						self freezeControls(false);
				}
				else
				{
					self open_Menu( self.menus[self.menu_id].parent );
				}
            }
            else if(self isButtonPressed("+gostand"))
            {
				switch( self.menus[self.menu_id].items[self.menu_scroll].type )
				{
					case 1: //TYPE_MENU:
						self open_Menu( self.menus[self.menu_id].items[self.menu_scroll]._arg );
					break;
					
					case 2: //TYPE_BOOL:
						self [[self.menus[self.menu_id].items[self.menu_scroll].func]](self.menus[self.menu_id].items[self.menu_scroll]._arg); //exec the func relating to bool...
						
						//this is the 'bool' actual value of toggled variable will be replaced in above function ^^
						self.menus[self.menu_id].items[self.menu_scroll]._arg = !self.menus[self.menu_id].items[self.menu_scroll]._arg;
						
						//after swapping values from above function ^^^, update text.
						self notify("menu_update");
						self.menu_hud["text_sub"][self.menu_scroll] setText( "[" + boolean(self.menus[self.menu_id].items[self.menu_scroll]._arg) + "]");
						level.numTextCache++;
					break;
					
					case 3: //TYPE_MULT:
					
						delims = strTok( self.menus[self.menu_id].items[self.menu_scroll].delims, "," );
					
						//create menu display + text
						self.menu_hud["text_sub"][self.menu_scroll].alpha = 0;
						self.menu_hud["mult_bg"] = createShader( "left_adjustable", "top_adjustable", "left", "top_adjustable", 287, (self.menu_scroll * 20) + 62, 145, delims.size * 20, "black", (0,0,0), .7, 3);
						self.menu_hud["mult_bar"] = createShader( "left_adjustable", "top_adjustable", "left", "top_adjustable", 287, (self.menu_scroll * 20) + 62, 145, 20, "black", (0,0,0), 1, 4);
						
						for( i = 0; i < delims.size; i++ )
						{
							self.menu_hud["delims"][i] = self createFontString( "default", 1.6 );
							self.menu_hud["delims"][i] setPos( "left_adjustable", "top_adjustable", "left", "top_adjustable", 290, (i * 20) + (self.menu_scroll * 20) + 62);
							self.menu_hud["delims"][i].sort = 3;
		
							self.menu_hud["delims"][i] setText( delims[i] );
							
							self thread destroyOnAny( self.menu_hud["delims"][i], "mult_menu_exit" );
							
							level.numTextCache++;
						}
						
						
						//get return value from mult menu
						returnVal = openMultMenu( self.menus[self.menu_id].items[self.menu_scroll]._arg, delims );
						
						//update menu display of newly changed item.
						self.menu_hud["text_sub"][self.menu_scroll].alpha = 1;
						self.menu_hud["mult_bg"] destroy();
						self.menu_hud["mult_bar"] destroy();
						self.menu_hud["text_sub"][self.menu_scroll] setText( returnVal );
						level.numTextCache++;
						
						self.menus[self.menu_id].items[self.menu_scroll]._arg = returnVal;
						
						self thread [[self.menus[self.menu_id].items[self.menu_scroll].func]](returnVal);
					
					break;
					
					case 4: //TYPE_MOVE:
					
					break;
					
					case 0: //TYPE_EXEC:
					default:
						self thread [[self.menus[self.menu_id].items[self.menu_scroll].func]](self.menus[self.menu_id].items[self.menu_scroll]._arg);
					break;
				}
            }
        }
		else
		{
			self destroyMenuHud();
		}
		
        waitframe();
    }
}

openMultMenu(value, delims)
{
	self.mult_menu_scroll = index_of( value, delims );
	self.menu_hud["mult_bar"] setPos( "left_adjustable", "top_adjustable", "left", "top_adjustable", 287, (self.menu_scroll * 20) + (self.mult_menu_scroll * 20) + 62, 145, 20 );
	
	while(1)
	{
		if(self isButtonPressed("+actionslot 1"))
		{
			self.mult_menu_scroll--;
			if(self.mult_menu_scroll < 0)
				self.mult_menu_scroll = 0;
			
			self.menu_hud["mult_bar"] setPos( "left_adjustable", "top_adjustable", "left", "top_adjustable", 287, (self.menu_scroll * 20) + (self.mult_menu_scroll * 20) + 62, 145, 20 );
		}
		else if(self isButtonPressed("+actionslot 2"))
		{
			self.mult_menu_scroll++;
			if(self.mult_menu_scroll > delims.size - 1)
				self.mult_menu_scroll = delims.size - 1;
			
			self.menu_hud["mult_bar"] setPos( "left_adjustable", "top_adjustable", "left", "top_adjustable", 287, (self.menu_scroll * 20) + (self.mult_menu_scroll * 20) + 62, 145, 20 );
		}
		else if(self isButtonPressed("+stance"))
		{
			self notify("mult_menu_exit");
			return value;
		}
		else if(self isButtonPressed("+gostand"))
		{
			self notify("mult_menu_exit");
			return delims[self.mult_menu_scroll];
		}
		
		waitframe();
	}
}
