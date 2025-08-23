script "model_Harray"
--> MetaData
-
license: GPLv3
name: model_Harray
type: model
version: 0.8

/*
This model wraps a complex multidimensional array that stores lot's of information about scripts, handlers and objects in the Livecode environment.
It is mistakenly labeled and stored in the global variable gLCW. It should ratehr be called gHarray (for "handler array" or simply gLiveCodeWorld.

Most of the handelrs here have been designed to work with parameters rather than directly with the global variable.
In the future we look to store this data in an sqlite, or possible graph database.
*/


--> hArray | Model
-
/*
New from "model_TextStack".
Need to tidy and remove old handlers in the section below "--> Working on"
*/

command hArray_LoadGlobal
   global gHkey_Array
   put hArray_FetchData() into gHkey_Array
end hArray_LoadGlobal

command hArray_StoreGlobal
   global gHkey_Array
   hArray_StoreData gHkey_Array
end hArray_StoreGlobal

function hArray_FetchData
   put lcw_FetchArray ("Hkey_Data.array") into hArray
   return hArray
end hArray_FetchData

command hArray_StoreData hArray
   lcw_StoreArray "Hkey_Data.array", hArray
end hArray_StoreData

command hArray_DeleteArrayDatabase
   global gHkey_Array
   delete variable gHkey_Array
end hArray_DeleteArrayDatabase


--> Project | hArray | Model
-
/*
Should change this to store it somewhere sensible
Like the lcw_User folder?
*/

function project_FetchHarray
   put lcw_FetchArray ("Hkey_Data.array") into hArray
   return hArray
end project_FetchHarray

command project_SaveHarray hArray
   lcw_StoreArray "Hkey_Data.array", hArray
   put the result into arrayFile
   return arrayFile
end project_SaveHarray


--> Working on
-
/*
Old hArray way of doing things (a bit brittle)

Not needed in this library except for compatability.
It is a powerful and flexib;e way of naming things though.

Below are the key handlers for updateing the index.
*/

command script_UpdateHarrayAndExport scriptObject, pExportHandlersAndCalls
   /*
   This does the older full version of updating hArray
   */
   menu_DeleteActiveArray

   if pExportHandlersAndCalls is empty then put false into pExportHandlersAndCalls
   put pExportHandlersAndCalls is true into createHashArray
   put false into forceIndexHandlerCalls
   try
      put the script of scriptObject into someScript
   catch e
      return merge ("error, [[scriptObject]] is probably a locked stack so can't index script.")
   end try

   -- update the extensive metadata stored in gLCW
   lcw_ExportAndAddScriptToHarray gLCW, scriptObject, someScript, createHashArray, forceIndexHandlerCalls, pExportHandlersAndCalls
   put the result into scriptFile
   set the menu_Update of scriptObject to true
   put the result into mTitleTableArray

   -- let's set the uRipArray (this will be lost for script-only stacks)
   script_UpdateUrip scriptObject, someScript
   return scriptFile
end script_UpdateHarrayAndExport

command script_UpdateUrip scriptObject, someScript
   -- with script only stacks as these changes will not be stored
   put script_GetMetadataArray (someScript) into uRIPArray
   delete local uRIPArray ["date"]
   set the urip_Array of scriptObject to uRipArray
   return uRipArray
end script_UpdateUrip

command lcw_ExportAndAddScriptToHarray @hArray, someObject, someScript, pCreateHashArray, pForceIndexHandlerCalls, pExportHandlersAndCalls
   -- new version
   if pExportHandlersAndCalls is true then
      -- here we can export the script
      object_ExportScript someObject, someScript, pExportHandlersAndCalls, false
      put the result into scriptFile
      file_StripHome scriptFile
   else
      put the dataObject_Folder [true] of someObject into dataFolder
      put textStack_ScriptFile (dataFolder) into scriptFile
   end if

   -- this add to hArray without exporting anything
   lcw_AddScriptToHarray hArray, someObject, someScript, scriptFile, pCreateHashArray, pForceIndexHandlerCalls, pExportHandlersAndCalls
end lcw_ExportAndAddScriptToHarray

