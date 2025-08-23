script "lib_OldCalls"
--> MetaData
-
license: GPLv3
name: lib_OldCalls
type: library
version: 0.1

/*
Should move this to "lib_Junk"
*/


--> hkey | Find | Array | Old
-
getprop hkey_InHierarchy [hKey]
   put the long id of the target into tObject
   --
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put hType && hName into shortHKey
   --
   put hkey_FoundArray (shortHKey, tObject, pProjectName) into foundArray 
   return foundArray ["foundHkey"]
end hkey_InHierarchy

function hkey_FindUsingFoundArray shortHKey, tObject, pProjectName
   -- use "hkey_Find" instead -- was "hkey_FindInHierarchy")
   put hkey_FoundArray (shortHKey, tObject, pProjectName) into foundArray 
   return foundArray ["foundHkey"]
end hkey_FindUsingFoundArray

function hkey_FoundArray shortHKey, tObject, pProjectName
   hkey_Deconstruct shortHKey, hName, hType, xObject, xNum
   put the script_Hierarchy [pProjectName] of tObject into searchHierarchy
   
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
end hkey_FoundArray

function hkey_FindExternalObjectArray hName, hType, externalObjects
   -- ignores private handlers
   -- finds in order of objects
   put hType && hName into shortHkey
   repeat with lineNum = the number of lines of externalObjects down to 1
      put line lineNum of externalObjects into foundObject
      put the revAvailableHandlers of foundObject into hTable
      --
      repeat for each line someLine in hTable
         if word 1 to 2 of someLine = shortHkey then
            put hTable into foundArray [foundObject]["handlerTable"]
            put word 3 of someLine into foundArray [foundObject]["startLineNum"]
            put word 4 of someLine into foundArray [foundObject]["endLineNum"]
            put hKeyLine_Construct (hName, hType, hObject) into foundArray [foundObject]["foundHkey"]
            exit repeat
         end if
      end repeat
   end repeat
   return foundArray
end hkey_FindExternalObjectArray

command hkey_FindScriptLine hKey, someScript, @scriptLine, @lineNum
   put word 1 to -1 of someScript into someScript
   script_ExtractAndStripMultiLineComments someScript, mulitLineComment
   put script_StripComments (someScript) into someScript
   
   put someScript into testScript
   put text_StripQuoted (testScript, "•••") into testScript
   
   hkey_Deconstruct hKey, hName, hType, scriptObject, hNum
   put empty into scriptLine
   put 0 into lineNum
   put 0 into lastWordNum
   repeat
      put wordoffset (hName, testScript, lastWordNum) into wordNum
      if wordNum = 0 then return false
      
      get testScript
      delete word (wordNum + lastWordNum + 1) to -1 of it
      put the number of lines of it into lineNum
      put word 1 to -1 of line lineNum of someScript into scriptLine
      
      switch hType
         case "g"
            if word (wordNum - 1) of someScript = "the" then return true
         case "s"
            if word (wordNum - 1) of someScript = "the" then return true
         case "c"
            if hName = token 1 of scriptLine then return true
         case "f"
            put someScript into testFunctionScript
            delete word 1 to (wordNum + lastWordNum) of testFunctionScript
            if token 1 of testFunctionScript = "(" then return true
         case "m"
            if hName = token 1 of scriptLine then return true
      end switch
      put empty into scriptLine
      put 0 into lineNum
      put wordNum into lastWordNum
   end repeat
   return false
end hkey_FindScriptLine


--> Handler | Calls | Old
-
/*
Old and dodgy handlers that try to follow getprop and setprop references to objects (not used anymore?)
*/

