script "lib_HkeyObjectWalk"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_HkeyObjectWalk
type: library
version: 0.1

/*
See new lib_HkeyWalk

Here I'm dumping all the old object walk scripts. The better / most recent ones are at the top.

hkey_ObjectWalk uses old "hkey_FoundArrayFromSearchHierarchy" searching
"hkey_FoundArrayFromSearchHierarchy" uses the the object_Hierarchy of searching

== Text from libs ==
Library "model_Overlay" draws graphs using the data stored in arrays created by "deps_SaveMainstackAndExportArrays".
The main guts of the code is in "hkey_ObjectWalk", which uses "project_ConstructWalkArray" (a hArray walk which uses hArray_FindHkeyInHierarchy)
This is complicated hacked code with various filtering going on.

Then it walks missing handlers using "hkey_ObjectWalk"

Library "lib_DisplayGraph" it draws graphs using the data stored in arrays created by "deps_SaveMainstackAndExportArrays".
The main guts of the code is in "hkey_ObjectWalk", which uses "project_ConstructWalkArray" (a hArray walk which uses hArray_FindHkeyInHierarchy)
This is complicated hacked code with various filtering going on.

Then it walks missing handlers using "hkey_ObjectWalk"

*/


--> Working on
-


--> Hkey | DepArray
-
/*
These handlers are based around hkey_DepArrayFromObjects / hkey_ObjectWalkDeps walk which is good.
But we are now using 
*/

getprop script_HkeyArray2 [searchObjects]
   put the script_Hkeys of tObject into hKeys
   put the hkey_ScriptHierarchy [searchObjects] of tObject into searchObjects
   -- put hkey_SearchHierarchyDependencyArray (hKeys, searchObjects, true) into hKeyArray
   -- put hkey_DependencyArrayFromObjects (hKeys, pProjectName, true) into hKeyArray
   put hkey_DepArrayFromObjects (hKeys, searchObjects, true) into hKeyArray
   return hKeyArray
end script_HkeyArray2

function hkey_DepArrayFromObjects hKeys, pExternalObjects, pAllCalls
   local hKeyLinkArray, pFoundStackArray
   try  
      repeat for each line hKey in hkeys
         put handler_Get (hKey) into someHandler
         if pAllCalls is true then
            -- returns modern format
            put handler_ExtractCalls (someHandler) into shortCalls
         else
            put handler_ExtractFilteredCalls (someHandler) into shortCalls
         end if
         
         repeat for each line shortCall in shortCalls
            hkey_ObjectWalkDeps shortCall, hKey, hKeyLinkArray, pExternalObjects, pAllCalls, pFoundStackArray
         end repeat
      end repeat
      return hKeyLinkArray
   catch e -- script is locked
      return empty
   end try
end hkey_DepArrayFromObjects

command hkey_ObjectWalkDeps shortCall, hKey, @hKeyLinkArray, pExternalObjects, pAllCalls, pFoundStackArray
   -- same as "hkey_ObjectWalk" but with deps instead of projectName
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   
   hkey_Deconstruct shortCall, callName, callType, emptyCallObject, emptyCallNum
   
   put hkey_FindShortHkey (shortCall, hObject, pExternalObjects) into foundCall
   --
   switch
      case foundCall is empty
         put merge ("Call '[[shortCall]]' for handler '[[hKey]]' is missing!") into someMessage
         lcw_Notify someMessage, true
         
         put hkey_Construct (callName, callType, "missing", 1) into foundCall
         indexArray_Add foundCall, hKey, hKeyLinkArray
         return empty
      case foundCall is among the keys of hKeyLinkArray
         -- already indexed so no need to recurse
         return empty
   end switch
   
   -- add it to the array
   put merge ("Added [[foundCall]] to hKeyArray!") into someMessage
   lcw_Notify someMessage
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
      hkey_ObjectWalkDeps shortCall, foundCall, hKeyLinkArray, pExternalObjects, pAllCalls, pFoundStackArray
   end repeat
   return empty
