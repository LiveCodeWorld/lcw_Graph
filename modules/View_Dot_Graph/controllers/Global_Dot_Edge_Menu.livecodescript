script "Global | Dot | Edge | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Dot | Edge | Menu
type: controller
version: 0.1

/*
on menu_EditBehavior edgeGraphic
   put the behavior of edgeGraphic into bObject
   edit the script of bObject
end menu_EditBehavior
*/


--> Variables
-
local LocalArray

--> Menu | Props
-


--> Global | Dot | Edge | Menu
-
on menu_EdgeArray edgeGraphic
   put the edge_Array of edgeGraphic into edgeArray
   display_Data edgeArray
end menu_EdgeArray

on _
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
