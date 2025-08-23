script "lib_HkeyWalk"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_HkeyWalk
type: library
version: 0.2
deps: none

/*
This is a standalone script for the handler "walk_ConstructHkeyArray"

Hence all the non-library handlers below teh "Deps" section..
*/


--> Variables
-
local LivecodeDictionaryTerms
local WalkSearchHierarchy


--> Walk | HkeyArray
-
getprop walk_HkeyArray [pShortHkey]
   switch pShortHkey
      case "stored"
         put the script_HkeyArray of the target into hKeyArray
         break
      case empty
         put the script_WalkHkeyArray of the target into hKeyArray
         break
      default
         put the script_Hkey [pShortHkey] of the target into hKey
         if hKey is empty then return empty
         put walk_ConstructHkeyArray (hKey) into hKeyArray
   end switch
   return hKeyArray
end walk_HkeyArray


--> Script | Walk
-
getprop script_WalkHandlers [pSearchObjects]
   put the long id of the target into tObject
   put false into pSkipDisplay
   if pSearchObjects is empty then
      put the walk_Hierarchy of tObject into pSearchObjects
   end if
   walk_SetSearchHierarchy pSearchObjects
   --
   put the revAvailableHandlers of tObject into hTable
   put _WalkAvailableHandlers (hTable, pSkipDisplay) into hKeyArray
   return hKeyArray
end script_WalkHandlers

getprop script_WalkHkeyArray [pSearchObjects]
   put the long id of the target into tObject
   --
   if pSearchObjects is empty then
      put the walk_Hierarchy of tObject into pSearchObjects
      put true into pSkipDisplay
   else
      put false into pSkipDisplay
   end if
   walk_SetSearchHierarchy pSearchObjects
   --
   put the revAvailableHandlers of tObject into hTable
   put _WalkAvailableHandlers (hTable, pSkipDisplay) into hKeyArray
   return hKeyArray
end script_WalkHkeyArray

function walk_ConstructHkeyArray hKey, pSearchObjects, pSkipDisplay
   local hKeyArray
   -- walk_HkeyCalls hKeyArray, hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortCallHkey
   
   # Object hierarchy (include behaviors)
   if pSearchObjects is empty then
      put the walk_Hierarchy of hObject into pSearchObjects -- default
   end if
   walk_SetSearchHierarchy pSearchObjects
   
   # Recursively walk
   _WalkHkeyRecursive hKey, hKey, hKeyArray, pSkipDisplay
   return hKeyArray
end walk_ConstructHkeyArray

command walk_HkeyCalls @hKeyArray, hKey, pSkipDisplay
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   --
   put _GetHandlerCalls (shortHkey, hObject, pSkipDisplay) into shortCallHkeys
   if shortCallHkeys is empty then
      put empty into hKeyArray [hKey]
   else
      repeat for each line shortCallHkey in shortCallHkeys 
         _WalkHkeyRecursive shortCallHkey, hKey, hKeyArray, pSkipDisplay
      end repeat
   end if
end walk_HkeyCalls

private function _WalkAvailableHandlers hTable, pSkipDisplay
   local hKeyArray
   
   put revRuggedID (word 5 to -1 of line 1 of hTable) into hObject
   repeat for each line hTableLine in hTable
      set the cursor to busy
      put word 1 to 2 of hTableLine into shortHkey
      put hKeyLine_AddObject (shortHkey, hObject) into hKey
      walk_HkeyCalls hKeyArray, hKey, pSkipDisplay
   end repeat
   return hKeyArray
end _WalkAvailableHandlers


--> Working on
-
getprop module_Name
   put the effective filename of the defaultstack into sPath
   put module_NameFromPath (sPath) into moduleName
   return moduleName
end module_Name

getprop module_Object
   -- was template_Object
   put the view_Name of the target into moduleName
   -- put the module_Name of the target into moduleName
   if exists (stack moduleName) is false then return empty
   
   -- put module_GetTemplateObject (moduleName) into mObject
   put the module_View of stack moduleName into mObject
   if exists (mObject) then return mObject
   
   put default_FirstStackControl (moduleName) into mObject
   return mObject
end module_Object

