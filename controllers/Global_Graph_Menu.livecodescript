script "Global | Graph | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Graph | Menu
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
   -- return display_MenuTarget(tObject)
   return the graph_View of tObject
end menu_Target

getprop graphDotArray_Params
   return dot_ListGraphStyles()
end graphDotArray_Params

getprop checked_StripPositions
   return LocalArray ["StripPositions"] is true
end checked_StripPositions

getprop checked_StripBoundingBox
   return LocalArray ["BoundingBox"] is true
end checked_StripBoundingBox


--> Global | Graph | Menu
-
on menu_GraphDotArray gView, graphStyle   
   put LocalArray ["StripPositions"] is true into removePos
   put the graph_DotArray of gView into dotArray
   put dot_FromArray (dotArray, removePos) into dotText
   --
   display_DotTextSvg dotText, empty, graphStyle
   put the result into dView
   put the dot_File of dView
end menu_GraphDotArray

on menu_DisplayDotArray gView
   put the graph_DotArray of gView into dotArray
   --
   put the dot_File of gView into dotFile
   display_DotArray dotArray, dotFile
end menu_DisplayDotArray

private on _
end _

on menu_StripPositions displayView, sBoolean
   put LocalArray ["StripPositions"] is false into LocalArray ["StripPositions"]
end menu_StripPositions

on menu_StripBoundingBox displayView, sBoolean
   put LocalArray ["BoundingBox"] is false into LocalArray ["BoundingBox"]
end menu_StripBoundingBox

private on __
end __

on submenu_DotArray
   return "Global | DotArray | Menu"
end submenu_DotArray

on submenu_Dev
   return menu_DevTitle ("Global | Graph | Menu")
end submenu_Dev
