#include maps\mp\_utility;
#include common_scripts\utility;

initButtons()
{
 self endon( "disconnect" );
 
 self.buttonAction = strTok( "+usereload|weapnext|+gostand|+melee|+actionslot 1|+actionslot 2|+actionslot 3|+actionslot 4|+frag|+smoke|+attack|+speed_throw|+stance|+breathe_sprint|togglecrouch", "|" );
 self.buttonPressed = [];
 for( i = 0; i < self.buttonAction.size; i++ )
 {
  self.buttonPressed[self.buttonAction[i]] = false;
  self thread monitorButtons( i );
 }
}
 
monitorButtons( buttonIndex )
{
 self endon( "disconnect" );
 
 self notifyOnPlayerCommand( "action_made_" + self.buttonAction[buttonIndex], self.buttonAction[buttonIndex] );
 for( ;; )
 {
  self waittill( "action_made_" + self.buttonAction[buttonIndex] );
  self.buttonPressed[self.buttonAction[buttonIndex]] = true;
  waitframe();
  self.buttonPressed[self.buttonAction[buttonIndex]] = false;
 }
}
 
isButtonPressed( actionID )
{
 if( self.buttonPressed[actionID] )
 {
  self.buttonPressed[actionID] = false;
  return true;
 }
 else
  return false;
}
