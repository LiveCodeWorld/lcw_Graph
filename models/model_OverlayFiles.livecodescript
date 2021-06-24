script "model_OverlayFiles"
--> MetaData
-
license: GPLv3
name: model_OverlayFiles
type: model
version: 0.2


--> Working on
-

--> Overlay | Folders
-
getprop project_OverlayFolder [pDontCreate]   
   -- /metadata/project/overlay/ 
   put the metadataProject_Folder of the target into metadataProjectFolder
   put metadataProjectFolder & "overlay/" into overlayFolder
   if pDontCreate is false then folder_CreateNested overlayFolder
   return overlayFolder
end project_OverlayFolder


--> Overlay | File | Wrappers
-
function overlay_GetCmapFile overlayFolder, pOverlayName
   put overlay_ConstructFile ("cmapx", overlayFolder, pOverlayName) into someFile
   return someFile
end overlay_GetCmapFile

function overlay_GetImageFile overlayFolder, pOverlayName
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   put overlayArray_GetImageFile (overlayArray, overlayFolder) into imageFile
   return imageFile
end overlay_GetImageFile

function overlayArray_GetImageFile overlayArray, overlayFolder
   put overlayArray_GetGraphProperty (overlayArray, "image_File") into shortImageFile
   if shortImageFile is empty then return empty
   text_AddTrailing overlayFolder, slash
   put overlayFolder & shortImageFile into imageFile
   return imageFile
end overlayArray_GetImageFile

function overlay_LinkFile overlayFolder
   -- could rename to "lcw_links.txt" ?
   folder_Format overlayFolder
   put overlayFolder & "links.txt" into someFile
   return someFile
end overlay_LinkFile

function overlay_GetNodeLinks overlayFolder
   put overlay_LinkFile (overlayFolder) into someFile
   put url ("file:" & someFile) into nodeLinks
   return nodeLinks
end overlay_GetNodeLinks

command overlay_SetNodeLinks overlayFolder, nodeLinks
   put overlay_LinkFile (overlayFolder) into someFile
   if nodeLinks is empty then
      -- file_Delete someFile
      delete file someFile
   else
      put nodeLinks into url ("file:" & someFile)
   end if
end overlay_SetNodeLinks


--> Overlay | File
-
function overlay_ArrayFile overlayFolder
   folder_Format overlayFolder
   put overlayFolder & "overlayData.array" into dotArrayFile
   return dotArrayFile
end overlay_ArrayFile

function overlay_GetFile overlayArray, filePropName
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   put overlayArray_GetGraphProperty (overlayArray, filePropName) into relativeFile
   folder_Format overlayFolder -- should not be needed
   put overlayFolder & relativeFile into someFile
   return someFile
end overlay_GetFile

command overlay_Files overlayFolder, @dotFile, @imageFile, @cmapxFile, @xdotFile, @dotArrayFile, pOverlayName, pImageFormat
   if pOverlayName is empty then
      put overlay_Getdata (overlayFolder) into overlayData
      overlayData_NormalizeName pOverlayName, overlayData
   end if
   folder_Format overlayFolder
   
   overlay_ShortFiles pOverlayName, shortDotFile, shortImageFile, shortCmapxFile, shortXdotFile, shortDotArrayFile, pImageFormat
   
   put overlayFolder & shortDotArrayFile into dotArrayFile
   put overlayFolder & shortDotFile into dotFile
   put overlayFolder & shortImageFile into imageFile
   put overlayFolder & shortCmapxFile into cmapxFile
   put overlayFolder & shortXdotFile into xdotFile
end overlay_Files

command overlay_ShortFiles overlayName, @shortDotFile, @shortImageFile, @shortCmapxFile, @shortXdotFile, @shortDotArrayFile, pImageFormat
   if pImageFormat is empty then put "png" into pImageFormat
   put "overlayData.array" into shortDotArrayFile
   
   put overlayName & ".dot" into shortDotFile
   put overlayName & "." & pImageFormat into shortImageFile
   put overlayName & ".cmapx" into shortCmapxFile
   put overlayName & ".xdot" into shortXdotFile
end overlay_ShortFiles

function overlay_ListAllFiles overlayFolder, pImageFormat
   put overlay_GetData (overlayFolder) into overlayData 
   put overlayData_ListNames (overlayData) into overlayNames
   repeat for each line overlayName in overlayNames
      overlay_Files overlayFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, overlayName, pImageFormat
      if there is a file dotFile then put dotFile & CR after overlayFiles
      if there is a file imageFile then put imageFile & CR after overlayFiles
      if there is a file cmapxFile then put cmapxFile & CR after overlayFiles
      if there is a file xdotFile then put xdotFile & CR after overlayFiles
      if there is a file dotArrayFile then put dotArrayFile & CR after overlayFiles
   end repeat
   delete char -1 of overlayFiles
   return overlayFiles
end overlay_ListAllFiles

function overlay_ImageFiles overlayFolder
   folder_Format overlayFolder
   put the directory into oDirectory
   set the directory to overlayFolder
   put the files into shortFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      if item -1 of shortFile = "png" then
         put overlayFolder & shortFile & CR after imageFiles
      end if
   end repeat
   delete char -1 of imageFiles
   set the directory to oDirectory
   return imageFiles
end overlay_ImageFiles
