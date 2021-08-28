script "Global | Hkey | Walk | Menu"
--> MetaData
-
copyright: David Bovill
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


--> Global | Hkey | Walk | Menu
-
on menu_GraphHandler hKey
   display_CreateHandlerGraph hKey
end menu_GraphHandler

on menu_FastGraphHandler hKey
   display_CreateHandlerGraph hKey, "fast undirected spring"
end menu_FastGraphHandler

on _
end _

on menu_DisplaySvg hKey, shortFile
   display_HkeySvg hKey, svgFile
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
