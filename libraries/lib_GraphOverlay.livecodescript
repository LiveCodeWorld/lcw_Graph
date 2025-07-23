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
function object_ToSlug oName
   return "default_header" -- for now
   
   # Construct a safe informative graph title
   if oName is not empty then
      put kwote (pageSlug) into graphTitle
   else
      put "default_header" into graphTitle
   end if
end object_ToSlug

function overlayArray_ConstructDot overlayArray, pOverlayName 
   put overlayArray_ConstructHeader (overlayArray) into dotHeader
   put dot_DefSectionFromArray (overlayArray, pOverlayName) into defSection
   
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdLinkArray, dotClusterArray
   
   put overlayArray_GetHeaderProperty (overlayArray, "dot_ClusterRank") into dotCluster
   if dotClusterArray is an array and dotCluster is not "none" then
      put overlayArray_ConstructClusterSection (overlayArray, pOverlayName) into clusterSection
   end if
   
   -- put hKeyArray_ConstructNodeSection (idArray, idLinkArray, graphController, nodeTypeArray) into linkSection
   put linkArray_DotNodeLinks (idLinkArray) into linkSection
   
   # Construct a safe informative graph title
   if pOverlayName is empty then
      put overlayArray_GetGraphProperty (overlayArray, "overlay_Of") into oName
      put object_ToSlug(oName) into graphTitle
   else
      put pOverlayName into graphTitle
   end if
   replace space with "_" in graphTitle
   
   put dot_TextFromSections (dotHeader, defSection, clusterSection, linkSection, graphTitle) into dotText
   return dotText
end overlayArray_ConstructDot


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
   
   # Recreate graph from exported overlayArray
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   if pOverlayOf is empty then put overlayArray_GetGraphProperty (overlayArray, "overlay_Of") into pOverlayOf
   if pGraphStyle is empty then put overlayArray_GetGraphProperty (overlayArray, "overlay_Style") into pGraphStyle
   
   put empty into pDotHeaderArray
   put empty into pGraphPropertyArray
   
   # Create graph arrays with local messages for processing
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
   
   # Change to mainstack_Hash rather than hash the image
   overlayArray_SetGraphProperty overlayArray, "overlay_Hash", pMainstackHash
   overlay_SetArray overlayFolder, overlayArray, pOverlayName
   return overlayArray
end overlay_CreateGraph

command overlayArray_CreateFilesAndSetGeometry @overlayArray, pMainstackHash, pImageFormat
   # Does not save overlay array
   if overlayArray is not an array then return empty
   put overlayArray_GetLinkArray (overlayArray) into hkeyArray
   if hkeyArray is not an array then return empty
   
   # Creates all the dot and image files (but does not save the array files)
   overlayArray_CreateDotFiles overlayArray, empty, pImageFormat
   put the result into gvResult
   if token 1 of gvResult = "error" then
      lcw_Notify gvResult, true
      return gvResult
   end if
   
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Name") into overlayName
   
   # Now set geometry by using dot to recreate files and then extract geometry array
   put overlay_GetCmapText (overlayFolder, overlayName) into cmapText
   put imagemap_ParseMap (cmapText) into geometryArray
   overlayArray_SetGeometryArray overlayArray, geometryArray
   
   # Store overlayArray in case not already stored
   overlay_SetArray overlayFolder, overlayArray, overlayName, pMainstackHash
   return geometryArray
end overlayArray_CreateFilesAndSetGeometry

command overlayArray_CreateDotFiles @overlayArray, pOverlayFolder, pImageFormat
   -- creates all the dot and image files (but does not save the array files)
   if pImageFormat is empty then put "png" into pImageFormat
   
   put overlayArray_GetLinkArray (overlayArray) into hkeyArray
   if hkeyArray is not an array then return empty
   
   put overlayArray_ConstructDot (overlayArray) into dotText
   
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
end overlayArray_CreateDotFiles


--> Dot | Overlay Array
-
/* 
A overlayArray is a datastructure that contains all the required information to draw a dot graph.

Several dotArrays can be nested inside an overlayData structure (see libOPN_GraphData),
which can be returned using the script_OverlayData of hkey_FetchOverlayData.

This library and it's handlers could be renamed to graphArray / libOPN_GraphArray,
but overlayArray while not as intuitive, is at least unique (there may be other types of graph?).
*/

function overlayArray_ConstructHeader overlayArray, pOverlayName
   overlayArray_DeconstructMetadata overlayArray, graphPropertyArray, dotHeaderArray, nodePropertyArray, edgePropertyArray, dotNodeStyleArray, pOverlayName
   -- _AddGraphSize dotHeaderArray, graphPropertyArray -- not needed with svg's
   _AddHeaderStuff dotHeaderArray, graphPropertyArray
   put dot_HeaderFromArrays (dotHeaderArray, nodePropertyArray, edgePropertyArray) into dotHeader
   return dotHeader
end overlayArray_ConstructHeader

private command _AddGraphSize @dotHeaderArray, graphPropertyArray
   put graphPropertyArray ["overlay_Size"] into graphSize
   if graphSize is not empty then
      if graphPropertyArray [pUseInches] is not false then
         put dot_RectFromSize (graphSize) into bbRect
         put graphPropertyArray ["overlay_ScaleToFit"] into someBoolean
         put dot_GraphInchSize (bbRect, someBoolean) into inchSize
         if inchSize is not empty then
            put inchSize into dotHeaderArray ["size"]
         end if
      else
         put dot_RectFromSize (graphSize) into bbRect
         if bbRect is not empty then
            put bbRect into dotHeaderArray ["bb"]
         end if
      end if
   end if
end _AddGraphSize


--> Private
-
private command _AddHeaderStuff @dotHeaderArray, graphPropertyArray
   switch graphPropertyArray ["overlay_Style"]
      case "hierarchical"
         -- remove these props unless the style is hierarchical "dot"
         delete local dotHeaderArray ["overlap"]
         delete local dotHeaderArray ["ordering"]
         delete local dotHeaderArray ["concentrate"]
         break
      case "spring"
         if dotHeaderArray ["overlap"] is empty then
            put false into dotHeaderArray ["overlap"]
         end if
         break
      default
   end switch
end _AddHeaderStuff

private command overlay_SetAndStoreFileRelative @overlayArray, filePropName, someFile
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   overlay_SetFileRelative someFile, overlayFolder
   overlayArray_SetGraphProperty overlayArray, filePropName, someFile
end overlay_SetAndStoreFileRelative