private function hkey_ConstructPropertyCall linkCall, linkName, linkType, linkObject, linkNum, someHandler
   -- total hack !!!
   put script_GetPropertyTarget (linkName, someHandler, someObject) into propertyTarget
   if exists (propertyTarget) is false then
      put "script_GetPropertyTarget" && linkName & "," && someObject into someError
      lcw_Notify someError, true
      put someObject into propertyTarget -- total hack !!!
   end if
   
   -- now find property linkName in the script_Hierarchy of propertyTarget
   put hkey_Construct (linkName, linkType, propertyTarget, linkNum) into testKey
   put the hkey_InHierarchy [testKey] of propertyTarget into propertyHandlerObject
   
   if exists (propertyHandlerObject) is false then
      -- it is a plain custom property
      put propertyTarget into propertyHandlerObject 
      put "Custom property of" && propertyHandlerObject into missingPropertyCall
      put hkey_Construct (linkName, linkType, missingPropertyCall, linkNum) into linkCall
   else
      -- we have found a custom property handler in the hierarchy
      -- not sure how but should mark property as plain custom property (not handled by a custom handler)
      put hkey_Construct (linkName, linkType, propertyHandlerObject, linkNum) into linkCall
   end if
   return linkCall
end hkey_ConstructPropertyCall

function handler_ParseForCalls someHandler, scriptHierarchy, someObject
   -- was "script_ParseHandlerForCalls"
   -- use "handler_ExtractCalls"
   
   put empty into allCalls
   put someHandler into oHandler
   script_CleanForCalls someHandler -- clean and remove first and last lines
   
   repeat for each line someLine in someHandler
      set the itemdelimiter to "#"
      put word 1 to -1 of item 1 of someLine into someLine
      if char 1 to 2 of someLine is "--" then next repeat
      
      put token 1 of someLine into testComand
      if testComand is empty then next repeat
      
      if dict_IsLanguageTerm (testComand) is false then
         script_AddToExtractCalls testComand, "c", scriptHierarchy, allCalls
      end if
      
      put _ExtractFunctionCalls (someLine, false) into fNames
      -- script_ExtractFunctionCallOfLine someLine, fName, bracketedStuff
      -- if fName is "(" then breakpoint
      script_AddToExtractCalls fNames, "f", scriptHierarchy, allCalls
      
      set the wholematches to true
      -- could still have other stufff on line
      put wordoffset ("the", someLine) into wordNum
      if wordNum is 0 then next repeat
      
      put word (wordNum + 1) of someLine into handlerName
      -- get word (wordNum + 1) to -1 of someLine
      -- put token 1 of it into handlerName
      if dict_IsLanguageTerm (handlerName) is true then next repeat
      
      -- now check getprop / setprop calls
      -- "the xxx [zzz] of"  (should change to use tokens)
      put wordNum + 2 into ofWordNum
      get word ofWordNum of someLine
      if it contains "[" then
         put wordNum + 5 into ofWordNum
         get word ofWordNum of someLine
      end if
      if it is "of" then
         put word (wordNum - 1) of someLine into setGetPut
         put scriptHierarchy into sendHierarchy -- default
         
         -- Here we can "try" to work out which object is being called
         put word (ofWordNum + 1) of someLine into objectWord
         if dict_IsLanguageTerm(objectWord) is true then
            -- probably "stack,background,group etc
            -- give up for now
         else
            -- lets assume it is a customproperty
            -- find the line which defines the object objectWord int the handler
            script_ExtractPutTheInto someHandler, objectWord, objectReference, targetObject
            if objectReference is empty then
               lcw_Notify ("Can't find reference for object" && kwote(objectWord))
            else
               if targetObject is among the items of "me,target" then put someObject into targetObject
               
               if exists(targetObject) is false then
                  lcw_Notify someHandler
               else
                  put the objectReference of targetObject into sendObject
                  if exists(sendObject) then
                     put the script_Hierarchy of sendObject into sendHierarchy
                  end if
               end if
            end if
         end if
         
         if setGetPut is "set" and "to" is among the words of someLine then
            script_AddToExtractCalls handlerName, "s", sendHierarchy, allCalls
         else -- if setGetPut is among the items of "case,if,get,put" then
            script_AddToExtractCalls handlerName, "g", sendHierarchy, allCalls
         end if
      end if
   end repeat
   
   -- sort allCalls
   return allCalls
