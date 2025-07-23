script "lib_DisplayHkeyDeps"
--> MetaData
-
license: GPLv3
name: lib_DisplayHkeyDeps
type: library
version: 0.3


--> Working on
-

--> Display
-
command display_HkeySVG hkey
   put hkey_SvgFile (hKey) into svgFile
   display_HkeySvgFile svgFile, hkey
   return the result
end display_HkeySVG

command display_HkeySvgFile svgFile, hkey
   -- if scriptEditor_PaneExists ("Deps") then display_ScriptEditorSvg svgFile
   
   display_Svg svgFile, hkey
   put the result into dView
   if exists (dView) then
      set the displayed_Hkey of dView to hkey
   end if
   return dView
end display_HkeySvgFile

command display_ClusterDepGraph hkey, searchHierarchy, pClusterBoolean, pProcessObject  
   graph_HkeyCreateCluster hkey, searchHierarchy, pClusterBoolean, pProcessObject
   display_HkeySVG hkey
   put the result into displayView
   return displayView
end display_ClusterDepGraph

command display_HkeyGraph hKey, pRevealFinder
   put hkey_SvgFile (hKey) into svgFile
   display_HkeySVG hkey
   --
   if pRevealFinder is true then
      finder_Reveal svgFile
   end if
end display_HkeyGraph

command display_HkeyDot hkey, pGraphStyle
   put hkey_DotFile (hKey, pGraphStyle) into dotFile
   --
   display_TextFile dotFile, hKey, mTitle, "Dot"
end display_HkeyDot

command display_HandlerCalls hKey
   put hkey_FetchCalls (hKey) into shortCalls
   hkey_Normalize hKey
   display_Lines shortCalls, hKey, "mDouble_EditShortHkey", "hkey_FetchCalls (hKey)"
end display_HandlerCalls

command display_SpotlightHandler hkeyLine, pTitle
   set the cursor to watch
   put spotlight_FindHandlerFile (hkeyLine) into foundFiles
   if foundFiles is empty then
      put hkeyLine
      answer "Spotlight could not find handler!"
      exit to top
   end if
   
   put the number of lines of foundFiles into lastNum
   if lastNum = 1 then
      put foundFiles into handlerFile
      atom_Edit handlerFile
      finder_Reveal handlerFile
      return foundFiles
   end if
   
   put 100 into maxNum
   if lastNum > maxNum then
      put merge ("There are [[maxNum]] found lines - this can tak a long time to process. Displaying the first [[maxNum]] lines.") into someComment
      lcw_Answer someComment
      put line 1 to maxNum of foundFiles into foundFiles
   end if
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   set the itemdelimiter to slash
   put the number of items of lcwUserMetadataFolder into rootItemNum
   repeat for each line foundFile in foundFiles
      set the cursor to busy
      put item (rootItemNum + 1) of foundFile into mainStackName
      put item -2 of foundFile into shortHkey
      put hkeyLine_FromHandlerFile (foundFile) into hkeyLine
      put hkeyLine & CR after hkeyLines
   end repeat
   delete char -1 of hkeyLines
   
   if pTitle is empty then
      put merge ("[[shortHkey]],spotlight_FindHandlerFile()") into pTitle
   end if
   display_HkeyLines hkeyLines, pTitle
   put the result into displayView
   --
   return foundFiles
end display_SpotlightHandler


--> Display | SVG
-
command display_ScriptSVG hObject, pSvgFile
   if pSvgFile is empty then
      put the overlay_SvgFile of hObject into pSvgFile
   end if
   --
   if scriptEditor_PaneExists ("Deps") then
      display_ScriptEditorSvg pSvgFile
   else
      put the name of hObject into stackLabel
      display_Svg pSvgFile, stackLabel
   end if
   put the result into displayView
   --
   set the displayed_Object of displayView to hObject
   return displayView
end display_ScriptSVG


--> Display | Events
-
on mDouble_EditShortHkey indexView, shortCall
   put the title_Text of indexView into hKeyLine
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   put the handler_InHierarchy [shortCall] of hObject
end mDouble_EditShortHkey


--> Working on
-
command hkey_CreateDepGraph hKey, pExternalObjects, pGraphStyle, pClusterBoolean
   -- see also "hkey_FoundArrayFromSearchHierarchy"
   put empty into overlayName -- defaults to pGraphStyle or "hierarchical"
   if pClusterBoolean is not false then 
      put empty into clusterRank
   else
      put "none" into clusterRank
   end if
   
   put hkey_DepArrayFromObjects (hKey, pExternalObjects, true) into hKeyArray
   --
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   folder_CreateNested hkeyMetadataFolder
   
   overlay_CreateGraph hkeyMetadataFolder, hkeyArray, overlayName, hKey, pGraphStyle, clusterRank, empty, "svg" 
   put hkey_SvgFile (hKey, pGraphStyle) into svgFile
   return svgFile
