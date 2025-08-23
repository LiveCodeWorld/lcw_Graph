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

private function _HkeyArray sObject
   if the shiftKey is "Down" then
      put the script_HkeyArray of sObject into hkeyArray
   else 
      put LocalArray ["dView"] into dView
      put the displayed_HkeyArray of dView into hkeyArray
   end if
   return hkeyArray
end _HkeyArray

private function _GetDisplayData dView, showHow
   put the link_Array of dView into hkeyArray
   put the displayed_Hkey of dView into hKey
   put false into stripMissingProps
   --
   put hkeyArray_DisplayData (hkeyArray, showHow, stripMissingProps, hKey) into dData
   return dData
end _GetDisplayData


--> Global | LinkArray | Menu
-
on menu_Show dView, showHow
   put _GetDisplayData (dView, showHow) into dData
   --
   set the displayed_Data of dView to dData
   set the show_How of dView to showHow
end menu_Show

getprop show_Param [dView]
   put the show_How of dView into showHow
   if showHow is empty then put "hkeyArray" into showHow
   return showHow
end show_Param

getprop show_Params
   return "projects,stacks,hKeys,depKeys,-,hkeyArray"
end show_Params

on menu_CollectScript dView
   put the link_Array of dView into hkeyArray
   put array_ListKeys (hkeyArray) into hKeys
   put script_CollectFromObjects (hKeys, true) into depScript
   --
   put the displayed_Hkey of dView into hKey
   display_Text depScript, hKey, "Hkey Dependency Script"
end menu_CollectScript

private on _
end _

on menu_DepStackNameScript dView
   put _GetDisplayData (dView, "stacks") into dData
   put keys (dData) into stackObjects
   repeat for each line stackObject in stackObjects
      put the short name of stackObject into sName
      put sName & CR after depStackNames
   end repeat
   delete char -1 of depStackNames
   --
   display_TransportGetPropHandler depStackNames, "getprop dep_StackNames"
end menu_DepStackNameScript

on menu_DisplaySvgGraph dView
   put the displayed_Array of dView into linkArray
   --
   display_LinkArrayGraph linkArray, "fast undirected spring"
end menu_DisplaySvgGraph

on menu_DisplayCrudeGraph dView
   local graphStyle
   put the displayed_Array of dView into linkArray
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

private on __
end __

on menu_GraphLinkArray dView, graphStyle
   put the displayed_Array of dView into linkArray
   
   put the result into svgFile
   --
   display_SVG svgFile, sObject
   put the result into dView
   set the displayed_Object of dView to sObject
end menu_GraphLinkArray

on menu_SimpleGraph dView
   local pFile, pGraphStyle
   put the displayed_Array of dView into linkArray
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

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | LinkArray | Menu")
end submenu_Dev
