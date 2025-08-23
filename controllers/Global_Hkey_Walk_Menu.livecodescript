script "Global | Hkey | Walk | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Hkey | Walk | Menu
type: controller
version: 0.4

/*
*/

--> Variables
-
local LocalArray

getprop menu_Target [tObject]
   put scriptEditor_GetHkey() into hKey
   if word 1 of hKey = "of" then
      breakpoint
      return empty
   end if
   return hKey 
end menu_Target

getprop displaySvg_Params [hKey]
   put hkey_ListSvgFiles (hKey) into shortFiles
   return shortFiles
end displaySvg_Params

getprop displayDot_Params [hKey]
   put hkey_ListDotFiles (hKey) into shortFiles
   return shortFiles
end displayDot_Params

getprop disabled_DisplaySvg [hKey]
   put hkey_ListSvgFiles (hKey) into shortFiles
   if shortFiles is empty then
      return "delete"
   else
      return false
   end if
end disabled_DisplaySvg

getprop disabled_DisplayOverlayData [hKey]
   put hkey_OverlayDataFile (hKey) into overlayFile
   return there is not a file overlayFile
end disabled_DisplayOverlayData

getprop disabled_DisplayHkeyArray [hKey]
   -- put hkey_OverlayDataFile (hKey) into overlayFile
   put hkey_ArrayFile (hKey) into hkeyArrayFile
   return there is not a file hkeyArrayFile
end disabled_DisplayHkeyArray


--> Global | Hkey | Walk | Menu
-
on menu_FastGraphHandler hKey
   display_CreateHandlerGraph hKey, "undirected spring"
   put the result into svgView
   --
   put the link_Array of svgView into hkeyArray
   put the displayed_Hkey of svgView into hKey
   put the displayed_GraphStyle of svgView into graphStyle
   --
   display_HandlerHkeyArray hKey, hkeyArray
   hKey_SetArray hkey, hKeyArray
end menu_FastGraphHandler

on menu_ExportHkeyArray hKey
   put walk_ConstructHkeyArray (hKey) into hKeyArray
   hKey_SetArray hkey, hKeyArray
   --
   display_HandlerHkeyArray hKey, hkeyArray
end menu_ExportHkeyArray

on menu_DisplayExportedHkeyArray hKey
   put hKey_GetArray (hkey) into hKeyArray
   display_HandlerHkeyArray hKey, hkeyArray
end menu_DisplayExportedHkeyArray

getprop disabled_DisplayExportedHkeyArray [hKey]
   put hkey_ArrayFile (hKey) into hkeyArrayFile
   return there is not a file hkeyArrayFile
end disabled_DisplayExportedHkeyArray

private on _
end _

on menu_GraphHandler hKey, graphStyle
   display_CreateHandlerGraph hKey, graphStyle
end menu_GraphHandler

getprop graphHandler_Param [hKey]
   put hkey_ListGraphStyles (hKey) into gStyles
   return gStyles
end graphHandler_Param

getprop graphHandler_Params [hKey]
   return dot_ListGraphStyles()
end graphHandler_Params

on menu_DisplaySvg hKey, shortFile
   put hkey_Folder (hKey) into hkeyFolder
   put hkeyFolder & shortFile into svgFile
   if there is a file svgFile then
      display_HkeySvgFile svgFile, hkey
   else
      put svgFile
      finder_Reveal hkeyFolder
   end if
end menu_DisplaySvg

on menu_DisplayDot hKey, shortFile
   set the itemdelimiter to "."
   put item 1 of shortFile into graphStyle
   --
   display_HkeyDot hkey, graphStyle
end menu_DisplayDot

private on __
end __

on menu_HkeyDepArray hKey
   display_HkeyDepArray hKey
end menu_HkeyDepArray

on menu_DisplayOverlayData hKey
   put hkey_FetchOverlayData (hKey) into overlayData
   display_Array overlayData, hKey, "hkey_FetchOverlayData (hKey)"
end menu_DisplayOverlayData

private on ___
end ___

on menu_MetadataFolder hKey
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   finder_Reveal hkeyMetadataFolder
end menu_MetadataFolder

on submenu_Dev
   return menu_DevTitle ("Global | Hkey | Walk | Menu")
end submenu_Dev
