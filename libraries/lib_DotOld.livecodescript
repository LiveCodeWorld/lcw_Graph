﻿script "lib_DotOld"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DotOld
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Dot | Old
-


--> Dot | Create
-
command dot_ProcessAndSaveFiles dotText, graphStyle, @pDotFile, @imageFile, @cmapFile, @xdotFile, pOverlayName, pImageFormat
   -- old
   -- depends on dodgy technique to figure out dotFolder
   
   if pDotFile is empty then
      put the tempname & "/" into dotFolder
      folder_CreateNested dotFolder
   else
      put pDotFile into dotFolder
      if char -1 of pDotFile is not "/" then
         set the itemdelimiter to "/"
         delete item -1 of dotFolder
         put "/" after dotFolder
      end if
   end if
   overlay_Files dotFolder, dotFile, imageFile, cmapFile, xdotFile, dotArrayFile, pOverlayName, pImageFormat
   
   file_CreateText dotText, dotFile
   /*
   if pGraphStyle = "hierarchical" then -- lets flatten it ?
      put dot_UnFlatten (pDotFile, 12) into unFlatDotText
      if word 1 of unFlatDotText is among the items of "digraph,graph" then
         file_CreateText unFlatDotText, pDotFile
      end if
   end if
   */
   dot_DoImageMapShell graphStyle, dotFile, imageFile, cmapFile, xdotFile, "png"
   return pDotFile
end dot_ProcessAndSaveFiles


