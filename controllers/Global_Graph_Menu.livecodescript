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

--> Global | Graph | Menu
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

-- on menu_CreatePresentationStack indexView, whichDot
put _ChooseDot (whichDot) into dotText
put dot_CreateArray (dotText) into dotArray
--
dot_CreateGraphStack dotArray
end menu_CreatePresentationStack

on menu_Shapes
   put "https://graphviz.org/Gallery/gradient/colors.gv.txt" into dotURL
   --
   display_DotUrl dotURL
   --
   put _FetchText (dotURL, "plain")
end menu_Shapes