end hkey_CreateDepGraph

command hkey_CreateSearchHierarchyGraph hKey, searchHierarchy, pGraphStyle, pClusterBoolean, pMainstackHash, pProcessObject
   put empty into overlayName -- defaults to pGraphStyle or "hierarchical"
   if pClusterBoolean is not false then 
      put empty into clusterRank
   else
      put "none" into clusterRank
   end if
   
   put hkey_SearchHierarchyDependencyArray (hKey, searchHierarchy, true) into hKeyArray
   --
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   folder_CreateNested hkeyMetadataFolder
   overlay_CreateGraph hkeyMetadataFolder, hkeyArray, overlayName, hKey, pGraphStyle, clusterRank, pMainstackHash, "svg", pProcessObject
   --
   put hkey_SvgFile (hKey, pGraphStyle) into svgFile
   return svgFile
end hkey_CreateSearchHierarchyGraph

function hkey_SearchHierarchyDependencyArray hKeys, searchHierarchy, pAllCalls
   -- from objects. See also "hkey_DependencyArrayFromObjects"
   local hKeyLinkArray
   try  
      repeat for each line hKey in hkeys
         put handler_Get (hKey) into someHandler
         if pAllCalls is true then
            put handler_ExtractCalls (someHandler) into shortCalls
         else
            put handler_ExtractFilteredCalls (someHandler) into shortCalls
         end if
         
         repeat for each line shortCall in shortCalls
            hkey_ObjectWalkSearchHierarchy shortCall, hKey, hKeyLinkArray, searchHierarchy, pAllCalls
         end repeat
      end repeat
      return hKeyLinkArray
   catch e -- script is locked
      return empty
   end try
end hkey_SearchHierarchyDependencyArray

command hkey_ObjectWalkSearchHierarchy shortCall, hKey, @hKeyLinkArray, searchHierarchy, pAllCalls
   -- same as "hkey_ObjectWalk" but uses fixed searchHierarchy
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   hkey_Deconstruct shortCall, callName, callType, emptyCallObject, emptyCallNum
   
   put hkey_FindShortHkey (shortCall, hObject, searchHierarchy) into foundCall
   
   switch
      case foundCall is empty
         put hkey_Construct (callName, callType, "missing", 1) into foundCall
         indexArray_Add foundCall, hKey, hKeyLinkArray
         return empty
      case foundCall is among the keys of hKeyLinkArray
         -- already indexed so no need to recurse
         return empty
   end switch
   
   -- add it to the array
   indexArray_Add foundCall, hKey, hKeyLinkArray
   
   -- now lets repeat and recurse for each call found
   put handler_Get (foundCall) into callHandler
   if callHandler is empty then breakPoint
   
   if pAllCalls is true then
      put handler_ExtractCalls (callHandler) into shortCalls
   else
      put handler_ExtractFilteredCalls (callHandler) into shortCalls
   end if
   
   repeat for each line shortCall in shortCalls
      set the cursor to busy
      hkey_ObjectWalkSearchHierarchy shortCall, foundCall, hKeyLinkArray, searchHierarchy, pAllCalls
   end repeat
   return empty
end hkey_ObjectWalkSearchHierarchy

command graph_HkeyCreateCluster hkey, searchHierarchy, pClusterBoolean, pProcessObject
   -- good for checking deps are what you think
   -- only searches and displays deps found in sepcific script objects
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the mainstack_Hash of hObject into mainstackHash
   put hkey_Construct (hName, hType, hObject) into hkey -- fixes and badly formatted hKyes
   hkey_CreateSearchHierarchyGraph hkey, searchHierarchy, "hierarchical", pClusterBoolean, mainstackHash, pProcessObject
   put the result into imageFile
   return imageFile
end graph_HkeyCreateCluster


--> Private 
-
private function hkeyLine_FromHandlerFile handlerPath
   -- used by "display_SpotlightHandler" amd therefore "hkey_FindShortHkey" ???
   -- lcw_User/lcw_Metadata/lib_Display/data/objects/stack/handlers/M display_SpotlightHandler/lcw_handler.txt
   
   set the itemdelimiter to slash
   if item -1 of handlerPath is not "lcw_handler.txt" then return empty
   put item -2 of handlerPath into shortHkeyLine
   put item 1 to -4 of of handlerPath into somePath
   
   put script_ExportedRootToObject (somePath) into hObject
   put hKeyLine_AddObject (shortHkeyLine, hObject) into hkeyLine
   return hkeyLine
end hkeyLine_FromHandlerFile
