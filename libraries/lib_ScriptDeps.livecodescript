script "lib_ScriptDeps"
--> MetaData
-
license: GPLv3
name: lib_ScriptDeps
type: library
version: 0.3


--> Working on
-
getprop found_Calls [findLong]
   switch findLong
      case "short"
         put the script_ExternalCalls of the target into shortCalls
         return shortCalls
      default
         put the script_ExternalHkeys of the target into externalHKeys
         return externalHKeys
   end switch
end found_Calls

getprop found_CallObjects [searchObjects]
   put the script_ExternalHkeys [searchObjects] of the target into externalHKeys
   repeat for each line hKey in externalHKeys
      hkey_Deconstruct hKey, callName, callType, callObject, xNum
      put callName into objectCallArray [callObject][hKey]
   end repeat
   put keys (objectCallArray) into foundCallObjects
   return foundCallObjects
end found_CallObjects

getprop script_ExternalHkeys [searchObjects]
   put the long id of the target into tObject
   put the script_ExternalCalls of tObject into shortExternalCalls
   
   -- this is slow
   put hkey_FindLongCalls (shortExternalCalls, tObject, searchObjects) into externalHKeys
   return externalHKeys
end script_ExternalHkeys


--> Script | Calls
-
getprop script_ExternalCalls
   put the script_SplitCallArray of the target into splitCallArray
   --
   put splitCallArray ["externalCalls"] into externalCallArray
   put keys (externalCallArray) into externalCalls
   sort externalCalls by word 2 of each
   --
   return externalCalls
end script_ExternalCalls

getprop script_InternalCalls
   put the script_SplitCallArray of the target into splitCallArray
   --
   put splitCallArray ["internalCalls"] into internalCallArray
   put keys (internalCallArray) into internalCalls
   sort internalCalls by word 2 of each
   --
   return internalCalls
end script_InternalCalls

getprop script_SplitCallArray
   put the long id of the target into tObject
   --
   put the script of tObject into someScript
   put the revAvailableHandlers of tObject into hTable
   --
   put _SplitCallArray (hTable, someScript) into splitCallArray
   --
   return splitCallArray
end script_SplitCallArray

private function _SplitCallArray hTable, someScript
   repeat for each line hkeyLine in hTable
      htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
      if endLineNum = 0 then next repeat
      
      # Extract handler calls
      put line startLineNum to endLineNum of someScript into someHandler
      put handler_ExtractCalls (someHandler) into handlerCalls
      
      # Split the calls
      repeat for each line handlerCall in handlerCalls
         htable_EitherLineOffsets handlerCall, hTable, startCallNum, endCallNum
         --
         if the result is empty then
            put startCallNum,endCallNum into splitCallArray ["externalCalls"][handlerCall]
         else
            put the result into hTableLine
            put word 1 to 2 of hTableLine into handlerCall -- fixes possible private bit
            put startCallNum,endCallNum into splitCallArray ["internalCalls"][handlerCall]
         end if
      end repeat
   end repeat
   return splitCallArray
end _SplitCallArray



--> Script | Calls
-
getprop script_Calls [pExternalOnly]
   -- uses hkey_GetPlace() of model_Place
   put the script_CallArray [pExternalOnly] of the target into callArray
   put keys (callArray) into allCalls
   sort allCalls by item 1 of each
   return allCalls
end script_Calls

getprop script_CallArray [pExternalOnly]
   local callArray
   
   put the long id of the target into tObject
   put the revAvailableHandlers of tObject into hTable
   put the dataObject_Folder of tObject into dataFolder
   put revRuggedID (tObject) into pObject
   put script_FetchHkeyPlaceArray() into hkeyPlaceArray
   
   repeat for each line hTableLine in hTable
      put word 1 to 2 of hTableLine into pShortHkey -- new word based version 
      put handler_FetchCalls (pShortHkey, dataFolder) into shortCalls
      put pShortHkey && "of" && pObject into pHkey
      
      set the wholematches to false
      repeat for each line shortCall in shortCalls
         if pExternalOnly is true then
            put shortCall & space into searchString
            if lineOffset (searchString, hTable) > 0 then next repeat
         end if
         
         put hkey_GetPlace (shortCall, hkeyPlaceArray) into cObject
         put shortCall && "of" && cObject into cHkey
         
         put empty into callArray [cHkey][pHkey]
      end repeat
   end repeat
   return callArray
end script_CallArray

getprop script_ShortCallArray [pExternalOnly]
   local callArray
   
   put the long id of the target into tObject
   put the revAvailableHandlers of tObject into hTable
   put the dataObject_Folder of tObject into dataFolder
   put revRuggedID (tObject) into rObject
   repeat for each line hTableLine in hTable
      put word 1 to 2 of hTableLine into shortHkey -- new word based version
      put handler_FetchCalls (shortHkey, dataFolder) into shortCalls
      set the wholematches to false
      repeat for each line shortCall in shortCalls
         if pExternalOnly is true then
            put shortCall & space into searchString
            if lineOffset (searchString, hTable) > 0 then next repeat
         end if
         put empty into callArray [shortCall][shortHkey]
      end repeat
   end repeat
   return callArray
end script_ShortCallArray


--> Script | Deps
-
getprop script_DepLibs [pUseTextStackArray]
   -- should give the option of returning the array directly from the objects script
   put the textStack_LibDeps of the target into dependencyStacks
   return dependencyStacks
end script_DepLibs

getprop textStack_LibDeps
   put the textstack_HkeyObjectArray of the target into objectArray
   delete variable objectArray ["Missing"]
   put the defaultstack into longStackObject
   delete variable objectArray ["revIgniter"]
   put the name of longStackObject into myStackObject
   delete variable objectArray [myStackObject]
   put keys (objectArray) into dependencyStacks
   return dependencyStacks
end textStack_LibDeps
