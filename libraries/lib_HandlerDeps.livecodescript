script "lib_HandlerDeps"
--> MetaData
-
license: GPLv3
name: lib_HandlerDeps
type: script library
version: 0.3

/*
Seems trashy. See lib_ScriptFetch
*/


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


--> HkeyArray | Exported | Recursive
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
      hkey_RecurseLongCallArrayFromExported hKey, hkeyArray, pProjectName
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
