script "Global | Dot | Edge | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dot | Edge | Dev | Menu
type: controller
author: David Bovill
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


--> Global | Dot | Edge | Dev | Menu
-
on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

private on _
end _

on menu_OriginalPoints edgeGraphic
   put the edge_OriginalPoints of edgeGraphic into edgePoints
   put edgePoints
end menu_OriginalPoints

on menu_Points edgeGraphic
   put the points of edgeGraphic
end menu_Points

on menu_ScaledPoints edgeGraphic
   put the edge_ScaledPoints of edgeGraphic into edgePoints
   set the points of edgeGraphic to edgePoints
   put edgePoints
end menu_ScaledPoints

on menu_LinkObjects edgeGraphic
   put the from_Object of edgeGraphic & CR & the to_Object of edgeGraphic
end menu_LinkObjects
