script "Global | LinkArray | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | LinkArray | Dev | Menu
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


--> Global | LinkArray | Dev | Menu
-
on menu_TestFile
   answer file "Choose..."
   put it into dotFile
   if dotFile is empty then exit to top
   --
   gv_DoShell dotFile, "dot", "json"
   put the result into dotJSON
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

private command _
end _

on submenu_CreateGraph
return "Global | Tree | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph

on submenu_Filter
return "Global | HkeyArray | Tree | Filter | Menu"
end submenu_Filter

on submenu_Deps
return "Global | HkeyArray | Tree | Deps | Menu"
end submenu_Deps

private command __
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