--> Update | hArray
-
command lcw_AddScriptToHarray @hArray, someObject, someScript, scriptFile, pCreateHashArray, pForceIndexHandlerCalls
   if pCreateHashArray is not true then
      delete variable hArray ["handlerHashArray"]
   end if

   put the stack_Object of someObject into stackObject
   put the mainstack of stackObject into mainStackName
   put the name of stack mainStackName into ruggedMainStack
   put the filename of stack mainStackName into stackFile
   file_StripHome stackFile

   put the rugged_ID of someObject into ruggedObject

   put the ticks into indexTime
   put sha1_Hash (someScript) into scriptHash

   put script_GetMetadataArray (someScript) into objectMetaData
   put the customproperties ["uRIP"] of someObject into uRipArray
   union objectMetaData with uRipArray

   -- first let's delete any old entries for this object
   hArray_RemoveObjectFromArray ruggedObject, hArray, uRipArray
   delete variable hArray ["scriptArray"][ruggedObject]

   -- now let's index object types
   put objectMetaData ["type"] into uRipType
   if uRipType is not empty then
      put objectMetaData ["name"] into uRipName
      -- with the info below you can get rugged_IDs fast, and hkeys in them pretty fast
      -- after this you can use the hKey to get handler info from the "handlerArray" below
      if uRipType = "view" and the view_IsTemplate of someObject is true then
         put "view template" into uRipType
      end if
      put scriptHash into hArray ["objectType"][uRipType][ruggedObject]["scriptHash"]
      put objectMetaData ["name"] into hArray ["objectType"][uRipType][ruggedObject]["uRipName"]
   end if

   -- Add script details to object metadata
   put scriptHash into hArray ["scriptArray"][ruggedObject]["metadata"]["sha1"]

   put objectMetaData into hArray ["scriptArray"][ruggedObject]["metadata"]["uripArray"]
   put scriptFile into hArray ["scriptArray"][ruggedObject]["metadata"]["scriptFile"]
   put stackFile into hArray ["scriptArray"][ruggedObject]["metadata"]["stackFile"]
   put ruggedMainStack into hArray ["scriptArray"][ruggedObject]["metadata"]["main stack object"]
   put indexTime into hArray ["scriptArray"][ruggedObject]["metadata"]["indexTime"]

   -- index any behaviors
   put the behavior of someObject into behaviorObject
   if behaviorObject is not empty then
      put scriptHash into hArray ["behaviorArray"][behaviorObject]["data"]["object"][ruggedObject]["scriptHash"]
   end if

   -- fast and simple (to get comments and metadata will need to process later
   put false into pIsExpanded
   local suiteTitle
   put 1 into indexNum
   put 1 into lineNum

   -- same logic as "the script_Array"
   put false into commentBlock
   repeat with lineNum = 1 to the number of lines of someScript
      put line lineNum of someScript into scriptLine
      switch
         case word 1 of scriptLine = "/*"
            put true into commentBlock
            break
         case commentBlock is true
            -- keep looping till end of block
            if word -1 of scriptLine = "*/" then
               -- could put this commented out section in the index?
               put false into commentBlock
            end if
            break
         case word 1 of scriptLine = "-->"
            put word 2 to -1 of scriptLine into suiteTitle

            put "t" into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["lineType"]
            put lineNum into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["startLineNum"]
            put suiteTitle into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["scriptLine"]
            put pIsExpanded into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["isExpanded"]

            add 1 to indexNum
            break
         case word 1 of scriptLine is among the items of "command,on,function,getprop,setprop,private"
            put true into indexingHandler

            if word 1 of scriptLine is "private" then
               put "p" into pBit
               delete word 1 of scriptLine
            else
               put empty into pBit
            end if

            get char 1 of scriptLine
            if it = "o" then
               put true into isOnMessage
               put pBit & "c" into lineType
            else
               put false into isOnMessage
               put pBit & it into lineType
            end if

            put word 2 of scriptLine into hName

            put countArray [hName][lineType] into hNum
            add 1 to hNum
            put hNum into countArray [hName][lineType]

            put hName,lineType into shortHKey
            put shortHKey,ruggedObject,hNum into hKey
            put lineNum into startLineNum

            put hKey into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["hKey"]
            put lineType into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["lineType"]
            put suiteTitle into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["suiteTitle"]
            put pIsExpanded is true into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["isExpanded"]
            put startLineNum into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["startLineNum"]

            put scriptLine into startScriptLine
            put startScriptLine into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["handlerLine"]

            break
         case word 1 of scriptLine = "end" and word 2 of scriptLine = hName and indexingHandler is true
            put false into indexingHandler
            put lineNum into endLineNum

            put endLineNum into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["endLineNum"]

            put line startLineNum to endLineNum of someScript into someHandler
            put sha1_Hash (someHandler) into handlerHash
            put handlerHash into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["sha1"]

            -- too slow
            if pCreateHashArray is true then
               -- this is slow
               -- here we check to see if the handlerHash already exists for that mainstack object
               -- this only happens if hArray ["handlerHashArray"] is added to hArray before walking
               -- this can be initialised by adding a previously stored handlerHashArray from disk
               -- or simply doing something like 'put empty into hArray ['"handlerHashArray"]["new"]'

               hArray_AddHandlerHash hArray, hKey, someHandler, handlerHash, indexTime, pForceIndexHandlerCalls
               put the result into handlerCallArray
               handler_ExportCalls shortHkey, scriptFile, handlerCallArray, pCreateHashArray, pForceIndexHandlerCalls

               put empty into hArray ["handlerHashArray"]["actual"][handlerHash]
            end if

            -- now index unique global suites
            if word -1 of suiteTitle = "Menu" and word -2 of suiteTitle = "|" then
               -- it's a menu
               _addMenuToHarray hArray, suiteTitle, shortHkey, ruggedObject, ruggedMainStack, isOnMessage, lineType, handlerHash, scriptHash, shortkeySuiteArray, thisScriptsMenuArray
            end if

            -- now index first (not last!) hKeys of object
            if hArray ["scriptArray"][ruggedObject]["data"]["firstHKeyArray"][shortHKey]["sha1"] is empty then
               -- only index first handler with this array
               put handlerHash into hArray ["scriptArray"][ruggedObject]["data"]["firstHKeyArray"][shortHKey]["sha1"]

               -- only firstHkeys can ever get called so only these go in handlerArray
               put startScriptLine into hArray ["handlerArray"][shortHKey][hKey]["scriptLine"]
               put handlerHash into hArray ["handlerArray"][shortHKey][hkey]["handlerHash"]
               put startLineNum into hArray ["handlerArray"][shortHKey][hKey]["startLineNum"]
               put endLineNum into hArray ["handlerArray"][shortHKey][hkey]["endLineNum"]

               -- now let's extract keywords and index shortHkey against each (no point doing it for non first Hkeys
               -- hkey_AddToKeyWordArray hArray, hKey, handlerHash -- could index twice with same hash in different places
            end if

            add 1 to indexNum
            break
         case token 1 of scriptLine is empty
            -- it's a comment or some junk
            -- however script suites are also comments (so put at end of tests)!
            -- not actually needed
            break
         default
            /*
            should modify to collect stuff here, and add to metadata outside of handlers
            */
      end switch
   end repeat

   return scriptFile
end lcw_AddScriptToHarray

private command handler_ExportCalls shortHkey, scriptFile, handlerCallArray, pCreateHashArray, pForceIndexHandlerCalls
   if pCreateHashArray is true or pForceIndexHandlerCalls is true then
      -- put handlerCallArray ["filteredCalls"] into shortCalls
      put handlerCallArray ["hkeyCalls"] into shortCalls

      -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/script.txt
      put scriptFile into dataFolder
      set the itemdelimiter to slash
      put empty into item -1 of dataFolder
      put textStack_ConstructCallsFile (shortHkey, dataFolder) into callsFile
      text_Set callsFile, shortCalls

      _DisplayIndexedCallsComment shortHkey, shortCalls
   end if
end handler_ExportCalls

command hArray_AddHandlerHash @hArray, hKey, someHandler, handlerHash, indexTime, pForceindex
   -- does not export handlers
   -- uses "handler_ConstructCallArray" and "lcw_Notify" and "outline_IncreaseIndent" for progress monitoring
   -- we could add to an hKeyArray here? But can't use hArray to find calls in hierarchy as it is in progress of being built

   put hArray ["handlerHashArray"]["cached"][handlerHash]["hashTime"] is not empty into alreadyIndexed

   -- let's get the old handler hash and delete the old entry
   put hArray_GetHandlerHash (hKey, hArray) into oldHandlerHash
   if oldHandlerHash is not handlerHash then
      delete variable hArray ["handlerHashArray"]["cached"][oldHandlerHash]
      delete variable hArray ["handlerHashArray"]["new"][oldHandlerHash]
   end if

   -- add hKey to list of hkeys with same handler(hash)
   put empty into hArray ["handlerHashArray"]["cached"][handlerHash]["hKey"][hKey]

   if alreadyIndexed is false or pForceindex is true then
      -- if new (handlerHash) entry extract calls and add to index
      put indexTime into hArray ["handlerHashArray"]["cached"][handlerHash]["hashTime"]

      -- now let's extract keywords and index shortHkey against each (no point doing it for non first Hkeys
      hkey_AddToKeyWordArray hArray, hKey, handlerHash

      -- this is VERY slow
      put handler_ConstructCallArray (someHandler) into handlerCallArray
      put handlerCallArray ["filteredCalls"] into shortCalls
      put handlerCallArray ["hkeyCalls"] into allShortCalls

      put shortCalls into hArray ["handlerHashArray"]["cached"][handlerHash]["shortCalls"]
      put allShortCalls into hArray ["handlerHashArray"]["cached"][handlerHash]["allShortCalls"]

      return handlerCallArray
   else
      -- put "Already Indexed" && kwote (hKey) into someComment
      return empty
   end if