getprop module_Folder
   put the long id of the target into tObject
   put the effective filename of the defaultstack into stackPath
   if exists (stack stackPath) is false then
      return empty
   end if
   
   put the project_Folder of stack stackPath into projectFolder
   if there is not a folder projectFolder then return empty
   --
   put module_FolderFromPath (stackPath, projectFolder) into moduleFolder
   return moduleFolder
end module_Folder

getprop project_Folder
   -- latest simplest version based on naming conventions and folder structure
   -- does not allow projects outside of the LCW reop folder  
   
   put the effective filename of the defaultstack into stackPath
   if stackPath is empty then return empty
   put project_FolderFromPath (stackPath) into projectFolder
   return projectFolder
end project_Folder


--> Handler
-
function walk_ConstructHkeyArray hKey, pSearchObjects, pSkipDisplay
   local hKeyArray
   -- walk_HkeyCalls hKeyArray, hKey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortCallHkey
   
   # Object hierarchy (include behaviors)
   if pSearchObjects is empty then
      put the walk_Hierarchy of hObject into pSearchObjects -- default
   end if
   walk_SetSearchHierarchy pSearchObjects
   
   # Recursively walk
   _WalkHkeyRecursive hKey, hKey, hKeyArray, pSkipDisplay
   return hKeyArray
end walk_ConstructHkeyArray


--> Deps
-
getprop behavior_Objects [useRugged]
   put the long id of the target into tObject
   put behavior_GetHierarchy (tObject, useRugged) into bObjects
   return bObjects
end behavior_Objects

getprop hierarchy_ObjectAndBehaviors [pPretty]
   local objectHierarchy
   put pPretty is not false into pPretty
   put the long id of the target into tObject
   
   _AddObjectAndBehaviors objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_ObjectAndBehaviors