end handler_ParseForCalls

command script_AddToExtractCalls handlerNames, handlerType, scriptHierarchy, @allCalls
   put false into notPrivate -- bug! Need to change so it only searches objects script for private
   repeat for each line handlerName in handlerNames
      if scriptHierarchy is empty then
         put handlerName,handlerType into hKey
      else
         put script_Hierarchy (handlerName, handlerType, scriptHierarchy, notPrivate) into hKey
      end if
      line_Add hKey, allCalls
   end repeat
end script_AddToExtractCalls

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

--> Junk
-
function hkey_FetchLinkArray hKey, pFetchHow
   -- this handler is mainly to show the different ways of fetching hkeyLinkArray
   switch pFetchHow
      case "stored hkeyLinkArray"
         put hkey_GetLinkArray (hKey) into hkeyLinkArray
         return hkeyLinkArray
      case "stored script_LinkArray"
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         put the script_LinkArray of hObject into scriptLinkArray
         put hkeyArray_ExtractSubArray (hKey,scriptLinkArray) into hkeyLinkArray
         return hkeyLinkArray
      case "from object"
         -- does not use hArray
         put hkey_ScriptDependencyArray (hKey) into hkeyLinkArray
         return hkeyLinkArray
      case "library_HkeyFolder()"
         -- mixture of hArray and walking
         put library_HkeyFolder (hKey) into hkeyLinkArray
         return hkeyLinkArray
      default  -- everywhere but fastest first
         put hkey_GetLinkArray (hKey) into hkeyLinkArray
         if hkeyLinkArray is an array then return hkeyLinkArray
         
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         if exists (hObject) is false then
            -- breakpoint
            return empty
         end if
         
         put the script_LinkArray of hObject into hkeyLinkArray
         if hkeyLinkArray is an array then return hkeyLinkArray
         
         put library_HkeyFolder (hKey) into hkeyLinkArray
         return hkeyLinkArray
   end switch
end hkey_FetchLinkArray


--> LinkArray | Model
-
/*
This is old!
Use overlay_Folder related stuff now.

A LinkArray is used to graph arrays. To do this LinkArrays provide a suite of tools that take complex keys and convert them into simple IDs,
and dictionaries to translate from these IDS to the orginal keys.

This new model uses default custom properties that can be used to get and set each of the three inter-connected arrays.
As these are default custom properties, they can be over-ridden locally.

The default behavior is to store the array in a file, in a default folder (named after the object), inside the opn_Model folder.
Later this folder can be moved, and the scripts re-directed to this model folder using the "model_Folder" property (see model_File).
*/

command linkArray_Get modelObject, @idLinkArray, @idArray, pModelName
   put the model_IdArray [pModelName] of modelObject into idArray
   put the model_IdLinkArray [pModelName] of modelObject into idLinkArray
end linkArray_Get

command linkArray_Set modelObject, idLinkArray, idArray
   set the model_IdArray [pModelName] of modelObject to idArray
   set the model_IdLinkArray [pModelName] of modelObject to idLinkArray
end linkArray_Set


