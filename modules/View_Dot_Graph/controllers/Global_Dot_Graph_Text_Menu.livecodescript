script "Global | Dot | Graph | Text | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Dot | Graph | Text | Menu
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
   put the display_View of tObject into LocalArray ["displayView"]
   put the displayed_Object of tObject into graphView
   return graphView
end menu_Target

private function _GetDotText
   put LocalArray ["displayView"] into displayView
   put the displayed_Text of displayView into dotText
   return dotText
end _GetDotText


--> Global | Dot | Graph | Text | Menu
-
on menu_AddSize graphView
   put _GetDotText() into dotText
   --
   put dot_GraphInchSize (the screenrect, true) into inchSizes
   dot_SetGraphSize dotText, inchSizes
   --
   display_Text dotText 
end menu_AddSize

on menu_RenderDot graphView
   put _GetDotText() into dotText
   --
   put the view_RectOnCard of graphView into gRect
   set the dot_Text [gRect] of graphView to dotText
end menu_RenderDot

on menu_ClearGraph graphView
   set the dot_Text of graphView to empty
   -- set the dot_Array of graphView to empty
end menu_ClearGraph

on _
end _

on submenu_Tools
   return "Global | Dot | Graph | Tools | Menu"
end submenu_Tools

on menu_FetchDotFromImage displayView
   put the graph_View of displayView into graphView
   put the dot_Text of graphView into dotText
   --
   set the displayed_Text of displayView to dotText
end menu_FetchDotFromImage

on menu_DisplayGraphView graphView
   object_GoTo graphView
end menu_DisplayGraphView

on menu_DiplayBehavior
   put LocalArray ["displayView"] into displayView
   put the behavior of displayView into bObject
   edit the behavior of bObject
end menu_DiplayBehavior
