script "Global | LinkArray | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | LinkArray | Menu
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
   return the display_View of tObject
end menu_Target


--> Global | LinkArray | Menu
-
on menu_DisplaySvgGraph displayView
   put the displayed_Array of displayView into linkArray
   --
   display_LinkArrayGraph linkArray, "fast undirected spring"
end menu_DisplaySvgGraph

on menu_DisplayCrudeGraph displayView
   local graphStyle
   put the displayed_Array of displayView into linkArray
   --
   ask file "Choose a file" with "some.dot"
   put it into sFile
   if sFile is empty then exit to top
   --
   put dotArray_FromLinkArray (linkArray, graphStyle, "Moti Graph", sFile) into dotArray
   if dotArray is not an array then
      breakpoint
   end if
   --
   display_GraphFromDotArray dotArray
   display_DotArray dotArray
end menu_DisplayCrudeGraph

on _
end _

on menu_GraphLinkArray displayView, graphStyle
   put the displayed_Array of displayView into linkArray
   
   put the result into svgFile
   --
   display_SVG svgFile, sObject
   put the result into displayView
   set the displayed_Object of displayView to sObject
end menu_GraphLinkArray

on menu_SimpleGraph displayView
   local pFile, pGraphStyle
   put the displayed_Array of displayView into linkArray
   --
   put dot_FromHkeyLinkArray (linkArray) into dotText
   dot_CreateGraph dotText, pFile, pGraphStyle
   put the result into svgFile
   --
   display_SVG svgFile
end menu_SimpleGraph

on menu_DisplaySvg scriptObject, shortSvgFile
   -- put the projectOverlay_SvgFile of scriptObject into svgFile
   put the scriptObject_SvgFile [shortSvgFile] of scriptObject into svgFile
   --
   if scriptEditor_PaneExists ("Deps") is true then
      display_ScriptEditorSvg svgFile
   else
      display_SVG svgFile
   end if
end menu_DisplaySvg

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | LinkArray | Menu")
end submenu_Dev
