script "Global | Dot | Graph | Text | Menu"
--> MetaData
-
copyright: David Bovill
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
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   put the displayed_Object of displayView into graphView
   return graphView
end menu_Target

private function _GetDotText
   put LocalArray ["displayView"] into displayView
   put the displayed_Text of displayView into dotText
   return dotText
end _GetDotText


--> Global | Dot | Graph | Text | Menu
-
on submenu_Save
   return "Global | Dot | Save | Menu"
end submenu_Save

private on _
end _

on menu_AddSize indexView
   put _GetDotText() into dotText
   --
   put dot_GraphInchSize (the screenrect, true) into inchSizes
   -- dot_SetGraphSize dotText, inchSizes
   --
   put word 2 of dotText into gTitle
   display_DotText dotText, gTitle
end menu_AddSize

on menu_RenderDot graphView
   put _GetDotText() into dotText
   --
   set the dot_Text of graphView to dotText
end menu_RenderDot

on menu_ClearGraph graphView
   set the dot_Text of graphView to empty
   -- set the dot_Array of graphView to empty
end menu_ClearGraph

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Dot | Graph | Text | Menu")
end submenu_Dev
