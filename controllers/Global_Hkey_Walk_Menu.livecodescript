script "Global_Hkey_Walk_Menu"
--> MetaData
-
license: GPLv3
name: Global_Hkey_Walk_Menu
type: controller
version: 0.3

/*
*/

--> Variables
-
local LocalArray


--> Global | Hkey | Walk | Menu
-
on menu_GraphHandler hKey
   display_CreateHandlerGraph hKey
end menu_GraphHandler

on menu_DisplaySvg hKey
   display_HkeyGraph hKey, true
end menu_DisplaySvg

on menu_DisplayDot hKey
   display_HkeyDot hKey
end menu_DisplayDot

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_WalkExportedHkeyDeps hKey
   display_HandlerDeps hKey
end menu_WalkExportedHkeyDeps

on menu_HkeyArrayFromExported hKey
   put hkeyArray_FromExported (hKey) into hkeyArray
   display_Array hkeyArray
end menu_HkeyArrayFromExported

on menu_TestFindAndAdd hKey
   put "lcw_Wiki" into projectName
   -- put empty into projectName
   
   set the behavior of stack "Temp Revigniter Controllers" to empty
   -- put empty into projectName
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   
   put "json_FromArray,f" into shortHKey
   put empty into foundStackArray
   put hkey_FindAndAdd (shortHKey, hObject, foundStackArray, projectName)
end menu_TestFindAndAdd


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