end hArray_AddHandlerHash


--> Update | lcw_ExportAndAddScriptToHarray | Deps
-
private command _DisplayIndexedCallsComment hKey, shortCalls
   put "Indexed" && kwote (hKey) into someComment
   if shortCalls is not empty then
      put CR & CR & "With the following calls to other handlers:" after someComment
      -- put CR & outline_IncreaseIndent (shortCalls, 4, space) after someComment
      put shortCalls
   end if
   lcw_Notify someComment
end _DisplayIndexedCallsComment

private command _addMenuToHarray @hArray, suiteTitle, shortHkey, ruggedObject, ruggedMainStack, isOnMessage, lineType, handlerHash, scriptHash, @shortkeySuiteArray, @thisScriptsMenuArray
   switch
      case word 1 of suiteTitle = "Global" and word 2 of suiteTitle = "|"
         menu_AddGlobalHarray suiteTitle, shortHkey, ruggedObject, handlerHash, isOnMessage, lineType, thisScriptsMenuArray, hArray
         break
      default
         menu_AddLocalHarray suiteTitle, shortHkey, ruggedObject, ruggedMainStack, handlerHash, scriptHash, isOnMessage, lineType, thisScriptsMenuArray, hArray
   end switch
end _addMenuToHarray

private command menu_AddLocalHarray suiteTitle, shortHkey, ruggedObject, ruggedMainStack, handlerHash, scriptHash, isOnMessage, lineType, @thisScriptsMenuArray, @hArray
   -- store local menu with the mainstack section of the array

   if ruggedMainStack is not among the keys of thisScriptsMenuArray then
      delete variable hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"]
      put empty into thisScriptsMenuArray [ruggedMainStack]
   end if

   put ruggedObject into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["mController"]
   put scriptHash into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["scriptHash"]

   if isOnMessage is true and lineType = "c" then
      put hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["item"] into shortkeySuiteArray
      if shortkeySuiteArray is not an array then
         put 1 into itemNum
      else
         put (the number of elements of shortkeySuiteArray) + 1 into itemNum
      end if

      put shortHkey into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["item"][itemNum]["shortHkey"]
      put handlerHash into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["item"][itemNum]["sha1"]
   end if
end menu_AddLocalHarray

private command menu_AddGlobalHarray suiteTitle, shortHkey, ruggedObject, handlerHash, isOnMessage, lineType, @thisScriptsMenuArray, @hArray
   -- updates hArray ["Global Menus"][suiteTitle]

   if suiteTitle is not among the keys of thisScriptsMenuArray then  -- a new global menu for this script
      delete variable hArray ["Global Menus"][suiteTitle]
      put empty into thisScriptsMenuArray [suiteTitle]
   end if

   put ruggedObject into hArray ["Global Menus"][suiteTitle]["mController"]
   if isOnMessage is true and lineType = "c" then
      put hArray ["Global Menus"][suiteTitle]["item"] into shortkeySuiteArray
      if shortkeySuiteArray is not an array then
         put 1 into itemNum
      else
         put (the number of elements of shortkeySuiteArray) + 1 into itemNum
      end if
      put shortHkey into hArray ["Global Menus"][suiteTitle]["item"][itemNum]["shortHkey"]
      put handlerHash into hArray ["Global Menus"][suiteTitle]["item"][itemNum]["sha1"]
   end if
end menu_AddGlobalHarray

command hkey_AddToKeyWordArray @hArray, hKey, handlerHash
   put hkey_ConstructKeywords (item 1 of hKey) into kWords
   put item 1 to 2 of hKey into shortHKey
   repeat for each line kWord in kWords
      put handlerHash into hArray ["keywordArray"][kWord][shortHKey]["sha1"]
      put item 3 of hKey into hObject
      if hObject is not empty then put hObject into hArray ["keywordArray"][kWord][shortHKey]["rugged_ID"]
   end repeat
end hkey_AddToKeyWordArray


--> Not needed
-
command object_AddToGlobalArray someObject, pExportHandlers, pCreateHashArray
   -- also exports handlers
   global gLCW
   try
      put the script of someObject into someScript
   catch e
      return merge ("error, [[someObject]] is probably a locked stack so can't index script.")
   end try
   lcw_ExportAndAddScriptToHarray gLCW, someObject, someScript, pCreateHashArray, false, false
   put the result into scriptFile
   return someScript
end object_AddToGlobalArray

-- command export_Script pAutoCommit, pObject
-- older check and update ?
-- same as when pressing compile, so may do other fancy stuff liek index menus
if pObject is empty then put the long id of the target into pObject
put the script of pObject into someScript
set the exported_Script [pAutoCommit] of pObject to someScript
put the result into scriptFile
return scriptFile
end export_Script

-- command ide_ExportAndIndex scriptObject
-- let's not export if the stack is not saved to disk
put the stack_Object of scriptObject into stackObject
put the mainstack of stackObject into mainStackName
put the filename of stack mainStackName into someFile
if someFile is empty then
   put merge ("Not exporting or indexing as scriptObject has no filename and is not saved anywhere!")
   return false
end if

-- export
script_UpdateHarrayAndExport scriptObject, true
put the result into scriptFile

put the name of scriptObject into cName
lcw_Notify merge ("Exported and indexed script of cName")
return scriptFile
end ide_ExportAndIndex


--> hArray | Old
-
function scriptEditor_GetBehaviorButton bName
   put hArray_GetNamedObjectType (bName, "behavior") into behaviorButton
   return behaviorButton
end scriptEditor_GetBehaviorButton


--> hArray | Model
-
command hArray_LoadGlobal
   global gLCW
   put hArray_FetchData() into gLCW
end hArray_LoadGlobal

command hArray_StoreGlobal
   global gLCW
   hArray_StoreData gLCW
end hArray_StoreGlobal

command hArray_DeleteArrayDatabase
   global gLCW
   delete variable gLCW
end hArray_DeleteArrayDatabase

function hArray_FetchData
   put lcw_FetchArray ("Hkey_Data.array") into hArray
   return hArray
end hArray_FetchData

command hArray_StoreData hArray
   lcw_StoreArray "Hkey_Data.array", hArray
end hArray_StoreData


