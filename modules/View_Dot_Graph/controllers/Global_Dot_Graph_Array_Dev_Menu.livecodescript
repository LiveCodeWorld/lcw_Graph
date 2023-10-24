script "Global | Dot | Graph | Array | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dot | Graph | Array | Dev | Menu
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
   return the display_View of tObject
end menu_Target


--> Global | Dot | Graph | Array | Dev | Menu
-
on menu_HeaderSection displayView
   put the displayed_Data of displayView into dotArray
   put dotArray_HeaderSection (dotArray)
end menu_HeaderSection

on menu_NodeSection displayView
   put the displayed_Data of displayView into dotArray
   put dotArray_ConstructNodeSection (dotArray)
end menu_NodeSection

private on _
end _

on menu_NodeShape gridView, defaultShape
   put "World" into linkArray ["Hello"]
   put "World" into linkArray ["Another"]
   put "Green" into linkArray ["World"]
   --
   put "Test Graph" into gTitle
   dotArray_Construct linkArray, dotArray, "fdp", gTitle, defaultShape
   put the result into dotText
   --
   display_GraphFromDotArray dotArray, dotText
   --
   display_DotArray dotArray
   display_DotText dotText, gTitle
end menu_NodeShape

on menu_TestCoda graphView
   display_MotiGraph
end menu_TestCoda

on menu_DotArrayJson displayView
   put the displayed_Data of displayView into dotArray
   put json_FromArray (dotArray, false, true) into dotText
   --
   display_Text dotText, "Dot Array JSON"
end menu_DotArrayJson

on menu_ProcessSubraphs displayView
   put the displayed_Data of displayView into dotArray
   --
   put dotArray_GetSubraphArray (dotArray) into subGraphArray
   display_Data subGraphArray, "subGraphArray"
end menu_ProcessSubraphs


