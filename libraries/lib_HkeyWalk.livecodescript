script "lib_HkeyWalk"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_HkeyWalk
type: library
version: 0.2

/*
In this stack we organise the best tested and developed handlers that walk hkey dependency trees.
*/

--> Varaibles
-
local WalkSearchHierarchy
local AllowPrivateWithFirstObject = true
local UseExportedCalls = false


--> Ask
-
command ask_CreateDepHkeyArray sObject, dView
   put the walk_ModuleBehaviorHkeyArray of sObject into hkeyArray
   display_ScriptHkeyArrayDeps hkeyArray, sObject
   put the result into dView
   --
   put the module_Name of sObject into mName
   lcw_Answer "Save the hkey array for module '[[var]]' and replace the script_HkeyArray?", dView, mName
   --
   set the script_HkeyArray of sObject to hKeyArray
   --
   return dView
end ask_CreateDepHkeyArray

--> Make Recursive
-
getprop walk_DepArray [pHkey]
   put the walk_HkeyArray [hKey] of the target into hkeyArray
   put hkeyArray_GetStackDepArray (hkeyArray) into hkeyDepArray
   return hkeyDepArray
end walk_DepArray

getprop walk_ModuleBehaviorHkeyArray [fromFolder]
   put the long id of the target into sObject
   --
   put the module_BehaviorHierarchy [fromFolder] of sObject into bSearchObjects
   put the walk_ScriptHkeyArray [bSearchObjects] of sObject into hkeyArray
   return hkeyArray
end walk_ModuleBehaviorHkeyArray
   
getprop walk_HkeyArray [hKey]
   local hKeyArray
   put the long id of the target into tObject
   
   # Search Hierarchy
   put the walk_Hierarchy of tObject into searchObjects
   walk_SetSearchHierarchy searchObjects
   
   # HkeyArray of script of hanlder
   if hKey is empty then
      put the revAvailableHandlers of tObject into hTable
      put _WalkAvailableHandlers (hTable) into hKeyArray
   else
      _WalkHkeyRecursive shortCallHkey, hKey, hKeyArray
   end if
   return hKeyArray
end walk_HkeyArray

getprop walk_ScriptHkeyArray [pSearchObjects]
   local hKeyArray
   put the long id of the target into tObject
   
   # Work out search hierarchy
   if pSearchObjects is empty then
      put the walk_Hierarchy of tObject into pSearchObjects
   end if
   walk_SetSearchHierarchy pSearchObjects
   
   # Htable of objects script
   put the revAvailableHandlers of tObject into hTable
   
   # Walk recursively
   put _WalkAvailableHandlers (hTable) into hKeyArray
   --
   return hKeyArray
end walk_ScriptHkeyArray

function hkeyArray_FromStackDepArray hkeyDepArray
   local hkeyArray
   repeat for each element handlerArray in hkeyDepArray
      union hkeyArray with handlerArray -- recursively
   end repeat
   return hkeyArray
end hkeyArray_FromStackDepArray

function hkeyArray_GetStackDepArray hkeyArray
   local hkeyDepArray
   hkeyArray_SetObjectArray hkeyDepArray, hkeyArray
   return hkeyDepArray
end hkeyArray_GetStackDepArray

command hkeyArray_SetObjectArray @hkeyDepArray, hkeyArray
   repeat for each key hKey in hkeyArray
      set the cursor to busy
      
      -- add toplevel hKey to objectArray
      _AddToObjectArray hkeyDepArray, hKey
      
      -- look at calls
      put hkeyArray [hKey] into hkeyCalls
      if hkeyCalls is an array then
         repeat for each key hkeyCall in hkeyCalls
            _AddToObjectArray hkeyDepArray, hkeyCall, hKey
         end repeat
      else
         repeat for each line hkeyCall in hkeyCalls
            _AddToObjectArray hkeyDepArray, hkeyCall, hKey
         end repeat
      end if
   end repeat
end hkeyArray_SetObjectArray


--> Props | Dep
-
getprop dep_ProjectArray
   put the long id of the target into sObject
   if the module_Name of sObject is empty then
      put the walk_HkeyArray of sObject into hKeyArray
   else
      put the module_BehaviorDepHkeyArray of sObject into hKeyArray
   end if
   --
   put hkeyArray_GetProjectDepArray (hkeyArray) into depProjectArray
   return depProjectArray
end dep_ProjectArray

