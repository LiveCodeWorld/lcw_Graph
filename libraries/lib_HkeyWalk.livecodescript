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


--> Working on
-
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
   put hkeyArray_GetDepArray (hkeyArray) into sArray
   --
   put sArray ["Missing"] into missingArray
   delete variable sArray ["Missing"]
   --
   repeat for each key sObject in sArray
      if exists (sObject) is false then
         breakpoint
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

function hkeyArray_GetDepArray hkeyArray, pStripProps
   local hkeyDepArray
   hkeyArray_SetObjectArray hkeyDepArray, hkeyArray
   --
   /*
   put hkeyDepArray ["Missing"] into missingArray
   if missingArray is an array then
      get hkeyArray_TidyMissing (missingArray, pStripProps)
      if it is an array then
         put it into hkeyDepArray ["Missing"]
      end if
   end if
   */
   --
   return hkeyDepArray
end hkeyArray_GetDepArray

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


--> Props
-
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

getprop walk_DepArray [pHkey]
   put the walk_HkeyArray [hKey] of the target into hkeyArray
   put hkeyArray_GetDepArray (hkeyArray) into hkeyDepArray
   return hkeyDepArray
end walk_DepArray

getprop walk_HkeyArray [hKey]
   put the long id of the target into tObject
   put the walk_Hierarchy of tObject into searchObjects
   put false into UseExportedCalls
   walk_SetSearchHierarchy searchObjects
   
   local hKeyArray
   --
   if hKey is empty then
      put the revAvailableHandlers of tObject into hTable
      put _WalkAvailableHandlers (hTable) into hKeyArray
   else
      _WalkHkeyRecursive shortCallHkey, hKey, hKeyArray
   end if
   --
   return hKeyArray
end walk_HkeyArray

getprop walk_Hierarchy
   -- as comprehensive as possible version of object_Hierarchy
   put the long id of the target into tObject
   put revRuggedID (tObject) into tObject
   --
   put object_GetHierarchy (tObject) into walkHierarchy
   put env_ScriptHierarchy (true) into envHierarchy
   if envHierarchy is empty then return walkHierarchy
   
   _StripObjectHierarchy envHierarchy, walkHierarchy
   if envHierarchy is empty then return walkHierarchy
   
   put CR & envHierarchy after walkHierarchy
   return walkHierarchy
end walk_Hierarchy


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

private command _AddObjectAndBehaviors @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return empty
   
   if pPretty is not false then
      -- put the long id of tObject into tObject
      put CR & the name of tObject after objectHierarchy
   else
      put CR & revRuggedId (tObject) after objectHierarchy
   end if
   
   put the behavior_Objects of tObject into bObjects
   if bObjects is empty then return false
   put CR & bObjects after objectHierarchy
   return true
end _AddObjectAndBehaviors

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
         put "top" into parentHkey
      default
         put revRuggedID (hObject) into hObject
         put empty into hkeyObjectArray [hObject][hKey][parentHkey]
   end switch
end _AddToObjectArray

private command _StripObjectHierarchy @externalObjects, objectHierarchy
   set the wholematches to true
   repeat for each line sObject in objectHierarchy
      put lineOffset (sObject, externalObjects) into lineNum
      delete line lineNum of externalObjects
   end repeat
end _StripObjectHierarchy


--> Deps
-
function object_GetHierarchy tObject, pPretty
   local objectHierarchy
   
   put the long id of tObject into tObject
   put pPretty is not false into pPretty
   _AddObjectAndBehaviors objectHierarchy, tObject, pPretty
   
   put tObject into objectOwner
   put empty into skipThisBackgroundID
   repeat
      switch word 1 of objectOwner
         case "stack"
            -- previously added a stack, check if it was a substack
            put objectOwner into stackObject
            put the owner of stackObject into mainStackObject
            if exists (mainStackObject) then
               _AddObjectAndBehaviors objectHierarchy, mainStackObject, pPretty
            end if
            
            delete word 1 to 3 of objectOwner
            if exists (objectOwner) is false then exit repeat
            break
         case "card"
            -- previously added a card, so check for backgrounds
            put objectOwner into cardObject
            put the backgroundIDs of cardObject into bgIDs
            -- need to add in reverse to mirror message path
            repeat with bgNum = the number of lines of bgIDs down to 1
               put line bgNum of bgIDs into someID
               if someID = skipThisBackgroundID then next repeat
               put the long ID of bg ID someID of cardObject into backgroundObject
               _AddObjectAndBehaviors objectHierarchy, backgroundObject
            end repeat
            
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            
            -- above a card must be a stack
            _AddObjectAndBehaviors objectHierarchy, stackObject
            break
         case "group"
            -- previously added a group, check to see if was a bg
            if the backgroundbehavior of objectOwner is true then
               -- will need to skip it's own "card" background
               put the short ID of objectOwner into skipThisBackgroundID
            end if
            --
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
            break
         default
            -- previously added a normal control
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
      end switch
   end repeat
   return word 1 to -1 of objectHierarchy
end object_GetHierarchy
