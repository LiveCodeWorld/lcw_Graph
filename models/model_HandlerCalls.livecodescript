script "model_HandlerCalls"
--> MetaData
-
license: GPLv3
name: model_HandlerCalls
type: model
version: 0.1


--> Hkey | Calls | Exported | Props
-
getprop exported_HandlerCalls [shortHkey]
   put the dataObject_Folder of the target into dataFolder
   put handler_FetchCalls (shortHkey, dataFolder) into shortCalls
   return shortCalls
end exported_HandlerCalls

setprop exported_HandlerCalls [shortHkey] shortCalls
   put the dataObject_Folder of the target into dataFolder
   handler_StoreCalls shortHkey, dataFolder, shortCalls
   return the result
end exported_HandlerCalls


--> Handler | Calls | Model
-
function hkey_FetchCalls hKey
   put hkey_CallsFile (hKey) into callsFile
   put script_FetchRaw (callsFile) into shortCalls
   return shortCalls
end hkey_FetchCalls

command hkey_StoreCalls hKey, hKeyCalls
   put hkey_CallsFile (hKey) into callsFile
   if hKeyCalls is empty then
      delete file callsFile
      return empty
   else
      -- put hKeyCalls into url ("binfile:" & someFile)
      script_SaveRaw callsFile, hKeyCalls
      return someFile
   end if
end hkey_StoreCalls

function handler_FetchCalls hkeyLine, dataFolder
   put textStack_ConstructCallsFile (hkeyLine, dataFolder) into callsFile
   put script_FetchRaw (callsFile) into hTableLines
   return hTableLines
end handler_FetchCalls

command handler_StoreCalls hkey, dataFolder, shortCalls
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/lcw_calls.txt
   put textStack_ConstructCallsFile (hkey, dataFolder) into callsFile
   script_SaveRaw callsFile, shortCalls
   return shortCalls 
end handler_StoreCalls


--> Old | hArray | Calls | Model
-
/*
We can also get calls information from hArray
*/

function hkey_FetchShortCalls hKey, pReindex
   -- first lets fetch a mainstack hArray
   put item 3 of hKey into hObject
   put the textStack_Folder of hObject into mainStackFolder
   put mainStack_FetchHarray (mainStackFolder) into hArray
   
   if hArray is not an array and pReindex is not false then
      mainStack_ExportAsFiles hObject -- fix:  should just redo hArray here
      put the result into mainStackMetaArray
      put mainStackMetaArray ["hArray"] into hArray
      -- put mainStack_FetchHarray (mainStackFolder) into hArray
   end if
   
   -- found on disk from stack export
   put hArray_GetCalls (hKey, hArray) into shortCalls
   return shortCalls
end hkey_FetchShortCalls

function hArray_GetCalls hKey, hArray
   put hArray_GetHandlerHash (hKey, hArray) into handlerHash
   put hArray ["handlerHashArray"]["cached"][handlerHash]["shortCalls"] into shortCalls
   return shortCalls
end hArray_GetCalls

function hArray_GetShortCalls hKey, pHArray
   put hArray_GetHandlerHash (hKey, pHArray) into handlerHash
   if handlerHash is not empty then
      put pHArray ["handlerHashArray"]["cached"][handlerHash]["shortCalls"] into shortCalls
      return shortCalls
   else
      -- not sure this option should be in this handler
      return hkey_FetchShortCalls (hKey)
   end if
end hArray_GetShortCalls

command hArray_SetShortCalls hkey, hArray, shortCalls
   put hArray_GetHandlerHash (hKey, hArray) into handlerHash
   if shortCalls is empty then
      delete variable hArray ["handlerHashArray"]["cached"][handlerHash]["shortCalls"]
   else
      put shortCalls into hArray ["handlerHashArray"]["cached"][handlerHash]["shortCalls"]
   end if
   return shortCalls
end hArray_SetShortCalls
