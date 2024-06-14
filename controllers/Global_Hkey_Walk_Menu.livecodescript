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

getprop displayDot_Params [hKey]
   put hkey_ListDotFiles (hKey) into shortFiles
   return shortFiles
end displayDot_Params

-- getprop disabled_DisplayDot [hKey]
put hkey_DotFile (hKey) into dotFile
if there is a file svgFile then
   return false
else
   return "delete"
end if
end disabled_DisplayDot

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
   put hkey_OverlayDataFile (hKey) into overlayFile
   return there is not a file overlayFile
end disabled_DisplayHkeyArray


--> Global | Hkey | Walk | Menu
-
on menu_GraphHandler hKey
   display_CreateHandlerGraph hKey
end menu_GraphHandler

on menu_FastGraphHandler hKey
   display_CreateHandlerGraph hKey, "fast undirected spring"
end menu_FastGraphHandler

-- on menu_ConstructDot hKey
put hkeyArray_Construct (hKey)
put hkey_ConstructDepArray(allCalls, pMakePrivate)
-- put hkey_ConstructHarrayWalkArray(hKeys, hArray, pSearchOutSideMainStack)
put dot_ConstructFromHkeyArray (hKeyArray, pGraphStyle, overlayName) into sDot
-- put hkey_ConstructHarrayWalkArray (hKeys, hArray, pSearchOutSideMainStack)
end menu_ConstructDot

private on _
end _

on menu_DisplaySvg hKey, shortFile
   display_HkeySvg hKey, svgFile
end menu_DisplaySvg

on menu_DisplayDot hKey, shortFile
   set the itemdelimiter to "."
   put item 1 of shortFile into graphStyle
   --
   display_HkeyDot hkey, graphStyle
end menu_DisplayDot

private on __
end __

on menu_ExportHkeyArray hKey
   put walk_GetHkeyArray (hKey) into hKeyArray
   --
   hKey_SetArray hkey, hKeyArray
end menu_ExportHkeyArray

on menu_TestBullets
   put hKey_GetArray (hkey) into hKeyArray
   --
   put hkeyArray_DepStackBulletList (hkeyArray)
end menu_TestBullets

on menu_DisplayExportedHkeyArray hKey
   put hKey_GetArray (hkey) into hKeyArray
   --
   display_HKeyArray hKey, hkeyArray
   put the result into dView
   return dView
end menu_DisplayExportedHkeyArray

getprop disabled_DisplayExportedHkeyArray [hKey]
   put hkey_ArrayFile (hKey) into hkeyArrayFile
   return there is not a file hkeyArrayFile
end disabled_DisplayExportedHkeyArray

private on ___
end ___

on menu_HkeyDepArray hKey
   display_HkeyDepArray hKey
end menu_HkeyDepArray

on menu_DisplayOverlayData hKey
   put hkey_FetchOverlayData (hKey) into overlayData
   display_Array overlayData, hKey, "hkey_FetchOverlayData (hKey)"
end menu_DisplayOverlayData

on menu_MetadataFolder hKey
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   finder_Reveal hkeyMetadataFolder
end menu_MetadataFolder

on submenu_Dev
   return menu_DevTitle ("Global | Hkey | Walk | Menu")
end submenu_Dev
