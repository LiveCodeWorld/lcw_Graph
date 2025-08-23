script "Global | ixOS | Arc | Dev | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ixOS | Arc | Dev | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/


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

getprop disabled_EdgeArray [gView]
   return exists (the arrow_View of gView) is false
end disabled_EdgeArray


--> Global | ixOS | Arc | Dev | Menu
-
on menu_DisplayArrowData aView
   put the arrow_Data of aView into aData
   display_Data aData, "arrow_Data"
end menu_DisplayArrowData

on menu_EdgeArray gView
   put the dot_EdgeArray of gView into edgeArray
   display_Array edgeArray, "dot_EdgeArray"
end menu_EdgeArray

private command _
end _

on menu_Points aView
   -- 6,4 with arrow lineSize 1
   -- 1 -- without arrows lineSize 1
   -- 6,6 -- without arrows lineSize 10
   
   -- relativepoints --12,12 linesize 1
   
   get the rect of aView
   put the relativepoints of aView into rPoints
   put the width of aView into aWidth
   put the height of aView into aHeight
   
   put line 1 of rPoints into sPoint
   put item 1 of sPoint into sLeftR
   put item 2 of sPoint into sTopR
   put line -1 of rPoints into ePoint
   put item 1 of ePoint into eLeftR
   put item 2 of ePoint into eTopR
   --
   put eLeftR - sLeftR into rWidth
   put eTopR - sTopR into rHeight
   --
   put CR & aWidth && aHeight after it
   put CR & rWidth && rHeight after it
   put CR & (aWidth - rWidth) && (aHeight - rHeight) after it
   --
   put CR&CR & the points of aView after it
   put CR&CR & rPoints after it
   put it
end menu_Points

on menu_InitPoints aView
   -- Pitch Work,top - Moti JV,b23
   set the from_Items ["Pitch Work"] of aView to "top"
   set the to_Items ["Moti JV"] of aView to "b,2,3"
   --
   put the arrow_Data of aView into aData
   display_Data aData, "arrow_Data"
   --
   dispatch "LayoutControl" to aView
end menu_InitPoints

on menu_SetPointsLink aView
   get the lockmessages
   put the arrow_NameLink of aView into nameLink
   put "Pitch Work,top - Moti JV,b,2,3" into nameLink
   --  put the short name of aView into nameLink
   set the arrow_PointLink of aView to nameLink
end menu_SetPointsLink

on menu_ArrowNameLink aView
   put the arrow_NameLink of aView into nameLink
   put nameLink
end menu_ArrowNameLink

private command __
end __

on menu_EditBehavior aView
   put the behavior of aView into bObject
   edit the script of bObject
end menu_EditBehavior