getprop dep_Data [graphStyle]
   if graphStyle is empty then put "hierarchical" into graphStyle
   --
   put the long id of the target into sObject
   put the walk_HkeyArray of sObject into hKeyArray
   --
   put dep_ConstructData (hkeyArray, sObject, graphStyle) into depData
   return depData
end dep_Data

function dep_ConstructData hkeyArray, sObject, pGraphStyle
   put hkeyArray_GetStackDepArray (hkeyArray) into depObjectData
   --
   put depObjectData into depData ["objectData"]
   delete variable depObjectData [sObject]
   put keys (depObjectData) into depData ["stacks"]
   --
   put hkeyArray_GetProjectDepArray (hkeyArray) into depProjectData
   put depProjectData into depData ["projectData"]
   put the project_Name of sObject into projectName
   delete variable depProjectData [projectName]
   put keys (depProjectData) into depData ["projects"]
   
   if pGraphStyle is not empty then
      put the short name of sObject into overlayName
      put dot_ConstructFromHkeyArray (hKeyArray, pGraphStyle, overlayName) into sDot
      put sDot into depData ["dot"]
   end if
   --
   return depData
end dep_ConstructData


--> Props
-
getprop dep_MissingArray [pHKeyArray]
   put the long id of the target into sObject
   if pHKeyArray is not an array then
      put the walk_HkeyArray of sObject into pHKeyArray
   end if
   --
   put hkeyArray_GetStackDepArray (pHKeyArray) into depObjectData
   put depObjectData ["Missing"] into missingArray
   return missingArray
end dep_MissingArray

getprop dep_Stacks [pHKeyArray]
   put the long id of the target into sObject
   if pHKeyArray is not an array then
      put the walk_HkeyArray of sObject into pHKeyArray
   end if
   --
   put hkeyArray_GetStackDepArray (pHKeyArray) into depObjectData
   delete variable depObjectData [sObject]
   --
   put keys (depObjectData) into depStacks
   return depStacks
end dep_Stacks

getprop dep_Projects [pHKeyArray]
   put the long id of the target into sObject
   if pHKeyArray is not an array then
      put the walk_HkeyArray of sObject into pHKeyArray
   end if
   --
   put hkeyArray_GetProjectDepArray (pHKeyArray) into depProjectData
   put the project_Name of sObject into projectName
   delete variable depProjectData [projectName]
   --
   put keys (depProjectData) into projectNames
   return projectNames
end dep_Projects

getprop call_HkeyArray [pSearchObjects]
   put the long id of the target into tObject
   put the revAvailableHandlers of tObject into hTable
   if pSearchObjects is empty then
      put the hkey_ScriptHierarchy of tObject into pSearchObjects
   end if
   --
   put true into UseExportedCalls
   walk_SetSearchHierarchy pSearchObjects
   put _WalkAvailableHandlers (hTable) into hKeyArray
   --
   return hKeyArray
end call_HkeyArray


--> Functions
-
function dot_ConstructFromHkeyArray hKeyArray, pGraphStyle, pOverlayName, pDotCluster
   put overlayArray_FromLinkArray (hKeyArray, pDotHeaderArray, pGraphPropertyArray, pKeyStyle) into overlayArray
   -- dispatch "graph_TidyOverlayArray" to pProcessObject with overlayArray
   
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", pGraphStyle
   overlayArray_SetGraphProperty overlayArray, "overlay_Name", pOverlayName
   -- overlayArray_SetGraphProperty overlayArray, "overlay_Of", pOverlayOf
   if pDotCluster is not empty then
      overlayArray_SetHeaderProperty overlayArray, "dot_ClusterRank", pDotCluster
   end if
   
   put overlayArray_ConstructDot (overlayArray, pOverlayName) into sDot
   return sDot
end dot_ConstructFromHkeyArray


--> HkeyArray
-
function hkeyArray_DepStackNames hkeyArray
   put hkeyArray_DepStacks (hkeyArray) into depStacks
   put stack_ObjectsToNames (stackObjects) into sNames
   return sNames
end hkeyArray_DepStackNames

function hkeyArray_DepStacks hkeyArray, sObject
   put revRuggedId (sObject) into sObject
   --
   put hkeyArray_GetStackDepArray (hkeyArray) into depStackData
   if exists (sObject) then
      delete variable depStackData [sObject]
   end if
   put keys (depStackData) into depStacks
   return depStacks
end hkeyArray_DepStacks