end hkey_ObjectWalkDeps


--> hkey_DependencyArrayFromObjects
-
function hkey_DependencyArrayFromObjects hKeys, pProjectName, pAllCalls
   local hKeyLinkArray, pFoundStackArray
   try  
      repeat for each line hKey in hkeys
         put handler_Get (hKey) into someHandler
         if pAllCalls is true then
            -- returns modern format
            put handler_ExtractCalls (someHandler) into shortCalls
         else
            put handler_ExtractFilteredCalls (someHandler) into shortCalls
         end if
         
         repeat for each line shortCall in shortCalls
            hkey_ObjectWalk shortCall, hKey, hKeyLinkArray, pProjectName, pAllCalls, pFoundStackArray
         end repeat
      end repeat
      return hKeyLinkArray
   catch e -- script is locked
      return empty
   end try
end hkey_DependencyArrayFromObjects


--> Hkey | ObjectWalk | Old
-
command hkey_ObjectWalk shortCall, hKey, @hKeyLinkArray, pProjectName, pAllCalls, pFoundStackArray
   -- new version that incrementally adds stacks to search using "hkey_FindAndAdd"
   -- see "lib_HarrayWalk"
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   hkey_Deconstruct shortCall, callName, callType, emptyCallObject, emptyCallNum
   
   put hkey_FindAndAdd (shortCall, hObject, pFoundStackArray, pProjectName) into foundCall
   
   -- this could be filtered out at the end
   -- if _foundUselessCall (foundCall) is true then return empty -- should do something else
   
   switch
      case foundCall is empty
         put merge ("Call '[[shortCall]]' for handler '[[hKey]]' is missing!") into someMessage
         lcw_Notify someMessage, true
         
         put hkey_Construct (callName, callType, "missing", 1) into foundCall
         indexArray_Add foundCall, hKey, hKeyLinkArray
         return empty
      case foundCall is among the keys of hKeyLinkArray
         -- already indexed so no need to recurse
         return empty
   end switch
   
   -- add it to the array
   put merge ("Added [[foundCall]] to hKeyArray!") into someMessage
   lcw_Notify someMessage
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
      hkey_ObjectWalk shortCall, foundCall, hKeyLinkArray, pProjectName, pAllCalls, pFoundStackArray
   end repeat
   return empty
end hkey_ObjectWalk

function hkey_FindAndAdd shortHKey, tObject, @foundStackArray, pProjectName
   hkey_Deconstruct shortHKey, hName, hType, xObject, xNum
   
   -- let's just add used (forget behaviors of libs for now)
   put the object_Hierarchy of tObject into objectHierarchy
   
   --  put project_ListUsedStacks (pProjectName) into usedProjectStacks
   if pProjectName is empty then
      repeat for each line stackName in the stacksinUse
         put the name of stack stackName & CR after usedProjectDepStacks
      end repeat
      delete char -1 of usedProjectDepStacks
   else
      put project_ListUsedDeps (pProjectName) into usedProjectDepStacks
   end if
   put keys (foundStackArray) into foundStacks
   
   put objectHierarchy into searchHierarchy
   
   -- let's add the ones already found first
   if foundStacks is not empty then
      -- should delete duplicate lines in searchHierarchy
      put foundStacks & CR before searchHierarchy
   end if
   
   if usedProjectDepStacks is not empty then
      -- should delete duplicate lines in searchHierarchy
      put usedProjectDepStacks & CR before searchHierarchy
   end if
   
   -- put searchHierarchy
   
   put hkey_FoundArrayFromSearchHierarchy (hName, hType, shortHKey, tObject, searchHierarchy) into foundArray
   put foundArray ["foundHkey"] into foundHkey
   
   if foundHkey is not empty then
      -- let's add it to found stacks to be added to hierarchy
      hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
      if word 1 of fObject = "stack" then
         put the project_Name of fObject into foundProjectName
         put foundProjectName into foundStackArray [fObject]
      else
         -- breakpoint
      end if
   end if
   return foundHkey