--> hArray
-
function hArray_ConstructHkeySuiteArray mainstackHarray
   local scriptObjectSuiteArray
   put mainstackHarray ["scriptArray"] into rObjectArray
   repeat for each key rObject in rObjectArray
      put rObjectArray [rObject]["data"]["script_DataArray"] into scriptDataArray

      repeat for each key indexNum in scriptDataArray
         put scriptDataArray [indexNum]["hkey"] into hKey
         if hKey is empty then next repeat
         put scriptDataArray [indexNum]["suiteTitle"] into suiteTitle
         if suiteTitle is empty then put "No Suite Title" into suiteTitle
         put item 2 of extents (scriptObjectSuiteArray [rObject]["suite"][suiteTitle]["data"]) + 1 into handlerInSuiteNum
         put empty into scriptObjectSuiteArray [rObject]["suite"][suiteTitle]["data"][handlerInSuiteNum][hKey]
      end repeat
   end repeat
   return scriptObjectSuiteArray
end hArray_ConstructHkeySuiteArray


--> Harray | Handler
-
function hArray_GetHandler hKey, pHarray, pCheckHash
   put item 3 of hKey into hObject
   if exists (hObject) is false then
      breakpoint
      return empty
   end if
   try
      put the script of hObject into someScript
   catch e
      lcw_Notify (hObject && "script is locked!"), true
      return empty
   end try

   put hArray_GetObjectData (hObject, "script_DataArray", pHarray) into scriptArray
   repeat for each key indexNum in scriptArray
      put scriptArray [indexNum]["hkey"] into testHkey
      if testHkey = hKey then
         put scriptArray [indexNum]["startLineNum"] into startLineNum
         put scriptArray [indexNum]["endLineNum"] into endLineNum
         put line startLineNum to endLineNum of someScript into someHandler
         switch
            case pCheckHash is not false
               return someHandler
            case sha1_Hash (someHandler) = scriptArray [indexNum]["sha1"]
               return someHandler
            default
               return empty
         end switch
      end if
   end repeat
   -- breakpoint -- should re-index and try again
   return empty
end hArray_GetHandler


--> Script | Array
-
function hArray_ConstructScriptArray someScript, someObject, pIndexSuites, pIsExpanded
   -- does the same as script_ConstructArray
   object_AddToGlobalArray someObject, pIsExpanded
   put the object_ScriptDataArray of someObject into dataArray
   if pIndexSuites is false then
      hArray_StripSuitesFromScriptDataArray dataArray
   end if
   return dataArray
end hArray_ConstructScriptArray

command hArray_StripSuitesFromScriptDataArray @dataArray
   repeat for each key indexNum in dataArray
      put dataArray [indexNum]["hKey"] into hKey
      if hKey is empty then
         delete dataArray [indexNum]["hKey"]
      end if
   end repeat
end hArray_StripSuitesFromScriptDataArray


--> hArray | Object | Types
-
function hArray_ListFrontLibraries
   put hArray_ListObjectsOfType ("frontscript") into rObjects
   return rObjects
end hArray_ListFrontLibraries

function hArray_ListBackLibraries
   put hArray_ListObjectsOfType ("backscript") into rObjects
   return rObjects
end hArray_ListBackLibraries

function hArray_ListUsedLibraries
   put hArray_ListObjectsOfType ("library") into rObjects
   return rObjects
end hArray_ListUsedLibraries

function hArray_ListViews
   put hArray_ListObjectsOfType ("view") into rObjects
   return rObjects
end hArray_ListViews

function hArray_ListViewTemplates
   put hArray_ListObjectsOfType ("view template") into rObjects
   return rObjects
end hArray_ListViewTemplates

function hArray_ListModels
   put hArray_ListObjectsOfType ("model") into rObjects
   return rObjects
end hArray_ListModels

function hArray_GetNamedObjectType viewName, objectType
   put hArray_GetObjectTypeArray (objectType) into typeArray
   repeat for each key rObject in typeArray
      put hArray_GetUripArray (rObject, "name") into objectViewName
      if objectViewName = viewName then
         return rObject
      end if
   end repeat
   return empty
end hArray_GetNamedObjectType

function hArray_ConstructTypeNameObjectArray
   local typeNameObjectArray
   put hArray_GetObjectTypeData() into objectTypeData

   repeat for each key objectType in objectTypeData
      put objectTypeData [objectType] into objectTypeArray
      repeat for each key rObject in objectTypeArray
         put hArray_GetUripArray (rObject, "name") into uripName
         put empty into typeNameObjectArray [objectType][uripName][rObject]
      end repeat
   end repeat
   return typeNameObjectArray
end hArray_ConstructTypeNameObjectArray

function hArray_ListObjectNamesOfType objectType
   put hArray_ConstructNameObjectArray (objectType) into nameObjectArray
   return keys (nameObjectArray)
end hArray_ListObjectNamesOfType

function hArray_ConstructNameObjectArray objectType
   local nameTypeArray
   put hArray_GetObjectTypeArray (objectType) into objectTypeArray
   repeat for each key rObject in objectTypeArray
      if exists (rObject) is false then
         next repeat
      end if
      put hArray_GetUripArray (rObject, "name") into uripName
      if uripName is empty then
         delete variable objectTypeArray [rObject]
         hArray_SetObjectTypeArray objectType, objectTypeArray

         put the mobile_Name of rObject into mObject
         put mObject && "has no uRIP ['name']." & CR & CR & "Removed it from gLCW!" into someMessage
         lcw_Notify someMessage, true
         next repeat
      else
         put empty into nameTypeArray [uripName][rObject]
      end if
   end repeat
   return nameTypeArray
end hArray_ConstructNameObjectArray

function hArray_ListObjectsOfType objectType
   put hArray_GetObjectTypeArray (objectType) into objectArray
   return keys (objectArray)
end hArray_ListObjectsOfType

function hArray_GetObjectTypeArray objectType
   put hArray_GetObjectTypeData() into objectTypeData
   return objectTypeData [objectType]
end hArray_GetObjectTypeArray

command hArray_SetObjectTypeArray objectType, objectTypeArray, pHarray
   put hArray_GetObjectTypeData (pHarray) into objectTypeData
   put objectTypeArray into objectTypeData [objectType]
   hArray_SetObjectTypeData objectTypeData, pHarray
end hArray_SetObjectTypeArray

function hArray_GetObjectTypeData pHarray
   if pHarray is an array then
      return pHarray ["objectType"]
   else
      global gLCW
      return gLCW ["objectType"]
   end if
end hArray_GetObjectTypeData

command hArray_SetObjectTypeData objectTypeData, pHarray
   if pHarray is an array then
      put objectTypeData into pHarray ["objectType"]
      return pHarray
   else
      global gLCW
      put objectTypeData into gLCW ["objectType"]
      return gLCW
   end if
end hArray_SetObjectTypeData

function hArray_ListObjectTypes
   put hArray_GetObjectTypeData() into objectTypeArray
   return keys (objectTypeArray)
end hArray_ListObjectTypes

function hArray_ListFirstObjectHkeys rObject
   put the hArray_FirstKeyArray of the target into someArray
   put keys(someArray) into shortHkeys
   repeat for each line shortHkey in shortHkeys
      put shortHkey,rObject,1 & CR after hKeys
   end repeat
   delete char -1 of hKeys
   return hKeys