--> Handler
-
function handler_IsComponent someHandler
   -- this uses regular expression (http://www.regextester.com/pregsyntax.html)
   -- may be faster way of checking
   put "--\s*component\s*:\s*true\b" into someReg
   put matchtext (someHandler, someReg) into someBoolean
   return someBoolean
end handler_IsComponent

function handler_ListExportedShortHkeys stackName
   put handler_ListShortExportedFolders (stackName) into hkeyFolders
   set the itemdelimiter to "_"
   repeat for each line hkeyFolder in hkeyFolders
      put item -1 of hkeyFolder into hType
      delete item -1 of hkeyFolder
      put hkeyFolder,hType into shortHkey
      put shortHkey & CR after shortHkeys
   end repeat
   delete char -1 of shortHkeys
   return shortHkeys
end handler_ListExportedShortHkeys

function handler_ListShortExportedFolders stackName
   put the handler_Folder of stack stackName into handlerFolder
   put the defaultfolder into oDefault
   set the defaultfolder to handlerFolder
   put the folders into hkeyFolders
   filter hkeyFolders without ".*"
   set the defaultfolder to oDefault
   return hkeyFolders
end handler_ListShortExportedFolders


--> Old Mixed | Hkey | Deps
-
function hkey_ExtractShortCalls hKey
   put hArray_GetHandler (hKey) into callHandler
   put handler_ExtractCalls (callHandler) into shortCalls
   return shortCalls
end hkey_ExtractShortCalls

function script_ExtractSubGraphArray shortHkey, scriptHkey, pSetName, pTestExceptions
   put hkey_GetLinkArray (scriptHkey) into scriptHkeyArray
   put hkeyArray_ExtractSubArray (shortHkey, hkeyArray) into hKeySubGraphArray
   return hKeySubGraphArray
end script_ExtractSubGraphArray

function hkey_ConstructShortKeyArray hKeys
   repeat for each line hKey in hKeys
      hkey_Deconstruct hKey, hName, hType, hObject, hNum
      put hName,hType into shortHkey
      put empty into shortHkeyArray [shortHkey][hKey]
   end repeat
   return shortHkeyArray
end hkey_ConstructShortKeyArray


getprop script_IsGlobal [hKey]
   -- should the handlers in this script be exported by default into the hkey handler library?
   -- place a "getprop script_IsGlobal" in an object if you want to override the default behavior below
   put the uRIP ["type"] of the target into scriptType
   switch
      case scriptType contains "library"
         return true
      case scriptType contains "model"
         return true
      case scriptType contains "behavior"
         return true
      case scriptType contains "front script"
         return true
      case scriptType contains "backscript"
         return true
      default
         return false
   end switch
end script_IsGlobal

command hkey_StoreCallsAndHandler hkey, someHandler, hKeyCalls
   /*
   Used by a number of hArray walk scripts
   For now, not storing anything (by default), other than handlers in a uRip marked library
   */
   hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
   
   if the script_IsGlobal [hKey] of scriptObject is true then
      hkey_StoreHandler hKey, someHandler
      hkey_StoreCalls hKey, hKeyCalls
      return true
   else
      put "Not stored" && hKey into someMessage
      lcw_Notify someMessage
      return false
   end if
end hkey_StoreCallsAndHandler


--> hkey | overlaydata | hkeyArray | Model
-
command hkey_SetOverlayArray hKey, overlayArray, pOverlayName
   hkey_StripDefaultDotArray overlayArray
   
   put hkey_FetchOverlayData (hKey) into overlayData
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayArray into overlayData [pOverlayName]
   hkey_SaveOverlayData hKey, overlayData
end hkey_SetOverlayArray


--> hkey | overlaydata | Metadata | Model
-
function hkey_GetMetadataArray hKey
   put hkey_FetchOverlayData (hKey) into overlayData
   put overlayData ["metadata"] into metadataArray
   return metadataArray
end hkey_GetMetadataArray

command hkey_SetMetadataArray hKey, metadataArray
   put hkey_FetchOverlayData (hKey) into overlayData
   put metadataArray into overlayData ["metadata"]
   hkey_SaveOverlayData hKey, overlayData
   return overlayData
end hkey_SetMetadataArray


--> hKey | Find  | hArray | Old ???
-
getprop hkey_FindInFullHierarchy [shortHkey]
   -- was "script_FindInFullHierarchy"
   /*
   It includes front scripts and the object itself should it contain the call.
   Currently it ignores Rev development environment.
   */
   if the number of items of shortHkey = 2 then
      put item 1 of shortHkey into handlerName
      put item 2 of shortHkey into handlerType
      put the long id of the target into scriptObject
      put hkey_Construct (handlerName, handlerType, scriptObject) into hKey
   else
      put shortHkey into hKey
   end if
   
   put the script_Hierarchy of the target into scriptHierarchy
   put hkey_SearchObjectHierarchy (hKey, scriptHierarchy) into foundHkey
   return foundHkey
end hkey_FindInFullHierarchy

function hkey_FindAndIndex hName, hType, hObject, pSetName, pNoLibraryBehaviors
   put the script_Hierarchy [pSetName] of hObject into scriptHierarchy
   
   if exists (hObject) is false then
      put hObject && "does not exist! Exiting..." into someMessage
      lcw_Notify someMessage, true
      return empty
   end if
   
   put hName,hType into shortHKey
   
   repeat with lineNum = (the number of lines of scriptHierarchy) down to 1
      set the cursor to busy
      put line lineNum of scriptHierarchy into testObject
      -- lcw_Notify testObject, true
      
      if exists (testObject) is false then
         put testObject && "does not exist! Skipping..." into someMessage
         lcw_Notify someMessage
         next repeat
      end if
      
      switch the hArray_IsCurrent of testObject 
         case empty
            put testObject && "is locked... skipping..." into someMessage
            lcw_Notify someMessage
            next repeat
         case false
            -- add to global index so we can search
            object_AddToGlobalArray testObject
            break
         default -- case true
            -- keep on trucking
      end switch
      
      if the long id of testObject = the long id of hObject then
         -- allow private handlers (as it is where the shortHkey is called from )
         if the hArray_HkeyPresent [shortHKey] of testObject is false then next repeat
         put hkey_Construct (hName, hType, testObject) into foundHkey
         return foundHkey
      else
         -- Don't allow private handlers (not where the shortHkey is called from)
         if the hArray_PublicKeyPresent [shortHKey] of testObject is false then next repeat
         put hkey_Construct (hName, hType, testObject) into foundHkey
         return foundHkey 
      end if
   end repeat
   
   -- gone through every object in hierarchy
   return empty 
end hkey_FindAndIndex

command hkey_FastFindHandlerAndKey hName, hType, hObject, @foundHkey, @foundHandler
   put the script_Hierarchy [pSetName] of hObject into scriptHierarchy
   hkey_AddDevelopmentHierarchy scriptHierarchy, empty, hObject
   
   if exists (hObject) is false then
      put hObject && "does not exist! Exiting..." into someMessage
      lcw_Notify someMessage, true
      return empty
   end if
   
   put hName,hType into shortHKey
   
   repeat with lineNum = (the number of lines of scriptHierarchy) down to 1
      set the cursor to busy
      put line lineNum of scriptHierarchy into testObject
      -- put testObject
      
      if exists (testObject) is false then
         put testObject && "does not exist! Skipping..." into someMessage
         lcw_Notify someMessage, true
         next repeat
      end if
      
      switch the hArray_IsCurrent of testObject 
         case empty
            put testObject && "is locked... skipping..." into someMessage
            lcw_Notify someMessage
            next repeat
         case false 
            object_AddToGlobalArray testObject
            break
         default -- case true
            -- keep on trucking
      end switch
      
      if the long id of testObject = the long id of hObject then
         -- allow private handlers (as it is where the shortHkey is called from )
         
         if the hArray_HkeyPresent [shortHKey] of testObject is false then next repeat
         
         put hkey_Construct (hName, hType, testObject) into foundHkey
         put library_FetchHandler (foundHkey) into foundHandler
         return hKey
      else
         -- Don't allow private handlers (not where the shortHkey is called from)
         
         if the hArray_PublicKeyPresent [shortHKey] of testObject is false then next repeat
         
         put hkey_Construct (hName, hType, testObject) into foundHkey
         put library_FetchHandler (foundHkey) into foundHandler
         return hKey 
      end if
   end repeat
   
   -- gone through every object in hierarchy
   put empty into foundHkey
   put empty into foundHandler
   return empty 
end hkey_FastFindHandlerAndKey

function hkey_SearchObjectHierarchy hKey, scriptHierarchy
   -- was "script_SearchObjectHierarchy"
   /*
   This script finds where a handler call is in the hierarchy.
   It returns multiple objects if the handler is passed and also intercepted further up the hierarchy.
   
   It does not use any caching at the moment but looks directly at the script.
   */
   hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
   hkey_FindHandlerInHierarchy handlerName, handlerType, scriptObject, scriptHierarchy, foundHKey, callHandler
   
   hkey_Deconstruct foundHKey, foundHandlerName, foundHandlerType, foundScriptObject, handlerNum
   return foundScriptObject
end hkey_SearchObjectHierarchy

function hkey_FindAndExtractCalls hKey, pEnvironmentFilter, pHkeyArray, pScriptObject
   local foundHKey, foundHandler
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if pScriptObject is empty then put hObject into pScriptObject
   
   put the script_Hierarchy [pEnvironmentFilter] of pScriptObject into scriptHierarchy
   hkey_FindHandlerInHierarchy hName, hType, pScriptObject, scriptHierarchy, foundHKey, foundHandler
   hkey_Deconstruct foundHkey, foundName, foundType, foundObject, foundNum
   
   -- save unecessary indexing work
   if foundHkey is among the lines of keys (pHkeyArray) then
      lcw_Notify merge ("Already indexed '[[hkey]]'. Lets not index it again please :)")
      return empty
   end if
   
   -- get handler calls
   -- this should be short calls for simplicity and speed of recursion
   
   put library_FetchHandler (foundHkey) into storedHandler
   if foundHandler = storedHandler and pForceSearch is not true then
      -- already stored, faster to fetch stored calls
      put hkey_FetchCalls (foundHkey) into handlerCalls
   else
      put the script_Hierarchy [pEnvironmentFilter] of foundObject into foundHierarchy
      put handler_ParseForCalls (foundHandler, foundHierarchy, foundObject) into handlerCalls
      hkey_StoreCallsAndHandler foundHkey, foundHandler, handlerCalls
   end if
   return handlerCalls
end hkey_FindAndExtractCalls

command hkey_FindHandlerInHierarchy handlerName, handlerType, scriptObject, scriptHierarchy, @hKey, @foundHandler, pNotPrivate
   -- this is the step that takes time
   -- looks for first hKey in scriptHierarchy
   local startHandler, endHandler
   
   if exists (scriptObject) is false then
      put scriptObject && "does not exist! Exiting..." into someMessage
      lcw_Notify someMessage, true
      return empty
   end if
   
   --  and from now on search rest of hierarchy only for public handler
   put handlerName,handlerType into shortHKey
   repeat with lineNum = (the number of lines of scriptHierarchy) down to 1
      set the cursor to busy
      put empty into hKey
      put line lineNum of scriptHierarchy into someObject
      
      if exists (someObject) is false then
         put someObject && "does not exist! Skipping..." into someMessage
         lcw_Notify someMessage, true
         next repeat
      end if
      
      if the long id of someObject = the long id of scriptObject then
         -- as it is the script object where the shortHkey is called from 
         -- allow private handlers
         
         if the hArray_IsCurrent of someObject is true then
            if the hArray_HkeyPresent [hKey] of someObject is true then
               put hkey_Construct (handlerName, handlerType, someObject) into hKey
               put library_FetchHandler (hKey) into foundHandler
               return hKey
            end if         
         else
            -- not properly indexed, so do it manually.
            try
               put the script of someObject into someScript
               
               -- don't think we need to have this option 
               -- change to look for either. Forget whether handlerType = "p"
               if char 1 of handlerType = "p" then
                  put handlerType into privateHandlerType
                  
                  put handlerName,privateHandlerType into shortHKey
                  hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
                  put the result into foundHandler
                  
                  if foundHandler is not empty then
                     -- found private handler => construct and return hKey
                     put hkey_Construct (handlerName, privateHandlerType, someObject) into hKey
                     return hKey
                  else
                     -- no point in searching hierarchy for private handlers
                     return empty
                  end if
               else
                  -- should find first regardless of public or private
                  -- for now finds private first
                  put "p" & handlerType into privateHandlerType
                  
                  put handlerName,privateHandlerType into shortHKey
                  hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
                  put the result into foundHandler
                  
                  if foundHandler is not empty then
                     -- found private handler => construct and return hKey
                     put hkey_Construct (handlerName, privateHandlerType, someObject) into hKey
                     return hKey
                  else
                     -- lets try public
                     put handlerName,handlerType into shortHKey
                     hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
                     put the result into foundHandler
                     if foundHandler is not empty then
                        -- found public handler => construct and return hKey
                        put hkey_Construct (handlerName, handlerType, someObject) into hKey
                        return hKey
                     end if
                  end if
                  
               end if
            catch someError
               -- locked
               put "Did not search" && the mobile_Name of someObject && "as it's script is locked!" into someMessage
               lcw_Notify someMessage, true
               next repeat
            end try
         end if
      else
         -- not the script object where the shortHkey is called from
         -- don't allow private handlers
         
         if the hArray_IsCurrent of someObject is true then
            if the hArray_PublicHkeyPresent [hKey] of someObject is true then
               put hkey_Construct (handlerName, handlerType, someObject) into hKey
               put library_FetchHandler (hKey) into foundHandler
               return hKey
            end if         
         else
            try
               put the script of someObject into someScript
            catch someError
               -- locked
               next repeat
            end try
            
            hkey_SetOffsets shortHKey, startHandler, endHandler, someScript, pNotPrivate
            put the result into foundHandler
            if foundHandler is empty then next repeat
            if script_HandlerContainsPass (handlerName, foundHandler) is false then
               -- found => construct and return hKey
               put hkey_Construct (handlerName, handlerType, someObject) into hKey
               return hKey
            end if
         end if
         
      end if
   end repeat
   
   -- gone through every object in hierarchy
   return empty
end hkey_FindHandlerInHierarchy

function hkey_Search hKey, pSearchHow 
   local pSetName
   
   switch pSearchHow
      case "not hdb"
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         put hkey_FindAndIndex (hName, hType, hObject, pSetName) into foundHkey
         return foundHkey
      case "not hierarchy"
         put hArray_SimpleSearch (hKey) into foundHkey
         return foundHkey
      default
         put item 1 to 2 of hKey into shortHKey
         put item 3 of hKey into pScriptObject
         if exists (pScriptObject) is false then
            put hArray_FindHkey (shortHkey) into foundHkey
            
            if foundHkey is empty then
               -- should use rev search
               hkey_Deconstruct hKey, hName, hType, hObject, hNum
               put the long id of the target into hObject -- hack
               put hkey_FindAndIndex (hName, hType, hObject, pSetName) into foundHkey
               return foundHkey
            else
               return foundHkey
            end if
         else
            put hArray_FindHkeyInHierarchy (shortHKey, pScriptObject) into foundHkey
            return foundHkey
         end if
   end switch
end hkey_Search

function hArray_SimpleSearch hKey, pHandlerHash
   put hArray_GetFoundHkeyArray (hKey) into hkeyArray
   if pHandlerHash is empty then
      -- let's get the hKey with the shortest object reference
      put keys (hkeyArray) into foundHKeys
      sort numeric lines of foundHKeys by the number of chars of item 3 of each
      put line 1 of foundHKeys into foundHKey
      return foundHKey
   else
      repeat for each key foundHKey in hkeyArray
         if hkeyArray [hKey]["handlerHash"] is pHandlerHash then
            return foundHKey
         end if
      end repeat
      return empty
   end if
end hArray_SimpleSearch


