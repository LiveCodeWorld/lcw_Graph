script "Global | IxOS | Arc | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | IxOS | Arc | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   return the arrow_View of tObject
end menu_Target

getprop menu_CheckTarget [aView]
   return exists (aView)
end menu_CheckTarget

getprop checked_StartArrow [aView]
   return the startArrow of aView
end checked_StartArrow

getprop checked_EndArrow [aView]
   return the endArrow of aView
end checked_EndArrow

getprop checked_BallStopped [aView]
   return the ball_Stopped of aView
end checked_BallStopped

getprop checked_FromBackground [aView]
   put the from_Object of aView into fromObject
   if exists (fromObject) is false then return empty
   return the show_Background of fromObject
end checked_FromBackground


--> Global | IxOS | Arc | Menu
-
on menu_ProperyInspector aView
   display_ObjectProperties aView
end menu_ProperyInspector

private on ___
end ___

on menu_AnimateBall aView
   put the points of aView into pathPoints
   put the card_Object of aView into cardObject
   
   set the ball_Path ["2,30"] of cardObject to pathPoints
   put the result into newBall
   --
   ball_PathAnimate newBall
end menu_AnimateBall

on menu_BallStopped aView
   put the ball_Stopped of aView into sBoolean
   set the ball_Stopped of aView to (sBoolean is false)
end menu_BallStopped

private on _
end _

on menu_LineSize aView
   put the lineSize of aView into someNum
   put lcw_Ask ("Set the linesize...", someNum) into someNum
   set the lineSize of aView to someNum
end menu_LineSize

on menu_StartArrow aView
   put the startArrow of aView into sBoolean
   set the startArrow of aView to (sBoolean is false)
end menu_StartArrow

on menu_EndArrow aView
   put the endArrow of aView into sBoolean
   set the endArrow of aView to (sBoolean is false)
end menu_EndArrow

private on __
end __

on menu_DeleteArrow aView
   lcw_Answer "Are you sure you want to delete this arrow?"
   object_Delete aView
end menu_DeleteArrow

on submenu_Dev
   return "Global | ixOS | Arc | Dev | Menu"
end submenu_Dev

on submenu_Layout
   return "Global | ixOS | Arc | Layout | Menu"
end submenu_Layout

on menu_FromBackground aView
   put the from_Object of aView into fromObject
   put the show_Background of fromObject into sBoolean
   --
   lock screen
   set the show_Chart of fromObject to (sBoolean is false)
   set the show_Table of fromObject to sBoolean
   set the show_Background of fromObject to (sBoolean is false)
   unlock screen
end menu_FromBackground

on menu_ResetFrom aView
   put the from_Object of aView into fromObject
   --
   lock screen
   set the show_Chart of fromObject to false
   set the show_Table of fromObject to false
   set the show_Background of fromObject to true
   --
   put line 1 of the points of aView into sLoc
   put rect_LocWidthHeight (sLoc, 60, 60) into newRect
   -- set the rect of fromObject to newRect
   dispatch "LayoutControl" to fromObject with newRect
   --
   unlock screen
end menu_ResetFrom