end hArray_ListFirstObjectHkeys

function hArray_GetObjectScriptArray rObject
   return hArray_GetObjectData (rObject, "script_DataArray")
end hArray_GetObjectScriptArray

function hArray_ObjectIsIndexStatus rObject, pHarray
   put hArray_GetObjectMetaData (rObject, "sha1", pHarray) into scriptHash
   try
      put the script of rObject into someScript
      return sha1_Hash (someScript) = scriptHash
   catch e
      return empty
   end try
end hArray_ObjectIsIndexStatus

function hArray_GetObjectData rObject, pKey, pHarray
   put hArray_GetObjectArray (rObject, pHarray) into objectArray
   if pKey is empty then
      return objectArray ["data"]
   else
      return objectArray ["data"][pKey]
   end if
end hArray_GetObjectData

function hArray_GetUripArray rObject, pKey, pHarray
   put hArray_GetObjectArray (rObject, pHarray) into objectArray
   if pKey is empty then
      return objectArray ["metadata"]["uripArray"]
   else
      return objectArray ["metadata"]["uripArray"][pKey]
   end if
end hArray_GetUripArray

function hArray_GetObjectMetaData rObject, pKey, pHarray
   put hArray_GetObjectArray (rObject, pHarray) into objectArray
   if pKey is empty then
      return objectArray ["metadata"]
   else
      return objectArray ["metadata"][pKey]
   end if
end hArray_GetObjectMetaData

command hArray_SetObjectMetaData rObject, arrayOrValue, pKey
   put hArray_GetObjectArray (rObject) into objectArray
   if pKey is empty then
      put arrayOrValue into objectArray ["metadata"]
   else
      put arrayOrValue into objectArray ["metadata"][pKey]
   end if
   hArray_SetObjectArray rObject, objectArray
end hArray_SetObjectMetaData


--> hArray | keywords
-
function hArray_ListHkeyObjects hKey
   put item 1 to 2 of hKey into shortHkey
   put hArray_GetFoundHkeyArray (shortHkey) into hkeyArray
   put keys (hkeyArray) into foundHkeys
   repeat for each line foundHkey in foundHkeys
      put item 3 of foundHkey & CR after foundObject
   end repeat
   return foundObject
end hArray_ListHkeyObjects

function hArray_GetHandlerHash hKey, pHArray
   put hArray_GetHkeyDataArray (hKey, pHArray) into handlerArray
   put handlerArray ["sha1"] into handlerHash
   return handlerHash
end hArray_GetHandlerHash

function hArray_GetHandlerLine hKey, pHArray
   put hArray_GetHkeyDataArray (hKey, pHArray) into handlerArray
   put handlerArray ["handlerLine"] into handlerLine
   return handlerLine
end hArray_GetHandlerLine

function hArray_GetHkeyDataArray hKey, pHArray
   put item 3 of hKey into hObject
   put hArray_GetObjectData (hObject, "script_DataArray", pHArray) into scriptArray
   repeat for each key indexNum in scriptArray
      put scriptArray [indexNum]["hkey"] into testHkey
      if testHkey = hKey then
         return scriptArray [indexNum]
      end if
   end repeat
   return empty
end hArray_GetHkeyDataArray

function hArray_FindHkey shortHkey, pHandlerHash
   -- a fast lookup that ignores hierarchy
   put item 1 to 2 of shortHkey into shortHkey

   put hArray_GetFoundHkeyArray (shortHkey) into hkeyArray
   if hkeyArray is not an array and char 1 of item 2 of shortHkey is not "p" then
      put "p" before char 1 of item 2 of shortHkey
      put hArray_GetFoundHkeyArray (shortHkey) into hkeyArray
   end if

   if pHandlerHash is empty then
      put line 1 of the keys of hkeyArray into foundHKey
      return foundHKey
   else
      repeat for each key hKey in hkeyArray
         if hkeyArray [hKey]["handlerHash"] = pHandlerHash then
            return hKey
         end if
      end repeat
      return empty
   end if
end hArray_FindHkey

function hArray_GetFoundHkeyArray hKey, pHArray
   put item 1 to 2 of hKey into shortHkey
   if pHArray is an array then
      return pHArray ["handlerArray"][shortHkey]
   else
      global gLCW
      return gLCW ["handlerArray"][shortHkey]
   end if
end hArray_GetFoundHkeyArray

function hArray_ShortKeyHash hKey
   global gLCW
   put item 1 to 2 of hKey into shortHkey
   put gLCW ["handlerArray"][shortHkey]["handlerHash"] into latestShortkeyHash
   return latestShortkeyHash
end hArray_ShortKeyHash

function hArray_GetKeywordArray pKWord
   global gLCW

   if pKWord is empty then
      return gLCW ["keywordArray"]
   else
      return gLCW ["keywordArray"][pKWord]
   end if
end hArray_GetKeywordArray

command hArray_SetKeywordArray keywordArray, pKWord
   global gLCW
   if kWord is empty then
      put keywordArray into gLCW ["keywordArray"]
   else
      put keywordArray into gLCW ["keywordArray"][pKWord]
   end if
end hArray_SetKeywordArray

function hArray_ListAllObjects pHarray
   if pHarray is an array then
      global gLCW
      put gLCW ["scriptArray"] into rObjectArray
   else
      put pHarray ["scriptArray"] into rObjectArray
   end if
   put keys (rObjectArray) into rObjects
   return rObjects
end hArray_ListAllObjects

function hArray_FetchObjectArray scriptObject
   put revRuggedID (scriptObject) into rObject
   put the textStack_Folder of rObject into mainStackFolder
   put mainstack_FetchHarray (mainStackFolder) into hArray
   return hArray_GetObjectArray (rObject, hArray)
end hArray_FetchObjectArray

function hArray_GetObjectArray rObject, pHarray
   if pHarray is an array then
      if rObject is empty then
         return pHarray ["scriptArray"]
      else
         return pHarray ["scriptArray"][rObject]
      end if
   else
      global gLCW
      if rObject is empty then
         return gLCW ["scriptArray"]
      else
         return gLCW ["scriptArray"][rObject]
      end if
   end if
end hArray_GetObjectArray

command hArray_SetObjectArray rObject, objectArray, pHarray
   if pHarray is an array then
      put objectArray into pHarray ["scriptArray"][rObject]
      return pHarray
   else
      global gLCW
      put objectArray into gLCW ["scriptArray"][rObject]
      return gLCW
   end if
end hArray_SetObjectArray

function hArray_GetHandlerArray pHkey
   global gLCW
   put item 1 to 2 of pHkey into shortHkey
   if shortHkey is empty then
      return gLCW ["handlerArray"]
   else
      return gLCW ["handlerArray"][shortHkey]
   end if
end hArray_GetHandlerArray