function hkeyArray_DepProjectBulletList hkeyArray, sObject
   put revRuggedId (sObject) into sObject
   
   # Construct depProjectData
   put hkeyArray_DepProjects (hkeyArray, sObject) into pNames
   
   # Make Tag Items
   put markdown_TagItems (pNames) into pNameBulletList
   --
   return pNameBulletList
end hkeyArray_DepProjectBulletList

function hkeyArray_DepStackBulletList hkeyArray, sObject
   put revRuggedId (sObject) into stackObject
   
   # Construct depProjectData
   put hkeyArray_GetStackDepArray (hkeyArray) into depStackData
   delete variable depStackData [stackObject]
   
   # Get Stack Names
   -- put stack_ObjectsToNames (stackObjects) into sNames
   repeat for each key stackObject in depStackData
      if exists (stackObject) is false then next repeat
      --
      put the short name of stackObject into sName
      put sName & CR after sNames 
   end repeat
   delete char -1 of sNames
   
   # Make Tag Items
   put markdown_TagItems (sNames) into sNameBulletList
   --
   return sNameBulletList
end hkeyArray_DepStackBulletList

function hkeyArray_DepProjects hkeyArray, sObject
   put revRuggedId (sObject) into sObject
   put hkeyArray_ConstructDepProjectData (hkeyArray, sObject) into depProjectData
   put keys (depProjectData) into depProjects
   return depProjects
end hkeyArray_DepProjects

function hkeyArray_ConstructDepProjectData hkeyArray, sObject
   put hkeyArray_GetProjectDepArray (hkeyArray) into depProjectData
   --
   put depProjectData into depData ["projectData"]
   if exists (sObject) then
      put the project_Name of sObject into projectName
      delete variable depProjectData [projectName]
   end if
   return depProjectData
end hkeyArray_ConstructDepProjectData

function hkeyArray_DisplayData hkeyArray, pShowHow, pStripMissing, pFirstHkey
   switch pShowHow
      case "depKeys"
         put hkeyArray_ListHkeys (hkeyArray, pFirstHkey) into hKeys
         filter hKeys with ("*Deps" & quote)
         return hKeys
         break
      case "hKeys"
         return hkeyArray_ListHkeys (hkeyArray, pFirstHkey)
      case "stacks"
         return hkeyArray_GetStackDepArray (hkeyArray)
      case "projects"
         return hkeyArray_GetProjectDepArray (hkeyArray, pStripMissing)
      default 
         return hkeyArray
   end switch
end hkeyArray_DisplayData

function hkeyArray_TidyMissing missingArray, pStripProps
   repeat for each key missingShortKey in missingArray
      put missingArray [missingShortKey] into ofHkeyArray
      repeat for each key ofHkey in ofHkeyArray
         hkeyLine_Deconstruct ofHkey, hName, hType, hObject
         put word 1 to 2 of missingShortKey into shortHkey
         --
         put char -1 of word 1 of missingShortKey is among the items of "G,S" into isProp
         if pStripProps is false AND isProp then next repeat
         --
         put empty into prettyMissingArray [hObject][shortHkey][ofHkey]
      end repeat
   end repeat
   --
   -- if pStripProps is true then hkeyArray_StripProps missingArray
   --
   return prettyMissingArray
end hkeyArray_TidyMissing

command hkeyArray_StripProps @missingArray
   repeat for each key shortMissingHkey in missingArray
      if char -1 of word 1 of shortMissingHkey is among the items of "G,S" then
         delete variable missingArray [shortMissingHkey]
      end if
   end repeat
end hkeyArray_StripProps


--> hKeyArray
-
function hkeyArray_GetProjectDepArray hkeyArray, pStripProps
   put hkeyArray_GetStackDepArray (hkeyArray) into sArray
   --
   put sArray ["Missing"] into missingArray
   delete variable sArray ["Missing"]
   --
   repeat for each key sObject in sArray
      if exists (sObject) is false then
         put sArray [sObject] into dArray ["Still Missing"][sObject]
      else
         put the project_Name of sObject into projectName
         put sArray [sObject] into dArray [projectName][sObject]
      end if
   end repeat
   --
   get hkeyArray_TidyMissing (missingArray, pStripProps)
   if it is an array then put it into dArray ["Missing"]
   --
   return dArray
end hkeyArray_GetProjectDepArray


--> Walk
-
function walk_GetObjectHkeyArray tObject, pSearchObjects, pUseExportedCalls
   put the revAvailableHandlers of tObject into hTable
   walk_SetSearchHierarchy pSearchObjects
   put _WalkAvailableHandlers (hTable) into hKeyArray
   return hKeyArray
