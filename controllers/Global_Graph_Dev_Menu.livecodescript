script "Global | Graph | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Graph | Dev | Menu
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


--> Global | Graph | Dev | Menu
-
on menu_ParseDot indexView, whichDot
   put _ChooseDot (whichDot) into dotText
   put dot_CreateArray (dotText) into dotArray
   --
   dot_CreateGraphStack dotArray
   put the result into dotGroup
   --
   dotArray_CreateEdges dotArray, dotGroup
   dotArray_CreateObjects dotArray, dotGroup
   
   -- check
   put dotArray_BackgroudRect (dotArray) into bbRect
   get the rect of dotGroup
   if it is not bbRect then
      -- should tolerate rouding errors
      breakpoint
   end if
end menu_ParseDot

on menu_Shapes
   put "https://graphviz.org/Gallery/gradient/colors.gv.txt" into dotURL
   --
   display_DotUrl dotURL
   --
   put _FetchText (dotURL, "plain")
end menu_Shapes

private on _
end _

on menu_DefSection gView
   put the dot_DefSection of gView into defSection
   put defSection
end menu_DefSection

on menu_LinkArray gView
   put the link_Array of gView into linkArray
   put the module_AssetFolder of gView into aFolder
   put aFolder & "linkArray.dot" into dotFile
   --
   put the dot_DefSection of gView into defSection
   put "white" into gColour
   display_LinkArrayGraph linkArray, "spring", dotFile, gColour, "LinkArray", defSection
end menu_LinkArray