end hkey_FindAndAdd

function hkey_FoundArrayFromSearchHierarchy hName, hType, shortHKey, tObject, searchHierarchy
   put the long id of tObject into tObject
   repeat with lineNum = the number of lines of searchHierarchy down to 1
      put line lineNum of searchHierarchy into hierarchyObject
      put the revAvailableHandlers of hierarchyObject into handlerTable
      
      if the long id of hierarchyObject = tObject and char 1 of hType is not "p" then -- if looking for private skip
         -- look for private handlers first (ideally should get the first version?)
         put "p" & hType into privateHype
         put hName,privateHype into privateShortKey
         hTable_FlexibleLineOffsets privateShortKey, handlerTable, startLineNum, endLineNum
         if the result is true then
            put handlerTable into foundArray ["handlerTable"]
            put startLineNum into foundArray ["startLineNum"]
            put endLineNum into foundArray ["endLineNum"]
            put hkey_Construct (hName, privateHype, hierarchyObject) into foundArray ["foundHkey"]
            return foundArray
         else
            hTable_FlexibleLineOffsets shortHkey, handlerTable, startLineNum, endLineNum
            if the result is true then
               put handlerTable into foundArray ["handlerTable"]
               put startLineNum into foundArray ["startLineNum"]
               put endLineNum into foundArray ["endLineNum"]
               put hkey_Construct (hName, hType, hierarchyObject) into foundArray ["foundHkey"]
               return foundArray
            end if
         end if
      else
         hTable_FlexibleLineOffsets shortHkey, handlerTable, startLineNum, endLineNum
         if the result is true then
            put handlerTable into foundArray ["handlerTable"]
            put startLineNum into foundArray ["startLineNum"]
            put endLineNum into foundArray ["endLineNum"]
            put hkey_Construct (hName, hType, hierarchyObject) into foundArray ["foundHkey"]
            return foundArray
         end if
      end if
   end repeat
   return empty
end hkey_FoundArrayFromSearchHierarchy


--> Deps
-
/*
--> Hkey | Walk | Object
-
function hkey_DependencyArrayFromObjects hKeys, pSetName, pAllCalls
   local hKeyLinkArray
   try  
      repeat for each line hKey in hkeys
         put handler_Get (hKey) into someHandler
         if pAllCalls is true then
            put handler_ExtractCalls (someHandler) into shortCalls -- returns modern format
         else
            put handler_ExtractFilteredCalls (someHandler) into shortCalls -- returns modern format
         end if
         
         repeat for each line shortCall in shortCalls
            hkey_ObjectWalk shortCall, hKey, hKeyLinkArray, pSetName, pAllCalls
         end repeat
      end repeat
      return hKeyLinkArray
   catch e -- script is locked
      return empty
   end try
end hkey_DependencyArrayFromObjects

command hkey_ObjectWalk shortCall, hKey, @hKeyLinkArray, pSetName, pAllCalls
   -- see "lib_HarrayWalk"
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   hkey_Deconstruct shortCall, callName, callType, emptyCallObject, emptyCallNum
   --
   put hkey_FindShortHkey (shortCall, hObject) into foundCall
   --
   switch
      case foundCall is empty
         put merge ("Call '[[shortCall]]' for handler '[[hKey]]' is missing!") into someMessage
         lcw_Notify someMessage, true
         
         put hkey_Construct (callName, callType, "missing", 1) into foundCall
         indexArray_Add foundCall, hKey, hKeyLinkArray
         return empty
      case foundCall is among the keys of hKeyLinkArray
         -- already indexed so no need to recurse
         return empty
   end switch
   
   -- add it to the array
   put merge ("Added [[foundCall]] to hKeyArray!") into someMessage
   lcw_Notify someMessage
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
      hkey_ObjectWalk shortCall, foundCall, hKeyLinkArray, pSetName, pAllCalls
   end repeat
   return empty
end hkey_ObjectWalk
*/
