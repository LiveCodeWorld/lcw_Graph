script "lib_GraphOverlay"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_GraphOverlay
type: library
version: 0.2

/*
All the good hkeyArray graphing goes through "overlay_CreateGraph"

However it si a VERY complex script, that uses outlines and XML and recursion, so we use it, 
but look to new ans simpler ways forwards.
*/


--> Working on
-


--> Graph | Overlay
-
command overlay_CreateGraph overlayFolder, hKeyArray, pOverlayName, pOverlayOf, pGraphStyle, pDotCluster, pMainstackHash, pImageFormat, pProcessObject
   -- Recreate graph from exported overlayArray
   put "hName" into pKeyStyle -- hName, number, short hkey
   --
   if pProcessObject is empty then
      put the long id of the target into pProcessObject
   end if
   
   --
   file_ReplaceHome overlayFolder
   if hKeyArray is not an array then
      overlay_Delete overlayFolder, pOverlayName
      return empty
   end if
   
   -- Recreate graph from exported overlayArray
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   if pOverlayOf is empty then put overlayArray_GetGraphProperty (overlayArray, "overlay_Of")  into pOverlayOf
   if pGraphStyle is empty then put overlayArray_GetGraphProperty (overlayArray, "overlay_Style")  into pGraphStyle
   
   put empty into pDotHeaderArray
   put empty into pGraphPropertyArray
   
   -- create graph arrays with local messages for processing
   dispatch "graph_TidyLinkArray" to pProcessObject with hKeyArray -- use "graph_TidyLinkArray @hKeyArray"
   put overlayArray_FromLinkArray (hKeyArray, pDotHeaderArray, pGraphPropertyArray, pKeyStyle) into overlayArray
   dispatch "graph_TidyOverlayArray" to pProcessObject with overlayArray -- use "graph_TidyOverlayArray @overlayArray"
   
   if pDotCluster is not empty then overlayArray_SetHeaderProperty overlayArray, "dot_ClusterRank", pDotCluster
   -- if pOverlayHash is not empty then overlayArray_SetGraphProperty overlayArray, "overlay_Hash", pOverlayHash
   
   file_ReplaceHome overlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Folder", overlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", pGraphStyle
   overlayArray_SetGraphProperty overlayArray, "overlay_Name", pOverlayName
   overlayArray_SetGraphProperty overlayArray, "overlay_Of", pOverlayOf
   
   overlayArray_CreateFilesAndSetGeometry overlayArray, pMainstackHash, pImageFormat
   if token 1 of the result = "error" then return the result
   
   /*
   put overlayArray_GetGraphProperty (overlayArray, "image_File") into shortImageFile
   folder_Format overlayFolder
   put overlayFolder & shortImageFile into imageFile
   put file_Hash (imageFile) into pMainstackHash
   */
   
   -- we change to mainstack_Hash rather than hash the image
   overlayArray_SetGraphProperty overlayArray, "overlay_Hash", pMainstackHash
   overlay_SetArray overlayFolder, overlayArray, pOverlayName
   return overlayArray
end overlay_CreateGraph

command overlayArray_CreateFilesAndSetGeometry @overlayArray, pMainstackHash, pImageFormat
   -- does not save overlay array
   if overlayArray is not an array then return empty
   put overlayArray_GetLinkArray (overlayArray) into hkeyArray
   if hkeyArray is not an array then return empty
   
   -- creates all the dot and image files (but does not save the array files)
   overlay_CreateDotFiles overlayArray, empty, pImageFormat
   put the result into gvResult
   if token 1 of gvResult = "error" then
      lcw_Notify gvResult, true
      return gvResult
   end if
   
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Name") into overlayName
   
   -- now set geometry by using dot to recreate files and then extract geometry array
   put overlay_GetCmapText (overlayFolder, overlayName) into cmapText
   put imagemap_ParseMap (cmapText) into geometryArray
   overlayArray_SetGeometryArray overlayArray, geometryArray
   
   ## Store overlayArray in case not already stored
   overlay_SetArray overlayFolder, overlayArray, overlayName, pMainstackHash
   return geometryArray
end overlayArray_CreateFilesAndSetGeometry

command overlay_CreateDotFiles @overlayArray, pOverlayFolder, pImageFormat
   -- creates all the dot and image files (but does not save the array files)
   if pImageFormat is empty then put "png" into pImageFormat
   
   put overlayArray_GetLinkArray (overlayArray) into hkeyArray
   if hkeyArray is not an array then return empty
   
   put dot_FromOverlayArray (overlayArray) into dotText
   
   if pOverlayFolder is not empty then
      folder_CreateNested pOverlayFolder
      overlayArray_SetGraphProperty overlayArray, "overlay_Folder", pOverlayFolder
   else
      put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into pOverlayFolder
      if pOverlayFolder is empty then
         put the tempname & "/" into pOverlayFolder
         folder_CreateNested pOverlayFolder
         overlayArray_SetGraphProperty overlayArray, "overlay_Folder", pOverlayFolder
      end if
   end if
   
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Style") into graphStyle
   if graphStyle is empty then
      put "hierarchical" into graphStyle
      overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   end if
   
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Name") into overlayName
   if overlayName is empty then
      put graphStyle into overlayName
      overlayArray_SetGraphProperty overlayArray, "overlay_Name", overlayName
   end if
   
   overlay_Files pOverlayFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, overlayName, pImageFormat
   -- put dotFile & CR & dotText
   dot_SaveTemporaryFile dotText, dotFile
   
   if graphStyle = "hierarchical" then -- lets flatten it ?
      put overlayArray_GetGraphProperty (overlayArray, "overlay_FlattenNum") into overlayFlattenNum
      if overlayFlattenNum is a number and overlayFlattenNum > 0 then
         put dot_UnFlatten (dotFile, overlayFlattenNum) into unFlatDotText
         if word 1 of unFlatDotText is among the items of "digraph,graph" then
            file_CreateText unFlatDotText, dotFile
         end if
      end if
   end if
   
   dot_DoImageMapShell graphStyle, dotFile, imageFile, cmapxFile, xdotFile, pImageFormat
   put the result into gvResult
   if word 1 of gvResult = "Error" then
      return gvResult
   end if
   
   -- now set relative files
   overlay_SetAndStoreFileRelative overlayArray, "dot_File", dotFile
   overlay_SetAndStoreFileRelative overlayArray, "image_File", imageFile
   overlay_SetAndStoreFileRelative overlayArray, "cmapx_File", cmapxFile
   overlay_SetAndStoreFileRelative overlayArray, "xdot_File", xdotFile
   
   return gvResult
end overlay_CreateDotFiles


--> Private
-
private command overlay_SetAndStoreFileRelative @overlayArray, filePropName, someFile
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   overlay_SetFileRelative someFile, overlayFolder
   overlayArray_SetGraphProperty overlayArray, filePropName, someFile
end overlay_SetAndStoreFileRelative
