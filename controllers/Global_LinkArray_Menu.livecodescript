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
on menu_Init tObject
   -- called only once for top menu
   pass menu_Init
end menu_Init

getprop menu_Target [tObject]
   -- called once for each menu
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

on menu_TestFile
   answer file "Choose..."
   put it into dotFile
   if dotFile is empty then exit to top
   --
   put dot_DoShell (dotFile, "dot", "json") into dotJSON
   if word 1 of dotJSON = "Warning:" then
      delete line 1 of dotJSON
   end if
   --
   -- put json_ToArray (dotJSON) into dotArray
   put JsonImport (dotJSON) into dotArray
   
   if dotArray is not an array then
      breakpoint
   end if
   --
   display_GraphFromDotArray dotArray
   display_DotArray dotArray
end menu_TestFile

on _
end _

-- on submenu_CreateGraph
return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph

-- on submenu_Filter
return "Global | HkeyArray | Tree | Filter | Menu"
end submenu_Filter

-- on submenu_Deps
return "Global | HkeyArray | Tree | Deps | Menu"
end submenu_Deps

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

on menu_LexonLinkArrayGraph displayView
   put "fast undirected spring" into graphStyle
   --
   put the displayed_Array of displayView into linkArray
   --
   put the project_AssetFolder of stack "lcw_Lexon" into projectAssetFolder
   put projectAssetFolder & "contract.dot" into dotFile
   --
   put lexon_ConstructGroupStyleArray (dData) into dotGroupStyleArray
   put dot_ConstructDefSection (dotGroupStyleArray, linkArray) into defSection
   put empty into pDefSection
   --
   delete variable linkArray ["GENERAL: definitions."]
   --
   display_LinkArrayGraph linkArray, graphStyle, dotFile, "lightblue", "LinkArray", pDefSection
end menu_LexonLinkArrayGraph


