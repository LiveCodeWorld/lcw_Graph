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
For "display_IndexScriptAndDisplaySVG"

A library to do with displaying overlays, creating them from folders of data (overlay_Folder)
and providing a set of custom properties that can be used to manipulate them.

Essentially it draws graphs using the data stored in arrays created by "deps_SaveMainstackAndExportArrays".
The main guts of the code is in "hkey_ObjectWalk", which uses "project_ConstructWalkArray" (a hArray walk which uses hArray_FindHkeyInHierarchy)
This is complicated hacked code with various filtering going on.

Then it walks missing handlers using "hkey_ObjectWalk"
*/


--> Graph | overlay_CreateGraph
-
command graph_Project scriptObject, pProjectName, pGraphStyle, pProcessObject, pForceCreate
   put graph_ConstructObjectHkeyArray (scriptObject, pProjectName, pProcessObject, pForceCreate) into hkeyArray
   set the projectOverlay_Array ["processedHkey.array"] of scriptObject to hkeyArray
   --
   graph_ProjectHkeyArray hkeyArray, scriptObject, pProjectName, pGraphStyle, pProcessObject
   put the result into imageFile
   return imageFile
end graph_Project

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

command graph_ObjectHkeyArray hkeyArray, hObject, pGraphStyle, pProcessObject
   -- should not use "project_OverlayFolder"
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


--> Graph | Object | HkeyArray
-
function graph_ConstructObjectHkeyArray scriptObject, projectName, pProcessObject, pForceCreate
   /*
   Uses "hkey_ObjectWalk"
   
   Was "hkeyArray_ConstructFromScript"
   
   You can alter the way the graph is constructed by placing a "graph_FilterProcessedArray" handler
   at the same level as the "display_IndexScriptAndDisplaySVG"
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