getprop hkey_Either [shortHkey]
   -- returns public or private hkey in tObject
   put the revAvailableHandlers of the target into hTable
   put hTable_GetEither (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Either

getprop hkey_Or [shortHkey]
   put the revAvailableHandlers of the target into hTable
   put htable_GetOr (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Or

getprop module_BehaviorHierarchy [fromFolder]
   local oHierarchy, bHierarchy
   put the long id of the target into tObject
   put revRuggedId (tObject) into rObject
   --
   put the module_Name of tObject into moduleName
   put default_FirstStackControl (moduleName) into mObject
   
   # Behaviors and object hieararchy
   if fromFolder is not false then
      put the module_Behaviors of mObject into oHierarchy
   else
      put the behavior_Objects of mObject into oHierarchy
   end if
   --
   line_Delete rObject, oHierarchy
   put rObject & CR before oHierarchy
   put word 1 to -1 of oHierarchy into oHierarchy
   
   # Rest of object hierarchy
   hierachy_AddStackObjects bHierarchy, mObject
   put oHierarchy & CR & word 1 to -1 of bHierarchy into walkHierarchy
   
   # Is this missing stack object?
   
   # Add Env hierarchy
   hierarchy_AddEnv walkHierarchy
   return walkHierarchy
end module_BehaviorHierarchy

getprop module_BehaviorPaths
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_BehaviorPaths

getprop module_Behaviors
   -- unordered list
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_Behaviors

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


--> Deps
-
--> Props
-
getprop handler_Key [hKey]
   put the long id of the target into tObject
   put revRuggedID (tObject) into hObject
   --
   hkey_Deconstruct hKey, hName, hType, xObject, xNum
   put hKeyLine_Construct (hName, hType, hObject) into hKey
   --
   return hKey
end handler_Key

getprop handler_MetadataFolder
   -- /~/Nextcloud/fedwiki/handler.livecode.wiki/assets/stack/View|Data/metadata/objects/stack/
   
   put wikiFarm_DefaultFolder() into metadataFolder
   --
   put "handler.livecode.wiki/assets/stack/" after metadataFolder
   put sName & slash after  metadataFolder
   put "metadata/objects/stack/" after metadataFolder
   return metadataFolder
end handler_MetadataFolder

getprop script_Hkey [hKey]
   return the handler_Key [hKey] of the target
end script_Hkey

getprop script_HkeyArray
   put the long id of the target into sObject
   put script_GetHkeyArray (sObject) into hKeyArray
   return hKeyArray
end script_HkeyArray

getprop script_HkeyArrayFile
   put the handler_MetadataFolder of the target into metadataFolder
   put metadataFolder & "scriptHkey.array" into hkeyArrayFile
   return hkeyArrayFile
end script_HkeyArrayFile


--> Hkeys
-
function array_Get someFile
   put url ("binfile:" & someFile) into encodedDataArray
   if encodedDataArray is empty then return empty
   put arraydecode (encodedDataArray) into modelArray
   return modelArray
end array_Get

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   -- will deconstruct both
   -- move over to hkeyLine_Deconstruct
   
   if the number of items of hkey = 1 then
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put 1 into hNum
   else
      -- old version
      put word 1 to -1 of item 1 of hKey into hName
      put word 1 to -1 of item 2 of hKey into hType
      if hType is empty then put "c" into hType
      put word 1 to -1 of item 3 of hKey into hObject
      put item 4 of hKey into hNum
      if hNum is empty then put 1 into hNum
   end if
   
   put hKeyLine_Construct (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkey_Deconstruct

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function script_GetHkeyArray sObject
   put the script_HkeyArrayFile of sObject into hkeyArrayFile
   put array_Get (hkeyArrayFile) into hKeyArray
   return hKeyArray
end script_GetHkeyArray

function wikiFarm_DefaultFolder
   -- put the metadataObject_Folder of the target into metadataFolder
   -- put default_FarmFolder() into metadataFolder
   put dataStack_GetValue ("default_FarmFolder") into farmFolder
   return farmFolder
end wikiFarm_DefaultFolder


-- Deps | Old
-
function behavior_GetHierarchy tObject, pUseRugged
   repeat
      put the behavior of tObject into bObject
      if exists (bObject) is false then exit repeat
      if pUseRugged is not false then
         put revRuggedId (bObject) into bObject
      end if
      put bObject & CR after bObjects
      put bObject into tObject
   end repeat
   delete char -1 of bObjects
   return bObjects
end behavior_GetHierarchy

function default_FirstStackControl viewName
   view_NormalizeName viewName
   put stack_FirstControl (viewName) into mObject
   return mObject
end default_FirstStackControl

function env_GetRepoFolder
   put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   delete item -1 of pLcwFolder
   return pLcwFolder
end env_GetRepoFolder

function env_GetLcwFolder
   if exists (stack "LCW") is false then
      put the filename of me into sPath
      return env_FolderFromPath (sPath)
   else
      get the filename of stack "LCW"
      set the itemdelimiter to slash
      put item 1 to -2 of it & slash into lcwFolder
      return lcwFolder
   end if
end env_GetLcwFolder

function env_FolderFromPath sPath
   -- works for any stack within the LiveCodeWorld repo
   constant RootName = "LivecodeWorld"
   
   set the itemdelimiter to slash
   put itemOffset (RootName, sPath) into itemNum
   if itemNum = 0 then return empty
   put item 1 to itemNum of sPath & slash into envFolder
   return envFolder
end env_FolderFromPath

function env_ListBackScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the backscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListBackScripts

function env_ListFrontScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the frontscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListFrontScripts

function env_ScriptHierarchy pRemoveTransportBehavior
   put env_ListFrontScripts() into frontObjects
   -- _RemoveTransporterTools frontObjects, pRemoveTransportBehavior
   --
   put env_ListBackScripts() into backObjects
   put stack_PathsToObjects (the stacksinUse) into usedStacks
   --
   object_AddBehaviors usedStacks
   object_AddBehaviors frontObjects
   object_AddBehaviors backObjects
   --
   if usedStacks is not empty then put usedStacks into scriptHierarchy
   if backObjects is not empty then put backObjects & CR before scriptHierarchy
   if frontObjects is not empty then put CR & frontObjects after scriptHierarchy
   --
   return scriptHierarchy
end env_ScriptHierarchy

function folder_ListStackPaths someFolder
   -- will load stacks into memory
   if there is not a folder someFolder then return empty
   
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   set the defaultfolder to oFolder
   return stackFilePaths
end folder_ListStackPaths

command handler_AddToCallArray @tempArray, shortHKey, handlerArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
   -- currently no filtering
   -- put hkeyLine_FromHkey (shortHkey) into hTableLine
   put shortHkey into hTableLine
   put empty into tempArray ["hkeyCalls"][hTableLine]
   put empty into tempArray ["filteredCalls"][hTableLine]
   return empty
end handler_AddToCallArray

function handler_ConstructCallArray someHandler, pSkipHkeyComponents, pSkipHkeyProps
   -- this is slow, and needs to be as fast as possible as we want to call it on every script compile!
   -- should be modified to include "pass"
   
   local allCalls
   
   put word 1 to -1 of someHandler into someHandler
   handler_UnsplitScriptLines someHandler
   --
   delete line 1 of someHandler
   delete line -1 of someHandler
   
   put false into repeatUntilEndOfComment
   repeat for each line someLine in someHandler
      if repeatUntilEndOfComment is true then
         put char -2 to -1 of someLine into endCommentBit
         if endCommentBit = "*/" then
            put false into repeatUntilEndOfComment
         end if
         next repeat
      else if char 1 to 2 of word 1 of someLine = "/*" then
         put true into repeatUntilEndOfComment
         next repeat
      else
         -- first lt's deal with single line comments
         repeat for each item commentBlock in "--,#"
            if someLine contains commentBlock then
               put text_StripQuoted (someLine) into commentLine
               
               put wordOffset (commentBlock, commentLine) into wordNum
               if wordNum > 0 then
                  put word wordNum to -1 of commentLine into someComment
                  
                  if char -1 of word 2 of someComment = ":" then
                     set the itemdelimiter to ":"
                     put word 2 of item 1 of someComment into someKey
                     put word 1 to -1 of item 2 of commentLine into someValue
                     set the itemdelimiter to ","
                     
                     put metadataArray [someKey] into someIndex
                     line_Add someValue, someIndex
                     put someIndex into metadataArray [someKey]
                  end if
                  
                  -- delete the comments part
                  delete word wordNum to -1 of someLine
               end if
            end if
         end repeat
         
         if the number of words of someLine = 0 then next repeat
         
         put someLine into testLine
         replace " then " with CR in testLine
         replace " else " with CR in testLine
         repeat for each line testBit in testLine
            put token 1 of testBit into testComand
            if testComand is empty then next repeat
            
            switch
               case dict_IsLanguageTerm (testComand) is true
                  break
               case testComand = "dispatch"
                  put token 2 of testBit into dispatchCommand
                  -- put dispatchCommand,"c" into shortHKey
                  put "M" && dispatchCommand into shortHKey
                  
                  handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
                  
                  delete token 1 to 3 of someLine  -- let's look at the rest of the line
                  break
               case testComand is among the items of "send,call"
                  put token 2 of testBit into sendMessage
                  put token 1 of sendMessage into sendComand
                  -- put sendComand,"c" into shortHKey
                  put "M" && sendComand into shortHKey
                  
                  handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
                  
                  delete token 1 to 3 of someLine  -- let's look at the rest of the line
                  break
               default
                  -- first word and not a LiveCode term
                  -- put testComand,"M" into shortHKey
                  put "M" && testComand into shortHKey
                  
                  handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
                  
                  delete token 1 of someLine  -- let's look at the rest of the line
            end switch
         end repeat
         
         put _ExtractFunctionCalls (someLine, false) into fNames
         repeat for each line fName in fNames
            -- put fName,"F" into shortHKey
            put "F" && fName into shortHKey
            
            handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
         end repeat
         
         -- could still have other stuff on line
         set the wholematches to true
         put wordoffset ("the", someLine) into theWordNum
         if theWordNum is 0 then next repeat
         
         put theWordNum - 1 into setGetPutWordNum
         put word setGetPutWordNum to -1 of someLine into testLineBit
         
         put 3 into handlerTokenNum
         put token handlerTokenNum of testLineBit into hName
         if dict_IsLanguageTerm (hName) is true then next repeat
         
         -- now check getprop / setprop calls ("the xxx [zzz] of")
         
         put handlerTokenNum + 1 into ofTokenNum
         get token ofTokenNum of testLineBit
         if it is "[" then
            put handlerTokenNum + 4 into ofTokenNum
            get token ofTokenNum of testLineBit
         end if
         
         if it is "of" then
            put token 1 of testLineBit into setGetPut
            if setGetPut is "set" and "to" is among the words of someLine then
               if "_" is not in hName then
                  -- we assume by convention that a virtual property has the form
                  next repeat
               end if
               -- put hName,"s" into shortHKey
               put "S" && hName into shortHKey
               
               handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
            else -- if setGetPut is among the items of "case,if,get,put" then
               if "_" is not in hName then
                  -- we assume by convention that a virtual property has the form
                  next repeat
               end if
               --put hName,"g" into shortHKey
               put "G" && hName into shortHKey
               
               handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
            end if
         end if
      end if
   end repeat
   
   put tempArray ["hkeyCalls"] into someArray
   put keys (someArray) into metadataArray ["hkeyCalls"]
   put tempArray ["filteredCalls"] into someArray
   put keys (someArray) into metadataArray ["filteredCalls"]
   
   put sha1_Hash (someHandler) into handlerHash
   put handlerHash into metadataArray ["sha1"]
   -- hkey_AddToKeyWordArray metadataArray, hKey, handlerHash
   
   return metadataArray
end handler_ConstructCallArray

function handler_ExtractCalls someHandler, pSkipHkeyComponents, pSkipHkeyProps
   put handler_ConstructCallArray (someHandler, pSkipHkeyComponents, pSkipHkeyProps) into metadataArray 
   return metadataArray ["hkeyCalls"]
end handler_ExtractCalls

command handler_UnsplitScriptLines @someHandler
   put "\" & CR into toReplace 
   
   -- should use whitespace regExp
   -- put replaceText (stringToChange, matchExpression, replacementString)
   replace toReplace with empty in someHandler
end handler_UnsplitScriptLines

command hierachy_AddStackObjects @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return false
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
            
            # Above a card must be a stack
            put objectOwner into stackObject
            delete word 1 to 4 of stackObject
            _AddObjectAndBehaviors objectHierarchy, stackObject
            
            exit repeat
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
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierachy_AddStackObjects

command hierachy_AddStackObjects @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return false
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
            
            # Above a card must be a stack
            put objectOwner into stackObject
            delete word 1 to 4 of stackObject
            _AddObjectAndBehaviors objectHierarchy, stackObject
            
            exit repeat
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
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierachy_AddStackObjects

command hierarchy_AddEnv @objectHierarchy
   put env_ScriptHierarchy (true) into externalObjects
   if externalObjects is empty then return false
   
   set the wholematches to true
   repeat for each line sObject in objectHierarchy
      put lineOffset (sObject, externalObjects) into lineNum
      delete line lineNum of externalObjects
   end repeat
   if externalObjects is empty then return false
   
   put CR & word 1 to -1 of externalObjects after objectHierarchy
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierarchy_AddEnv

function hierarchy_Construct tObject, pPretty
   -- was "object_GetHierarchy"
   local objectHierarchy
   put the long id of tObject into tObject
   put pPretty is not false into pPretty
   
   put the hierarchy_ObjectAndBehaviors [pPretty] of tObject into objectHierarchy
   hierachy_AddStackObjects objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_Construct

function hkey_FindShortHkey shortHkey, pObject, pSearchObjects
   put word 1 to 2 of shortHkey into shortHkey
   
   # Make shortHkey public
   if char 1 of shortHkey = "P" then delete char 1 of shortHkey
   
   if exists (pObject) then
      # Search for private handlers
      put the hkey_Either [shortHkey] of pObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
      line_Delete pSearchObjects, pObject -- so we dont search it again later
   end if
   
   # Search for public handlers in pSearchObjects
   repeat for each line foundObject in pSearchObjects
      if exists (foundObject) is false then next repeat
      
      put the hkey_Or [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty  
end hkey_FindShortHkey

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function htable_GetEither searchHkeyLine, hTable
   -- matches either private of public handlers
   -- returns just the foundHkey (we dont need line numbers)
   put char -1 of word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into searchName
   
   repeat for each line hLine in hTable
      put word 2 of hLine into foundName
      put word 1 of hLine into foundPublicType
      if foundName is not searchName then next repeat
      
      put char -1 of foundPublicType into fType
      switch
         case hType = fType
         case (hType = "C") AND (fType = "M")
         case (hType = "M") AND (fType = "C")
            put word 5 to -1 of line 1 of hTable into hObject
            put hKeyLine_Construct (foundName, foundPublicType, hObject) into foundHkey
            return foundHkey
      end switch
   end repeat
   return empty
end htable_GetEither

function htable_GetOr searchHkeyLine, hTable
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   --
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum
   if the result is false then return empty
   
   put word 5 to -1 of line 1 of hTable into tObject
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end htable_GetOr

command htable_OrLineOffsets hName, hType, hTable, @startLineNum, @endLineNum
   repeat for each line hLine in hTable
      if hName is not word 2 of hLine then next repeat
      
      switch
         case hType = word 1 of hLine
         case (hType = "C") AND (word 1 of hLine = "M")
         case (hType = "M") AND (word 1 of hLine = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_OrLineOffsets

command htable_OrLineOffsets hName, hType, hTable, @startLineNum, @endLineNum
   repeat for each line hLine in hTable
      if hName is not word 2 of hLine then next repeat
      
      switch
         case hType = word 1 of hLine
         case (hType = "C") AND (word 1 of hLine = "M")
         case (hType = "M") AND (word 1 of hLine = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_OrLineOffsets

command ide_FilterOutStacks @longIDs
   put rev_AppContentsFolder() into revAppContentsFolder
   
   set the itemdelimiter to slash
   repeat for each line tObject in longIDs
      if exists(tObject) is false then next repeat
      put token -1 of tObject into stackPath
      if stackPath begins with revAppContentsFolder then next repeat
      put revRuggedId (tObject) & CR after filteredObjects
   end repeat
   delete char -1 of filteredObjects
   put filteredObjects into longIDs
end ide_FilterOutStacks

command line_Add someLines, @someIndex
   repeat for each line someLine in someLines
      if someLine is empty then next repeat
      set the wholematches to true
      put lineoffset(someLine, someIndex) into lineNum
      if lineNum is 0 then
         put the number of lines of someIndex into maxLine
         put maxLine + 1 into lineNum
         put someLine into line lineNum of someIndex
      else
         put lineNum & comma after lineNums
      end if
   end repeat
   delete char -1 of lineNums
   return lineNums
end line_Add

command line_Delete someLine, @someIndex
   set the wholematches to true
   put lineoffset (someLine, someIndex) into lineNum
   delete line lineNum of someIndex
   return lineNum
end line_Delete

function module_ConstructFolder stackPath
   put project_FolderFromPath (stackPath) into projectFolder
   if there is not a folder projectFolder then return empty
   
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   if item (pNum + 1) of stackPath is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of stackPath & slash into moduleFolder
   return moduleFolder
end module_ConstructFolder

function module_ConstructShortFolder sPath
   put module_ConstructFolder (sPath) into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   return shortFolder
end module_ConstructShortFolder

function module_FolderFromPath stackPath, projectFolder
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   if item (pNum + 1) of stackPath is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of stackPath & slash into moduleFolder
   return moduleFolder
end module_FolderFromPath

function module_NameFromPath sPath
   put module_ConstructShortFolder (sPath) into moduleName
   replace "_" with "|" in moduleName
   return moduleName
end module_NameFromPath

command object_AddBehaviors @objectIndex
   repeat for each line someObject in objectIndex
      if exists (someObject) is false then next repeat 
      put the behavior of someObject into objectBehavior
      if exists (objectBehavior) then
         put revRuggedId (objectBehavior) & CR after newObjectIndex
      end if
      put someObject & CR after newObjectIndex
   end repeat
   delete char -1 of newObjectIndex
   put newObjectIndex into objectIndex
end object_AddBehaviors

function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath

function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath

function rev_AppContentsFolder
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/
   set the itemdelimiter to slash
   put the engine folder into appContentsFolder
   put empty into item -1 of appContentsFolder
   return appContentsFolder
end rev_AppContentsFolder

function sha1_Hash someData
   local hexDigest
   put sha1digest (someData) into someBinaryData
   get binarydecode ("H*", someBinaryData, hexDigest)
   return hexDigest
end sha1_Hash

function stack_FirstControl sPath
   if exists (control 1 of card 1 of stack sPath) then
      return the long id of control 1 of card 1 of stack sPath
   else
      return empty
   end if
end stack_FirstControl

function stack_PathsToObjects stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return word 1 to -1 of stackObjects
end stack_PathsToObjects

function text_StripQuoted someText
   put _ConstructQuoteReg() into someReg
   put replaceText (someText, someReg, "•••") into strippedText
   return strippedText
end text_StripQuoted

command view_NormalizeName @viewPath
   if viewPath is empty then return false
   view_NormalizePiped viewPath
   
   set the itemdelimiter to "|"
   if item 1 of viewPath is not among the items of "View|Layout" then put "View|" before viewPath
   return true
end view_NormalizeName

command view_NormalizePiped @viewPath, pMakePretty
   if viewPath is empty then return false
   put word 1 to -1 of viewPath into viewPath
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of viewPath
      put word 1 to -1 of item itemNum of viewPath into someItem
      if pMakePretty is true then
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someItem
      end if
      put someItem into item itemNum of viewPath
   end repeat
   return true
end view_NormalizePiped

command walk_SetSearchHierarchy pSearchObjects
   if pSearchObjects is empty then
      put env_ScriptHierarchy (true) into pSearchObjects
   end if
   --
   put pSearchObjects into WalkSearchHierarchy
end walk_SetSearchHierarchy


--> Private
-
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

private function _ConstructQuoteReg
   -- put "(" & quote & "[^" & quote & "]*" & quote & ")" into someReg
   get "•([^•\\]|\\.)*•|'([^'\\]|\\.)*'"
   replace "•" with quote in it
   return it
end _ConstructQuoteReg

private function _ExtractFunctionCalls scriptLine, pIncludeBuiltinFunctions
   -- recursive function
   local fNames
   
   put text_StripQuoted (scriptLine) into scriptLine
   -- put "(\w+)\s*" & "\((.*)\)" into greedyExpression -- error with handlers that use "." notation
   -- if matchtext(scriptLine, greedyExpression, wordBefore, bracketedStuff) is true then
   
   put "\((.*)\)" into bracketExpression
   if matchchunk (scriptLine, bracketExpression, startBracketedStuff, endBracketedStuff) is true then
      put char startBracketedStuff to endBracketedStuff of scriptLine into bracketedStuff
      get char 1 to (startBracketedStuff - 1) of scriptLine
      put token -2 of it into wordBefore
      if wordBefore is among the chars of "[()]" then
         -- hack
         put empty into wordBefore
      end if
      
      if bracketedStuff contains "(" then
         put _ExtractFunctionCalls (bracketedStuff, pIncludeBuiltinFunctions) into innerFunctions
         
         if pIncludeBuiltinFunctions is true then
            repeat for each line innerFunction in innerFunctions
               line_Add innerFunction, fNames
            end repeat
         else
            repeat for each line innerFunction in innerFunctions
               if dict_IsLanguageTerm(innerFunction) is false then
                  line_Add innerFunction, fNames
               end if
            end repeat
         end if
      end if
      
      if wordBefore is not empty then
         if pIncludeBuiltinFunctions is true then
            line_Add wordBefore, fNames
         else
            if dict_IsLanguageTerm (wordBefore) is false then
               line_Add wordBefore, fNames
            end if
         end if
      end if
      return word 1 to -1 of fNames
   else
      return empty
   end if
end _ExtractFunctionCalls

private function _GetHandlerCalls hKeyLine, rObject, pSkipDisplay
   -- htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum -- breaks as revAvailableHandlers has changed M/C
   put the revAvailableHandlers of rObject into hTable
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum -- should it be Either private or public?
   if endLineNum = 0 then return empty
   
   # Get handler
   put the script of rObject into someScript
   put line startLineNum to endLineNum of someScript into foundHandler
   
   # Check it is not to be skipped
   if the shiftkey is "Up" AND pSkipDisplay is true then
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

private command _WalkHkeyRecursive shortHkey, parentHKeyLine, @hKeyArray, pSkipDisplay
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
   
   # Add it to the array
   if hKeyArray [parentHKeyLine][foundCall] is true then return empty -- already indexed (don't recurse)
   put true into hKeyArray [parentHKeyLine][foundCall]
   
   # Repeat and recurse for each call found
   hkeyLine_Deconstruct foundCall, fName, fType, fObject
   put _GetHandlerCalls (foundCall, fObject, pSkipDisplay) into childShortHkeys
   repeat for each line childShortHkey in childShortHkeys
      set the cursor to busy
      _WalkHkeyRecursive childShortHkey, foundCall, hKeyArray
   end repeat
   --
   return true
end _WalkHkeyRecursive
