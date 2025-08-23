script "lib_OldHkeyWalk"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_OldHkeyWalk
type: library
version: 0.1

/*
In this stack we organise the best tested and developed handlers that walk hkey dependency trees.
*/

--> Variables
-
local WalkSearchHierarchy
local AllowPrivateWithFirstObject = true
local UseExportedCalls = false


--> Walk | Old
-
getprop walk_Hierarchy
   put the long id of the target into tObject
   --
   if the module_Name of tObject is empty then
      put revRuggedID (tObject) into tObject
      put hierarchy_Construct (tObject) into walkHierarchy
      hierarchy_AddEnv walkHierarchy
   else
      put the module_BehaviorHierarchy of tObject into walkHierarchy
   end if
   return walkHierarchy
end walk_Hierarchy

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


--> Walk | Basics
-
private function _GetHandlerCalls hKeyLine, rObject
   -- htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum -- breaks as revAvailableHandlers has changed M/C
   put the revAvailableHandlers of rObject into hTable
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum -- should it be Either private or public?
   if endLineNum = 0 then return empty
   
   # Get handler
   put the script of rObject into someScript
   put line startLineNum to endLineNum of someScript into foundHandler
   
   # Check it is not to be skipped
   if the shiftkey is "Up" then
      switch
         case hName begins with "display_"
         case line 2 of foundHandler contains "-- component: true"
            return empty -- should do something so graph is styled to show component
      end switch
   end if
   
   # This is too complex as it calculates hashes and all sorts (update needed)
   put handler_ExtractCalls (foundHandler) into shortHkeyCalls
   return shortHkeyCalls
end _GetHandlerCalls

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


--> SearchHierarchy | Model
-
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
   put hkeyStackArray_From (hkeyArray) into hkeyDepArray
   return hkeyDepArray
end walk_DepArray

getprop walk_ModuleBehaviorHkeyArray [fromFolder]
   put the long id of the target into sObject
   --
   put the module_BehaviorHierarchy [fromFolder] of sObject into bSearchObjects
   put the walk_ScriptHkeyArray [bSearchObjects] of sObject into hkeyArray
   return hkeyArray
end walk_ModuleBehaviorHkeyArray


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
   put hkeyStackArray_From (hkeyArray) into depObjectData
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
   put hkeyStackArray_From (pHKeyArray) into depObjectData
   put depObjectData ["Missing"] into missingArray
   return missingArray
end dep_MissingArray

getprop dep_Stacks [pHKeyArray]
   put the long id of the target into sObject
   if pHKeyArray is not an array then
      put the walk_HkeyArray of sObject into pHKeyArray
   end if
   --
   put hkeyStackArray_From (pHKeyArray) into depObjectData
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
   put hkeyStackArray_From (hkeyArray) into depStackData
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
   put hkeyStackArray_From (hkeyArray) into depStackData
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


--> Walk
-
function walk_GetObjectHkeyArray tObject, pSearchObjects, pUseExportedCalls
   put the revAvailableHandlers of tObject into hTable
   walk_SetSearchHierarchy pSearchObjects
   put _WalkAvailableHandlers (hTable) into hKeyArray
   return hKeyArray
end walk_GetObjectHkeyArray


--> Private | Walk
-
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