command hArray_SetHandlerArray handlerArray, pHkey
   global gLCW
   put item 1 to 2 of pHkey into shortHkey
   if shortHkey is empty then
      put handlerArray into gLCW ["handlerArray"]
   else
      put handlerArray into gLCW ["handlerArray"][shortHkey]
   end if
end hArray_SetHandlerArray

function hArray_ListHkeys pShortHkey
   if pShortHkey is not empty then
      global gLCW
      put gLCW ["handlerArray"] into handlerArray
      put handlerArray [pShortHkey] into hKeyArray
      put keys (hKeyArray) into hKeys
   else
      put hArray_ConstructHkeyArray() into bigHKeyArray
      put keys (bigHKeyArray) into hKeys
   end if
   sort hKeys by item 1 of each
   return hKeys
end hArray_ListHkeys

function hArray_ConstructHkeyArray
   global gLCW
   local bigHKeyArray

   put gLCW ["handlerArray"] into handlerArray
   repeat for each key shortHkey in handlerArray
      if shortHkey = "_,c" then next repeat
      put handlerArray [shortHkey] into hKeyArray
      union bigHKeyArray with hKeyArray
   end repeat
   return bigHKeyArray
end hArray_ConstructHkeyArray

function hArray_GetScriptHash rObject
   put item 3 of hKey into rObject
   put hArray_GetObjectArray (rObject) into objectArray
   put objectArray ["metadata"]["sha1"] into scriptHash
   return scriptHash
end hArray_GetScriptHash

function hArray_ListIdenticalHkeys hKey
   local identicalHkeys, anotherHashArray
   hArray_SetHkeyDifferences hKey, identicalHkeys, anotherHashArray
   return identicalHkeys
end hArray_ListIdenticalHkeys

function hArray_ListDifferentHkeys hKey
   local identicalHkeys, anotherHashArray
   hArray_SetHkeyDifferences hKey, identicalHkeys, anotherHashArray
   repeat for each element handlerHashArray in anotherHashArray
      put keys(handlerHashArray) & CR after differentKeys
   end repeat
   delete char -1 of differentKeys
   sort differentKeys by item 1 of each
   return differentKeys
end hArray_ListDifferentHkeys

command hArray_SetHkeyDifferences hKey, @identicalHkeys, @anotherHashArray
   global gLCW

   put item 1 to 2 of hKey into shortHkey
   put gLCW ["handlerArray"][shortHkey] into hKeyArray
   put hKeyArray [hKey]["handlerHash"] into handlerHash

   repeat for each key anotherHkey in hKeyArray
      put hKeyArray [anotherHkey]["handlerHash"] into anotherHash
      if anotherHash = handlerHash then
         put anotherHkey & CR after identicalHkeys
      else
         put anotherHkey & CR after differentHkeys
         put hKey into anotherHashArray [anotherHash][anotherHkey]
      end if
   end repeat
   delete char -1 of identicalHkeys
end hArray_SetHkeyDifferences

function hArray_ListHandlerHashes
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   put keys (hkeyHashArray) into handlerHashes
   return handlerHashes
end hArray_ListHandlerHashes

function hArray_ConstructHkeyHashArray
   global gLCW

   -- timer_Start "hArray_ConstructHkeyHashArray"
   put gLCW ["handlerArray"] into handlerArray
   repeat for each key shortHkey in handlerArray
      if shortHkey = "_,c" then next repeat
      put handlerArray [shortHkey] into hKeyArray
      repeat for each key hKey in hKeyArray
         put hKeyArray [hKey]["handlerHash"] into handlerHash

         -- can get anything, could get info from objectArray?
         put hKeyArray [hKey]["scriptLine"] into scriptLine
         put scriptLine into hkeyHashArray [handlerHash][hKey]
      end repeat
   end repeat
   -- timer_Stop "hArray_ConstructHkeyHashArray"

   return hkeyHashArray
end hArray_ConstructHkeyHashArray

function hArray_KeywordHkeys pKeyWordList
   -- see also "hArray_ListShortKeys"
   put hArray_KeywordHkeyArray (pKeyWordList) into hKeyArray
   put keys (hKeyArray) into hKeys
   sort hKeys by item 1 of each
   return hKeys
end hArray_KeywordHkeys

function hArray_KeywordHkeyArray pKeyWordList
   -- see also "hArray_ListShortKeys"
   global gLCW

   if pKeyWordList is empty then
      -- put hArray_GetHandlerArray() into handlerArray
      put gLCW ["handlerArray"] into handlerArray
      put keys(handlerArray) into shortHKeys
   else
      replace CR with comma in pKeyWordList -- hack to allow passing lines not just lists

      put word 1 to -1 of item 1 of pKeyWordList into firstKeyWord
      delete item 1 of pKeyWordList
      put gLCW ["keywordArray"][firstKeyWord] into keywordArray

      repeat for each key shortHkey in keywordArray
         put keywordArray [shortHkey]["rugged_ID"] into ruggedID
         put keywordArray [shortHkey]["sha1"] into handlerHash
         put shortHkey,ruggedID,1 into hKey
         put handlerHash into hKeyArray [hKey]
      end repeat
   end if
   return hKeyArray
end hArray_KeywordHkeyArray

function hArray_ListShortKeys pKeyWordList
   global gLCW

   if pKeyWordList is empty then
      -- put hArray_GetHandlerArray() into handlerArray
      put gLCW ["handlerArray"] into handlerArray
      put keys(handlerArray) into shortHKeys
   else
      replace CR with comma in pKeyWordList -- hack to allow passing lines not just lists

      put word 1 to -1 of item 1 of pKeyWordList into firstKeyWord
      delete item 1 of pKeyWordList
      put gLCW ["keywordArray"][firstKeyWord] into intersectArray

      repeat for each item pKeyword in pKeyWordList
         put word 1 to -1 of pKeyword into pKeyword
         put gLCW ["keywordArray"][pKeyword] into keywordArray
         intersect intersectArray with keywordArray
      end repeat

      put keys (intersectArray) into shortHkeys
   end if
   sort shortHkeys by item 1 of each
   return shortHkeys
end hArray_ListShortKeys

function hArray_ListAllHkeys
   -- timer_Start
   put hArray_ConstructHkeyArray() into bigHKeyArray
   put keys (bigHKeyArray) into hKeys
   sort hKeys by item 1 of each
   -- timer_Stop
   return hKeys
end hArray_ListAllHkeys

function hArray_ListUniqueHkeys
   local bigHKeyArray
   -- timer_Start
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   repeat for each key handlerHash in hkeyHashArray
      put hkeyHashArray [handlerHash] into uniqueHkeyArray
      union bigHKeyArray with uniqueHkeyArray
   end repeat
   put keys (bigHKeyArray) into hkeys
   sort hkeys by item 1 of each
   -- timer_Stop

   return hkeys
end hArray_ListUniqueHkeys


