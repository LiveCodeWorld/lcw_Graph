script "Global | Node | Graphic | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Node | Graphic | Dev | Menu
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
   -- return display_MenuTarget(tObject)
   return the graph_Node of tObject
end menu_Target


--> Global | Node | Graphic | Dev | Menu
-
on menu_LayoutArrows nodeView
   dispatch "LayoutArrows" to nodeView
end menu_LayoutArrows

private on _
end _

on menu_ResizeFont gView
   -- put the formattedwidth of gView &CR& the width of gView
end menu_ResizeFont

on menu_TestGeometry gView
   get the loc of gView
   put item 1 of it into centreX
   subtract the left of gView from centreX
   put dot_PixelsToPoints (centreX)
   
   exit to top
   
   put the properties of gView into propArray
   put propArray ["rect"] into sRect
   put dot_GraphInchSize (sRect) into rectPos
   
   put the dot_ObjectArray of gView into objectArray
   put objectArray ["pos"] into realPos
   
   put the node_Pos of gView into nodePos
   
   put realPos &CR& rectPos &CR& the loc of gView &CR& nodePos
end menu_TestGeometry

on menu_DotObjectArray sNode
   put the dot_ObjectArray of sNode into objectArray
   display_Data objectArray,  the name of sNode, "dot_ObjectArray"
   --
   -- put the dot_ObjectArray of sNode into objectArray
end menu_DotObjectArray
