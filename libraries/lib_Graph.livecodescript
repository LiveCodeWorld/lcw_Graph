script "lib_Graph"
--> MetaData
-
license: GPLv3
name: lib_Graph
type: library
version: 0.2

/*
This library contains the latest top-level handlers for creating and manipulating graphs.

Previously there were many intefaces and libraries - overlayData, overlayFolder, overlayArray, linkArray etc
This library is designed to provide a standard way to interface with these handlers, 
using overlay_Folder and overlay_Name to refer to graph overlays uniquely.

= To Do =
At the moment the data structure is a nested set of dotArrays keyed by the overlayName of each overlayArray.
This means there is no real metadata for overlayData, and thngs like overlayName are stored
as a hack by slooping through metadata properties of each overlayArray.

The data structure should perhaps be changed to the usual data/metadata arrangement.
*/


--> Graph
-
/*
Here we store the latest graphing handlers.

A library to do with displaying overlays, creating them from folders of data (overlay_Folder)
and providing a set of custom properties that can be used to manipulate them.
*/


--> Working on
-

--> Graph
-
command graph_CreateFromScriptHkeyArray hkeyArray, hObject, pGraphStyle, pProcessObject
   -- tailored to create a clustered graph from hKeyArray of an objects script
   -- display_CreateScriptObjectGraph sObject, projectName, pGraphStyle, pProcessObject, false
   -- display_ObjectDepArray sObject
   
   if pGraphStyle is empty then put "hierarchical" into pGraphStyle
   --
   put the metadataObject_Folder [true] of hObject into metadataFolder
   --
   put true into clusterBoolean
   put empty into mainstackHash
   put hObject into overlayOf
   --
   overlay_CreateGraph metadataFolder, hkeyArray, pGraphStyle, overlayOf, pGraphStyle, clusterBoolean, mainstackHash, "svg", pProcessObject
   put the result into overlayArray
   --
   put overlayArray_GetImageFile (overlayArray, metadataFolder) into imageFile
   return imageFile
end graph_CreateFromScriptHkeyArray

command graph_Hkey hKey, pGraphStyle, pHkeyArray
   if pHkeyArray is not an array then
      put walk_ConstructHkeyArray (hKey) into pHkeyArray
   end if
   hKey_SetArray hkey, pHkeyArray
   --
   graph_HkeyArray hKey, pHkeyArray, pGraphStyle
   --
   put the result into svgFile
   return svgFile
end graph_Hkey

command graph_HkeyArray hKey, pHkeyArray, pGraphStyle
   -- uses "walk_ConstructHkeyArray" of stack "lib_HkeyWalk"
   
   # Set things up and do checks
   set the cursor to busy
   if pHkeyArray is not an array then
      put hKey_GetArray (hkey) into pHkeyArray
      if pHkeyArray is not an array then
         return "Error, hkeyArray is not an array for:" && hKey
      end if
   end if
   if pGraphStyle is empty then put "hierarchical" into pGraphStyle
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if exists (hObject) is false then
      return "Error, hObject for 'graph_HkeyArray' does not exists:" && hKey
   end if
   
   # Set HkeyArray
   -- script_SetHkeyArray hObject, pHkeyArray
   
   # Create Overlay and Graph
   put hkey_MetadataFolder (hKey) into metadataFolder
   overlay_CreateGraph metadataFolder, pHkeyArray, pGraphStyle, hObject, pGraphStyle, true, "", "svg"
   put the result into overlayArray
   
   # Return svgFile
   put overlayArray_GetImageFile (overlayArray, metadataFolder) into svgFile
   return svgFile
end graph_HkeyArray

command graph_HkeyDependency hKey, pProjectName, pGraphStyle, pClusterBoolean, processObject
   -- change to lib_HkeyWalk rather than walk_ConstructHkeyArray?
   -- traverses the hkey dependency graph using a slow crawl of Livecode objects
   -- uses overlay_CreateGraph and walk_ConstructHkeyArray
   
   put empty into overlayName -- defaults to pGraphStyle or "hierarchical"
   if pClusterBoolean is not false then 
      put empty into clusterRank
   else
      put "none" into clusterRank
   end if
   
   -- put hkey_DependencyArrayFromObjects (hKey, pProjectName, true) into hKeyArray
   put walk_ConstructHkeyArray (hKey) into hKeyArray
   hkeyArray_Process hKeyArray, processObject -- export to overlayArray
   --
   -- this is not working until we eexport overlayArray
   put hkey_MetadataFolder (hKey) into hkeyMetadataFolder
   folder_CreateNested hkeyMetadataFolder
   overlay_CreateGraph hkeyMetadataFolder, hkeyArray, overlayName, hKey, pGraphStyle, clusterRank, empty, "svg", processObject
   --
   put hkey_SvgFile (hKey, pGraphStyle) into svgFile
   return svgFile
end graph_HkeyDependency

command graph_CreateScriptObject sObject, pGraphStyle, pProcessObject, pProjectName
   -- uses overlay_CreateGraph and hkey_ObjectWalk (not walk_ConstructHkeyArray)
   
   put graph_ConstructObjectHkeyArray (sObject, pProjectName, pProcessObject) into hkeyArray
   set the projectOverlay_Array ["processedHkey.array"] of sObject to hkeyArray
   --
   graph_CreateFromScriptHkeyArray hkeyArray, sObject, pGraphStyle, pProcessObject
   put the result into imageFile
   return imageFile
end graph_CreateScriptObject