--> hArray | duplicates
-
function hArray_ListDuplicateHkeys
   local duplicateShortKeyArray, duplicateHkeys
   hArray_ConstructDuplicateHkeyArray duplicateShortKeyArray, duplicateHkeys
   return duplicateHkeys
end hArray_ListDuplicateHkeys

command hArray_ConstructDuplicateHkeyArray @duplicateShortKeyArray, @duplicateHkeys
   local duplicateHKeyArray
   timer_Start "hArray_ConstructDuplicateHkeyArray"
   --
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   repeat for each key handlerHash in hkeyHashArray
      put hkeyHashArray [handlerHash] into hkeyArray
      if the number of elements of hkeyArray > 1 then
         union duplicateHKeyArray with hkeyArray

         repeat for each key hKey in hkeyArray
            put item 1 to 2 of hKey into shortHkey
            -- put handlerHash into duplicateShortKeyArray [shortHkey][hKey]
            put hkeyArray [hKey] into duplicateShortKeyArray [shortHkey][hKey]
            put empty into duplicateShortKeyArray [shortHkey][hKey]
         end repeat
      end if
   end repeat

   put keys (duplicateHKeyArray) into duplicateHkeys
   sort duplicateHkeys by item 1 of each
   --
   timer_Stop "hArray_ConstructDuplicateHkeyArray"

   return duplicateHkeys
end hArray_ConstructDuplicateHkeyArray

command hArray_ConstructDuplicateHkeyArray @duplicateShortKeyArray, @duplicateHkeys
   local duplicateHKeyArray
   timer_Start "hArray_ConstructDuplicateHkeyArray"
   --
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   repeat for each key handlerHash in hkeyHashArray
      put hkeyHashArray [handlerHash] into hkeyArray
      if the number of elements of hkeyArray > 1 then
         union duplicateHKeyArray with hkeyArray

         repeat for each key hKey in hkeyArray
            put item 1 to 2 of hKey into shortHkey
            -- put handlerHash into duplicateShortKeyArray [shortHkey][hKey]
            put hkeyArray [hKey] into duplicateShortKeyArray [shortHkey][hKey]
            put empty into duplicateShortKeyArray [shortHkey][hKey]
         end repeat
      end if
   end repeat

   put keys (duplicateHKeyArray) into duplicateHkeys
   sort duplicateHkeys by item 1 of each
   --
   timer_Stop "hArray_ConstructDuplicateHkeyArray"

   return duplicateHkeys
end hArray_ConstructDuplicateHkeyArray


--> hArray | Tidy
-
command hArray_FindAndRemoveMissingObjects pDontNotify
   global gLCW

   put hArray_ListMissingObjects() into missingObjects
   repeat for each line rObject in missingObjects
      hArray_RemoveObjectFromArray rObject, gLCW
   end repeat

   if pDontNotify is true then return missingObjects
   if missingObjects is empty then
      lcw_Notify "Did not find any missing objects in the global gLCW array!"
   else
      lcw_Notify "Removed the following missing objects from the global gLCW array!", true
      put missingObjects
   end if
   return missingObjects
end hArray_FindAndRemoveMissingObjects

function hArray_ListMissingObjects
   put hArray_GetObjectArray() into scriptArray
   repeat for each key rObject in scriptArray
      if exists (rObject) is false then
         put rObject & CR after missingObjects
      end if
   end repeat
   delete char -1 of missingObjects
   return missingObjects
end hArray_ListMissingObjects

