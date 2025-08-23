script "Global_Overlay_Menu"
--> MetaData
-
license: GPLv3
name: Global_Overlay_Menu
type: controller
version: 0.2

/*
This menu uses overlayFolder as mTarget.
It is for drawing, displaying and otherwise manipulating overlay images and groups.

Changed this to use scriptObject instead of overlayFolder as mTarget.
*/


--> Global | Overlay | Menu
-
on menu_DisplayInteractiveOverlay scriptObject, overlayName
   put the overlay_Folder of scriptObject into overlayFolder
   --
   display_Overlay overlayFolder, overlayName
end menu_DisplayInteractiveOverlay

on menu_OpenImageFile scriptObject, overlayName
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_GetImageFile (overlayFolder, overlayName) into imageFile
   launch document imageFile
end menu_OpenImageFile

on _
end _

on menu_RevealOverlayFolder scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   --
   finder_Reveal overlayFolder
end menu_RevealOverlayFolder

on menu_RevealImageFile scriptObject, overlayName
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_GetImageFile (overlayFolder, overlayName) into imageFile
   finder_Reveal imageFile
end menu_RevealImageFile

on menu_RevealOverlayDataFile scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_ArrayFile (overlayFolder) into someFile
   finder_Reveal someFile
end menu_RevealOverlayDataFile

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_CreateLimitOverlay scriptObject, generationNum
   put the overlay_Folder of scriptObject into overlayFolder
   --
   overlay_ReconstructDotArray overlayFolder, overlayName
   put the result into overlayArray
   display_Overlay overlayFolder, overlayName
end menu_CreateLimitOverlay

on menu_CloneOverlay scriptObject, overlayName   
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_GetArray (overlayFolder, overlayName) into overlayArray
   put lcw_Ask ("Rename this graph?", overlayName) into newOverlayName
   overlayArray_SetGraphProperty overlayArray, "overlay_Name", newOverlayName
   
   overlay_SetArray overlayFolder, overlayArray, newOverlayName
   overlayArray_CreateDotFiles overlayArray, overlayFolder
   
   display_Overlay overlayFolder, newOverlayName
end menu_CloneOverlay

on _
end _

on menu_OverlayNodeLinks scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_GetNodeLinks (overlayFolder) into someText
   display_Lines someText
end menu_OverlayNodeLinks

on menu_OverlayDotText scriptObject, overlayName
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_GetDotText (overlayFolder, overlayName) into someText
   display_Lines someText
end menu_OverlayDotText

on menu_DotTextFromArray scriptObject, overlayName
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_GetArray (overlayFolder, overlayName) into overlayArray
   put overlayArray_ConstructDot (overlayArray) into dotText
   
   display_Text dotText, "overlayArray_FromLinkArray"
end menu_DotTextFromArray

on menu_OverlayDotXml scriptObject, overlayName
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_ConstructFile ("xdot", overlayFolder, overlayName) into someFile
   put dot_ConvertToXml (someFile) into dotXML
   
   display_Lines dotXML
   -- put xml_ToArray (dotXML) into dotArray
   display_Xml dotXML, "Dot XML"
end menu_OverlayDotXml


--> Global | Overlay | Menu | Props
-
-- getprop overlay_DefaultName [scriptObject]
put overlay_GetDefaultName (overlayFolder) into overlayDefaultName
return overlayDefaultName
end overlay_DefaultName

getprop generation_Nums
   return "1,2,3"
end generation_Nums

getprop overlay_Names [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_ListNames (overlayFolder) into overlayNames
   return overlayNames
end overlay_Names

-- getprop overlay_DefaultNames [scriptObject]
put the overlay_Folder of scriptObject into overlayFolder
put overlay_ListNames (overlayFolder) into overlayNames
return overlayNames
end overlay_DefaultNames


--> Global | Overlay | Menu | Disabled
-
-- getprop disabled_DeleteOverlay [scriptObject]
put the overlay_Folder of scriptObject into overlayFolder
return _NoNames (overlayFolder)
end disabled_DeleteOverlay

getprop disabled_DefaultOverlayName [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   return _NoNames (overlayFolder)
end disabled_DefaultOverlayName

getprop disabled_DisplayOverlayData [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   return _NoDataFile (overlayFolder)
end disabled_DisplayOverlayData

getprop disabled_OverlayNodeLinks [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   put overlay_LinkFile (overlayFolder) into someFile
   if there is a file someFile then
      return false
   else
      return true
   end if
end disabled_OverlayNodeLinks

getprop disabled_ReconstructFromLinkArray [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   return _NoDataFile (overlayFolder)
end disabled_ReconstructFromLinkArray

getprop disabled_CloneOverlay [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   return _NoDataFile (overlayFolder)
end disabled_CloneOverlay

getprop disabled_RevealOverlayDataFile [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   return _NoDataFile (overlayFolder)
end disabled_RevealOverlayDataFile

getprop disabled_DisplayInteractiveOverlay [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   return _NoImageFiles (overlayFolder)
end disabled_DisplayInteractiveOverlay

getprop disabled_OpenImageFile [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   return _NoImageFiles (overlayFolder)
end disabled_OpenImageFile

getprop disabled_RevealImageFile [scriptObject]
   put the overlay_Folder of scriptObject into overlayFolder
   --
   return _NoImageFiles (overlayFolder)
end disabled_RevealImageFile


--> Deps
-
private function _NoDataFile overlayFolder
   put overlay_ArrayFile (overlayFolder) into someFile
   if there is a file someFile then
      return false
   else
      return true
   end if
end _NoDataFile

private function _NoNames overlayFolder
   put overlay_ListNames (overlayFolder) into overlayNames
   if overlayNames is empty then
      return true
   else
      return false
   end if
end _NoNames

private function _NoImageFiles overlayFolder
   put overlay_ImageFiles (overlayFolder) into overlayImageFiles
   if overlayImageFiles is empty then
      return true
   else
      return false
   end if
end _NoImageFiles