command graph_Project scriptObject, pProjectName, pGraphStyle, pProcessObject, pForceCreate
   put graph_ConstructObjectHkeyArray (scriptObject, pProjectName, pProcessObject, pForceCreate) into hkeyArray
   set the projectOverlay_Array ["processedHkey.array"] of scriptObject to hkeyArray
   --
   graph_ProjectHkeyArray hkeyArray, scriptObject, pProjectName, pGraphStyle, pProcessObject
   put the result into imageFile
   return imageFile
end graph_Project

command graph_ObjectHkeyArray hkeyArray, hObject, pGraphStyle, pProcessObject
   -- should not use "project_OverlayFolder" (see "graph_CreateFromScriptHkeyArray")
   put true into clusterBoolean
   put empty into mainstackHash
   --
   put "default" into overlayName
   put hObject into overlayOf
   put the project_OverlayFolder [false] of hObject into overlayFolder
   --
   overlay_CreateGraph overlayFolder, hkeyArray, overlayName, overlayOf, pGraphStyle, clusterBoolean, mainstackHash, "svg", pProcessObject
   put the result into overlayArray
   --
   put overlayArray_GetImageFile (overlayArray, overlayFolder) into imageFile
   return imageFile
end graph_ObjectHkeyArray

function graph_ConstructObjectHkeyArray scriptObject, projectName, pProcessObject, pForceCreate
   /*
   Uses "hkey_ObjectWalk"
   It's an hArray script
   
   Was "hkeyArray_ConstructFromScript"
   
   You can alter the way the graph is constructed by placing a "graph_FilterProcessedArray" handler
   This allows you to filter the plain hkeyArray before you graph it.
   This allows you to categorize thing like "missing" rig stacks as belonging to revIgniter.
   
   -- was "script_ConstructHkeyArray"
   This handler first fetches or creates an internal hKey array from the mainstack.
   It then looks at all "missing" that is externall hKeys, and slowly crawls the hierarchy to find them.
   I believe it indexes these hierarchy stacks as it goes.
   -- see "lib_HkeyArray"
   */
   
   put true into pAllCalls
   put empty into pDepObject
   --
   deps_SaveMainstackAndExportArrays scriptObject, pForceCreate
   put the result into mainStackMetaArray
   --
   -- deps_ConstructDependencyArray scriptObject, pForceCreate, projectName
   -- put the result into hKeyWalkArray
   put mainStackMetaArray ["hArray"] into hArray
   put project_ConstructWalkArray (hArray, pDepObject, projectName) into hKeyWalkArray
   set the mainstack_WalkArray of scriptObject to hKeyWalkArray
   
   -- now let's walk missing handlers
   put hKeyWalkArray ["missing"] into missingArray
   put hKeyWalkArray ["external"] into externalArray
   union missingArray with externalArray recursively
   
   put empty into missingHkeyLinkArray
   repeat for each key shortCall in missingArray
      put missingArray [shortCall] into hKeyInfoArray
      put keys (hKeyInfoArray) into hkeysThatCallMissing
      put line 1 of hkeysThatCallMissing into hKey -- just pick one
      hkey_ObjectWalk shortCall, hKey, missingHkeyLinkArray, projectName, pAllCalls
   end repeat
   
   put hKeyWalkArray ["hkeyArray"] into stackHkeyArray -- only lists internal calls
   union missingHkeyLinkArray with stackHkeyArray recursively
   
   repeat for each key someKey in missingHkeyLinkArray
      put word 1 to -1 of missingHkeyLinkArray [someKey] into someKeyCalls
      put empty into processedCalls
      repeat for each line someKeyCall in someKeyCalls
         if exists (pProcessObject) is false then
            put someKeyCall & CR after processedCalls
         else
            dispatch "graph_FilterProcessedArray" to pProcessObject with processedCalls,someKeyCall
            if it is "unhandled" then
               put someKeyCall & CR after processedCalls
            end if
         end if
      end repeat
      sort processedCalls
      put word 1 to -1 of processedCalls into processedCalls
      put processedCalls into processedHkeyArray [someKey]
   end repeat
   return processedHkeyArray
end graph_ConstructObjectHkeyArray


--> Graph | overlay_CreateGraph | Deps
-
command graph_ProjectHkeyArray hkeyArray, hObject, pGraphStyle, pProjectName, pProcessObject
   -- was "graph_ProjectCreate, script_CreateGraph" then "hObject_CreateGraph"
   -- tailored to create a clustered graph from hKeyArray of an objects script
   put true into clusterBoolean
   put empty into mainstackHash
   --
   if pProjectName is empty then put the project_Name of hObject into overlayName
   put pProjectName into overlayName
   put hObject into overlayOf
   --
   put the project_OverlayFolder [false] of hObject into overlayFolder
   --
   overlay_CreateGraph overlayFolder, hkeyArray, overlayName, overlayOf, pGraphStyle, clusterBoolean, mainstackHash, "svg", pProcessObject
   put the result into overlayArray
   --
   put overlayArray_GetImageFile (overlayArray, overlayFolder) into imageFile
   return imageFile
end graph_ProjectHkeyArray

command graph_ObjectSearchHierarchy hObject, searchHierarchy, pGraphStyle   
   local overlayName -- defaults to "hierarchical"
   put empty into pProjectName
   --
   put the hkey_Lines of hObject into hKeys
   put hkey_SearchHierarchyDependencyArray (hKeys, searchHierarchy, true) into hKeyArray
   --
   graph_ObjectHkeyArray hkeyArray, hObject, pGraphStyle
   put the result into imageFile
   return imageFile
end graph_ObjectSearchHierarchy