command hArray_RemoveObject someObject
   global gLCW
   if exists (someObject) then
      put revRuggedID (someObject) into rObject
      put the object_Metadata of rObject into uRipArray
   else
      put someObject into rObject -- assume it is in the right format (won't do anythign if it is not)
      put empty into uRipArray -- won;t strip same name / type objects
   end if

   global gLCW
   hArray_RemoveObjectFromArray rObject, gLCW, uRipArray
end hArray_RemoveObject

command hArray_RemoveObjectFromArray rObject, @hArray, pUripArray
   delete variable hArray ["scriptArray"][rObject]
   hArray_RemoveObjectFromHandlerArray rObject, hArray
   hArray_RemoveObjectFromTypeArray rObject, hArray
   if pUripArray is an array then
      hArray_RemoveSameNameTypeObjects rObject, hArray, pUripArray
   end if
end hArray_RemoveObjectFromArray

command hArray_RemoveObjectFromHandlerArray rObject, @hArray, pSlowClean
   if pSlowClean is not false then
      -- this is slower but thorough (should not be needed with a tidy db)
      put hArray ["handlerArray"] into handlerArray
      repeat for each key shortHkey in handlerArray
         put handlerArray [shortHkey] into shortKeyArray
         repeat for each key hkey in shortKeyArray
            if item 3 of hkey = rObject then
               put keys(shortKeyArray) into hKeys
               if the number of lines of hKeys = 1 then
                  delete variable hArray ["handlerArray"][shortHkey]
               else
                  delete variable hArray ["handlerArray"][shortHkey][hkey]
               end if
            end if
         end repeat
      end repeat
   else
      put hArray_GetObjectData (rObject, "script_DataArray", hArray) into scriptData -- should be old handlers and work
      repeat for each key indexNum in scriptData
         put scriptData [indexNum]["hKey"] into hKey
         if hKey is empty then next repeat

         put item 1 to 2 of hKey into shortHKey
         put hArray ["handlerArray"][shortHKey] into shortKeyArray
         if shortKeyArray is an array then -- not sure if we really need to check this for speed reasons
            delete variable hArray ["handlerArray"][shortHKey][hKey]
            put hArray ["handlerArray"][shortHKey] into shortKeyArray
            if shortKeyArray is not an array then
               delete variable hArray ["handlerArray"][shortHKey] -- to tidy empty arrays
            end if
         end if
      end repeat
   end if
end hArray_RemoveObjectFromHandlerArray

command hArray_RemoveObjectFromTypeArray rObject, @hArray
   put hArray ["objectType"] into objectTypeArray
   repeat for each key objectType in objectTypeArray
      -- remove the object from every object type
      delete variable hArray ["objectType"][objectType][rObject]
      if objectTypeArray [typePath] is not an array then
         delete variable hArray ["objectType"][typePath]
      end if
   end repeat
end hArray_RemoveObjectFromTypeArray

command hArray_RemoveSameNameTypeObjects rObject, @hArray, uRipArray
   put uRipArray ["name"] into uripName
   put uRipArray ["type"] into objectType
   if objectType is "view" and the view_IsTemplate of rObject is true then
      put "view template" into objectType
   end if

   -- only for the particular type
   -- an object with the same uRipName can have different "types"
   -- but the uripName / type cobination must be unique
   -- so here we delete any other objects of the same type and uRipName
   put hArray ["objectType"][objectType] into rObjectTypeArray
   repeat for each key testObject in rObjectTypeArray
      put rObjectTypeArray [testObject]["uripName"] into testName
      if testName is empty then next repeat
      if testName = uripName then
         delete variable hArray ["objectType"][objectType][testObject]
      end if
   end repeat
end hArray_RemoveSameNameTypeObjects


--> View | Model
-
/*
These handlers are the current way views store their metadata.
Eventually the aim is to update this to the way stacks in general store their metadata for any object,
which is based on the standard stack export model (with it's associated metadata folders for each exported object).
These handlers have been place here in order to encourage this migration :)
*/

command view_RenameTemplate oldViewName, newViewName
   view_NormalizeName oldViewName
   view_NormalizeName newViewName

   put default_FirstStackControl (oldViewName) into templateObject
   if exists (templateObject) is false then return "error, cannot locate view tempate for stack" && kwote (oldViewName)

   put there is a stack oldViewName and oldViewName begins with "View|" into oldViewStack
   if oldViewStack is false then
      -- lets not rename the stack - but just update the view metadata
      set the view_NewName of templateObject to newViewName
   else
      put the filename of stack oldViewName into oldFile

      if there is a stack newViewName then return "error, there is already a stack" && kwote (newViewName)
      put view_NameToFile (newViewName) into newFile

      put the short id of templateObject into newTemplateID
      put "control id" && newTemplateID && "of stack" && kwote (newViewName) into newTemplateObject
      put the stack_SubName ["OPN Stack Menus"] of templateObject into subStackName

      set the object_IsIndexed of templateObject to false

      put the behavior of templateObject into templateBehavior
      if exists (templateBehavior) then
         set the object_IsIndexed of templateBehavior to false

         put the stack_Name of templateBehavior into templateStackName
         put the short id of templateBehavior into newBehaviorID
         switch templateStackName
            case oldViewName
               -- it is in the stack of the view being renamed
               put "control id" && newBehaviorID && "of stack" && kwote (newViewName) into newTemplateBehavior
               break
            case subStackName
               -- it is in the sub-stack of the view being renamed
               put newViewName & "|" & "OPN Stack Menus" into newSubStackName
               put "control id" && newBehaviorID && "of stack" && kwote (newSubStackName) into newTemplateBehavior
               break
            default
               -- it is a linked behavior in a stack that is not being renamed
               put templateBehavior into newTemplateBehavior
         end switch
      else
         put empty into newTemplateBehavior
      end if

      if exists (stack subStackName) then
         -- lets rename the substack first
         -- first a quick safety check
         put newViewName & "|" & "OPN Stack Menus" into newSubStackName
         if there is a stack newSubStackName then
            -- should not be let's exit
            return "error, for some strange reason there is already a sub-stack" && kwote (newSubStackName)
         end if

         -- now rename the substack

         set the object_IsIndexed of stack newSubStackName to false
         set the stack_IsKnown of stack subStackName to false
         set the name of stack subStackName to newSubStackName
      end if

      -- now rename the mainstack, it's file on disk (keeping it in the same folder), and set the new mainstacks fileName
      set the object_IsIndexed of stack oldViewName to false
      set the stack_IsKnown of stack oldViewName to false
      set the name of stack oldViewName to newViewName
      set the filename of stack newViewName to newFile
      -- file_Rename oldFile, newFile
      rename file oldFile to newFile
      set the stack_IsKnown of stack newViewName to true
      set the object_IsIndexed of stack newViewName to true

      if exists (stack newSubStackName) then
         set the stack_IsKnown of stack newSubStackName to true
         set the object_IsIndexed of stack newSubStackName to true
      end if

      -- done renaming, lets fix the uRip properties, and update hArray
      set the view_NewName of newTemplateObject to newViewName
   end if
end view_RenameTemplate

command view_DeleteTemplate vName
   view_NormalizeName vName
   if there is a stack vName then
      put the filename of stack vName into someFile
      delete stack vName
   else
      put view_NameToFile (vName) into someFile
   end if

   if there is a file someFile then delete file someFile
   view_DeleteMetaData vName
   view_DeleteHelpText vName
   view_DeleteIcon vName
   return someFile
end view_DeleteTemplate

function view_GetHelpHtml vName, pOnLineMode
   view_NormalizeName vName
   put library_TextUrl ("help.html", vName, "view", true) into someUrl
   if someUrl is empty then return empty
   put url someUrl into helpHtml
   return helpHtml
end view_GetHelpHtml

on view_SetHelpHtml vName, someHtml, pOnLineMode
   view_NormalizeName vName
   put library_TextUrl ("help.html", vName, "view", false) into someUrl
   if someUrl is not empty then put someHtml into url someUrl
   return someUrl
end view_SetHelpHtml

command view_DeleteHelpText vName
   view_NormalizeName vName
   put library_TextFile ("help.html", vName, "view", true) into someFile
   delete file someFile
   return someFile
end view_DeleteHelpText

function view_GetMetaData vName
   put view_GetFileMetaArray() into metaDataArray
   return metaDataArray [vName]
end view_GetMetaData

command view_SetMetaData vName, vMetaArray
   put view_GetFileMetaArray() into metaDataArray
   put vMetaArray into metaDataArray [vName]
   view_SetFileMetaArray metaDataArray
end view_SetMetaData

command view_DeleteMetaData vName
   put view_GetFileMetaArray() into metaDataArray
   delete variable metaDataArray [vName]
   view_SetFileMetaArray metaDataArray
end view_DeleteMetaData

function view_GetPublished vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isPublished"] into someBoolean
   return someBoolean is true
end view_GetPublished

command view_SetPublished vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isPublished"]
   view_SetFileMetaArray metaDataArray
end view_SetPublished

function view_GetFavourite vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isFavourite"] into someBoolean
   return someBoolean is true
end view_GetFavourite

command view_SetFavourite vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isFavourite"]
   view_SetFileMetaArray metaDataArray
end view_SetFavourite

function view_GetTested vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isTested"] into someBoolean
   return someBoolean is true
end view_GetTested

command view_SetTested vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isTested"]
   view_SetFileMetaArray metaDataArray
end view_SetTested

function view_GetOld vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isOld"] into someBoolean
   return someBoolean is true
end view_GetOld

command view_SetOld vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isOld"]
   view_SetFileMetaArray metaDataArray
end view_SetOld


--> View | File | Model
-
/*
Text and data for browsing and navigating view templates,
but not needed for functioning of view - simply house-keeping.

Not necessary to distribute with working views.

Used for things like presenting and browsing library metadata.
Stored as a text file (an encoded array), and is not need ed to be distribute with view stack for it to work.
*/

function view_GetFileMetaArray
   put model_GetFileArray ("viewMetaData.array") into viewMetaDataArray
   return viewMetaDataArray
end view_GetFileMetaArray

command view_SetFileMetaArray viewMetaDataArray
   model_SetFileArray "viewMetaData.array", viewMetaDataArray
   put the result into someFile
   return someFile
end view_SetFileMetaArray