end walk_GetObjectHkeyArray

function walk_GetHkeyArray hKey, pSearchObjects
   local hKeyArray
   walk_SetSearchHierarchy pSearchObjects
   walk_HkeyCalls hKeyArray, hKey
   return hKeyArray
end walk_GetHkeyArray

command walk_HkeyCalls @hKeyArray, hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   --
   put _GetHandlerCalls (shortHkey, hObject) into shortCallHkeys
   if shortCallHkeys is empty then
      put empty into hKeyArray [hKey]
   else
      repeat for each line shortCallHkey in shortCallHkeys 
         _WalkHkeyRecursive shortCallHkey, hKey, hKeyArray
      end repeat
   end if
end walk_HkeyCalls

function walk_GetSearchHierarchy
   return WalkSearchHierarchy
end walk_GetSearchHierarchy

command walk_SetSearchHierarchy pSearchObjects
   if pSearchObjects is empty then
      put env_ScriptHierarchy (true) into pSearchObjects
   end if
   --
   put pSearchObjects into WalkSearchHierarchy
end walk_SetSearchHierarchy


--> Private
-
private function _GetHandlerCalls hKeyLine, rObject
   if UseExportedCalls is true then
      breakpoint
      put hkey_FetchCalls (hKeyLine) into shortHkeyCalls
   else
      -- we get the revAvailableHandlers and script for each call
      -- may be possible to speed up by caching?
      -- put the handler_Calls [hKeyLine] of rObject into shortHkeyCalls
      
      put the revAvailableHandlers of rObject into hTable
      htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
      if endLineNum = 0 then return empty
      --
      put the script of rObject into someScript
      put line startLineNum to endLineNum of someScript into foundHandler
      
      -- this is too complex as it calculates hashes and all sorts (update needed)
      put handler_ExtractCalls (foundHandler) into shortHkeyCalls
   end if
   return shortHkeyCalls
end _GetHandlerCalls


--> Private | Walk
-
private function _WalkAvailableHandlers hTable
   local hKeyArray
   
   put revRuggedID (word 5 to -1 of line 1 of hTable) into hObject
   repeat for each line hTableLine in hTable
      set the cursor to busy
      put word 1 to 2 of hTableLine into shortHkey
      put hKeyLine_AddObject (shortHkey, hObject) into hKey
      walk_HkeyCalls hKeyArray, hKey
   end repeat
   return hKeyArray
end _WalkAvailableHandlers

private command _WalkHkeyRecursive shortHkey, parentHKeyLine, @hKeyArray
   -- first we look for it in WalkSearchHierarchy
   hkeyLine_Deconstruct parentHKeyLine, pName, pType, pObject
   --
   put hkey_FindShortHkey (shortHkey, pObject, WalkSearchHierarchy) into foundCall
   --
   if foundCall is empty then 
      put shortHkey && "of Missing" into missingCall
      put true into hKeyArray [parentHKeyLine][missingCall]
      return false
   end if
   
   -- add it to the array
   if hKeyArray [parentHKeyLine][foundCall] is true then return empty -- already indexed (don't recurse)
   put true into hKeyArray [parentHKeyLine][foundCall]
   
   -- now lets repeat and recurse for each call found
   hkeyLine_Deconstruct foundCall, fName, fType, fObject
   put _GetHandlerCalls (foundCall, fObject) into childShortHkeys
   repeat for each line childShortHkey in childShortHkeys
      set the cursor to busy
      _WalkHkeyRecursive childShortHkey, foundCall, hKeyArray
   end repeat
   --
   return true
end _WalkHkeyRecursive

private command _AddToObjectArray @hkeyObjectArray, hKey, parentHkey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   switch
      case char 1 to 3 of hName is "rig"
         put empty into hkeyObjectArray [revIgniter][hKey][parentHkey]
         break
      case hObject is "Missing"
      case hObject is empty
         put empty into hkeyObjectArray ["Missing"][hKey][parentHkey]
         break
      case parentHkey is empty
         put revRuggedID (hObject) into hObject
         if the keys of hkeyObjectArray [hObject] is empty then
            put empty into hkeyObjectArray [hObject][hKey]
         else
            -- put empty into hkeyObjectArray [hObject][hKey]["top"]
         end if
         break
      default
         put revRuggedID (hObject) into hObject
         put empty into hkeyObjectArray [hObject][hKey][parentHkey]
   end switch
end _AddToObjectArray
