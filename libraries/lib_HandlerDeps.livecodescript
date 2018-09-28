script "lib_HandlerDeps"
--> MetaData
-
license: GPLv3
name: lib_HandlerDeps
type: script library
version: 0.3


--> Props
-
getprop script_HkeyArrayFromExportedCalls [pSetName]
   local hkeyArray
   put the script_Hkeys of the target into hKeys
   repeat for each line hKey in hKeys
      hkey_RecurseLongCallArrayFromExported hKey, hkeyArray, pSetName
   end repeat
   return hkeyArray
end script_HkeyArrayFromExportedCalls


--> Hkey | Collect
-
function hkey_CollectFromObjects hKeys, pSortAlphabetically
   local newScript
   put word 1 to -1 of hKeys into hKeys
   if pSortAlphabetically is true then sort hKeys by item 1 of each
   repeat for each line hKey in hKeys
      put handler_Get (hKey) into someHandler
      text_AddParagraph someHandler, newScript
   end repeat
   return newScript
end hkey_CollectFromObjects

function script_FromHkeys hKeys, pMakePrivate
   local newScript, missingHkeys
   script_FetchFromHkeys hKeys, newScript, missingHkeys, pMakePrivate
   return newScript
end script_FromHkeys

command script_FetchFromHkeys hKeys, @newScript, @missingHkeys, pMakePrivate
   -- utitlity for returning missing keys as well
   put word 1 to -1 of hKeys into hKeys
   sort hKeys
   repeat for each line hKey in hKeys
      put hkey_FetchHandler (hKey) into someHandler
      if someHandler is empty then
         line_Add hKey, missingHkeys
      else
         if pMakePrivate is true and word 1 of dsfa is not "private" then
            put "private" & space before someHandler
         end if
         text_AddParagraph someHandler, newScript
      end if
   end repeat
end script_FetchFromHkeys


--> Deps
-
function hkey_CallArrayFromExported hKey, pSetName
   local hkeyArray
   hkey_RecurseLongCallArrayFromExported hKey, hkeyArray, pSetName
   return hkeyArray
end hkey_CallArrayFromExported

function scriptArray_ConstructShortHkeyArray dataArray
   -- fetch from "links.txt" for all hKeys in the scriptArray "dataArray"
   local hkeyArray
   repeat for each element recordArray in dataArray
      set the cursor to busy
      put recordArray ["hkey"] into hkey
      if hKey is empty then next repeat
      if hKey is among the keys of hkeyArray then next repeat
      
      hkey_RecurseCallArray hKey, hkeyArray
   end repeat
   return hkeyArray
end scriptArray_ConstructShortHkeyArray


--> Private
-
function hkeyArray_FromExported hKey, pProjectName
   local hkeyArray
   hkeyArray_RecurseFromExported hKey, hkeyArray, pProjectName
   return hkeyArray
end hkeyArray_FromExported

private command hkeyArray_RecurseFromExported hKey, @hkeyArray, pProjectName
   -- fetch files recursively
   local foundHkey, foundHandler
   if hKey is among the keys of hkeyArray then
      return "Already indexed! Skipping to avoid recursion."
   end if
   
   hKeyLine_Deconstruct hKey, hName, hType, hObject
   --
   put hkey_FetchCalls (hKey) into shortCalls
   put hkey_FindLongCalls (shortCalls, hObject) into longCalls
   put longCalls into hkeyArray [hKey]
   
   repeat for each line longCall in longCalls
      hkey_RecurseLongCallArrayFromExported hKey, @hkeyArray, pProjectName
   end repeat
end hkeyArray_RecurseFromExported

private command hkey_RecurseLongCallArrayFromExported hKey, @hkeyArray, pSetName
   -- fetch from "links.txt" file recursively
   local foundHkey, foundHandler
   if hKey is among the keys of hkeyArray then return "Already indexed! Skipping to avoid recursion."
   
   hKeyLine_Deconstruct hKey, hName, hType, hObject
   put hkey_FetchCalls (hKey) into shortCalls
   repeat for each line shortCall in shortCalls
      put item 1 of shortCall into cName
      put item 2 of shortCall into cType
      put hkey_FindAndIndex (cName, cType, hObject, pSetName) into foundHkey
      put foundHkey & CR after longCalls
   end repeat
   delete char -1 of longCalls
   put longCalls into hkeyArray [hKey]
   
   repeat for each line longCall in longCalls
      -- hkey_RecurseShortCallArrayFromExported longCall, hkeyArray, pSetName
   end repeat
end hkey_RecurseLongCallArrayFromExported
