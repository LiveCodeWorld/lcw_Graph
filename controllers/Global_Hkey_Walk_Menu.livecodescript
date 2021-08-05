script "Global | Hkey | Walk | Menu"
--> MetaData
-
license: GPLv3
name: Global | Hkey | Walk | Menu
type: controller
version: 0.3

/*
*/

--> Variables
-
local LocalArray

getprop menu_Target
   put scriptEditor_GetHkey() into hKey
   return hKey 
end menu_Target

getprop displaySvg_Params [hKey]
   put hkey_ListSvgFiles (hKey) into shortFiles
   return shortFiles
end displaySvg_Params


--> Global | Hkey | Walk | Menu
-
on menu_DisplayHkeyArray hKey
   display_HkeyArray hKey
end menu_DisplayHkeyArray

on menu_DisplaySvg hKey, shortFile
   display_HkeySvg hKey, svgFile
end menu_DisplaySvg

on menu_DisplayDot hKey
   display_HkeyDot hKey
end menu_DisplayDot

on _
end _

on menu_GraphHandler hKey
   display_CreateHandlerGraph hKey -- doesn't use lib_HkeyWalk
end menu_GraphHandler

on menu_FastGraphHandler hKey
   display_CreateFastHandlerGraph hKey
end menu_FastGraphHandler

on _
end _

on menu_DisplayHandlerDeps hkey
   display_HandlerDeps hkey
end menu_DisplayHandlerDeps

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _WalkExportedHkeyDeps hKey
   display_HandlerDeps hKey
end _WalkExportedHkeyDeps

on _HkeyArrayFromExported hKey
   put hkeyArray_FromExported (hKey) into hkeyArray
   display_Array hkeyArray
end _HkeyArrayFromExported

on _TestFindAndAdd hKey
   put "lcw_Wiki" into projectName
   -- put empty into projectName
   
   set the behavior of stack "Temp Revigniter Controllers" to empty
   -- put empty into projectName
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   
   put "json_FromArray,f" into shortHKey
   put empty into foundStackArray
   put hkey_FindAndAdd (shortHKey, hObject, foundStackArray, projectName)
end _TestFindAndAdd


--> Global | Hkey | Walk | Menu | Props
-
getprop p_Name [hKey]
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the project_Name of hObject into projectName
   return projectName
end p_Name

getprop p_Names
   put library_ListProjectNames() into projectNames
   return projectNames
end p_Names


--> Global | Hkey | Walk | Menu | Disabled
-
getprop disabled_DisplayDot [hKey]
   put hkey_DotFile (hKey) into dotFile
   if there is a file svgFile then
      return false
   else
      return "delete"
   end if
end disabled_DisplayDot

getprop disabled_DisplaySvg [hKey]
   put hkey_SvgFile (hKey) into svgFile
   if there is a file svgFile then
      return false
   else
      return "delete"
   end if
end disabled_DisplaySvg
