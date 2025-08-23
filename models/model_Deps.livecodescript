script "model_Deps"
--> MetaData
-
license: GPLv3
name: model_Deps
type: model
version: 0.2


/*
This seems a bit old, and a bit mixed up.

A library to handle dependencies (in particular script dependencies).
It used to be in "libOPN_Deps"

It provides code for graphing dependencies, and extracting handlers required by a script or stack to function.
It also enables the automatic creation of depndency behavior scripts for libraries.

The Main Stack| Meta Array is the combined hArray and mainStackArray export format.

It superceded the older handlers below. 
There were some problems with stackObject references to substacks,
and the organisation requires some repetition in order to allow accumilation of hArray data as the parsing procedes.
In addition there is some duplication of data, particulalry the "scriptArray" and "objects" sections of the two main arrays.
This woud probably be much better stored in an sqlite database.
*/


--> Working on
-
function hkey_TestFetchDeps hKey, someHandler, pSkipHkeyComponents, pSkipHkeyProps
   put hkey_TestShortDeps (hKey, someHandler, pSkipHkeyComponents, pSkipHkeyProps) into shortBoolean
   if shortBoolean = false then return false
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if exists (hObject) is false then return shortBoolean  
   
   if pSkipHkeyComponents is empty then put pref_GetValue ("skip_HkeyComponents") is not false into pSkipHkeyComponents
   if pSkipHkeyProps is empty then put pref_GetValue ("skip_HkeyProps") is not false into pSkipHkeyProps
   
   put the uRIP ["Type"] of hObject into objectType
   put the object_MetaData ["component"] of hObject into scriptIsComponent
   switch
      case hkey_IsDataGridCall (hKey, hName, hType, hObject) is true
         return false
      case scriptIsComponent is true and pSkipHkeyComponents is true
         return false
      case objectType is not "library" and hType is among the items of "g,s" and pSkipHkeyProps is true
         return false
      default
         return true
   end switch
end hkey_TestFetchDeps

function hkey_TestShortDeps hKey, someHandler, pSkipHkeyComponents, pSkipHkeyProps
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if pSkipHkeyComponents is empty then put pref_GetValue ("skip_HkeyComponents") is not false into pSkipHkeyComponents
   if pSkipHkeyProps is empty then put pref_GetValue ("skip_HkeyProps") is not false into pSkipHkeyProps
   
   switch
      case hName = "_"
         return false
      case hName is among the items of "menu_Target,menu_CheckTarget,menu_Version" and hType = "g"
         return false
      case hName is "menu_Init" and hType = "c"
         return false
      case char 1 of hName = "u" and hType is among the items of "g,s"
         return false
      case "_" is not in hName and hType is among the items of "g,s"
         return false
      case char 1 to 3 of hName = "rev" and char 4 of hName is not "_"
         return false
      case handler_IsComponent (someHandler) and pSkipHkeyComponents is true
         return false
      default
         return true
   end switch
end hkey_TestShortDeps


--> Deps | MainstackArray
-
/*
These handers create and work with exported arrays.
*/

function deps_HarrayFetch hKey
   -- was "hArray_FetchHkeyDeps"
   put item 3 of hKey into hObject
   if exists (hObject) is false then return false -- maybe it is a shortheky in a library?
   put the mainstack_WalkArray of hObject into mainstackHkeyWalkArray
   if mainstackHkeyWalkArray is not an array then return false
   put mainstackHkeyWalkArray ["hkeyArray"] into hkeyArray
   if mainstackHkeyWalkArray is not an array then return false
   put hkeyArray_ExtractSubArray (hKey, hkeyArray) into hkeySubArray
   
   put array_List (hkeySubArray) into hKeyDeps
   line_Delete hKey, hKeyDeps
   sort hKeyDeps by item 1 of each
   return hKeyDeps
end deps_HarrayFetch

command deps_ConstructDependencyArray scriptObject, pForceCreate, pSetName
   put the mainStack_Hash of scriptObject into stackHash
   put the mainstack_Harray of scriptObject into hArray
   
   put the stack_BehaviorButton of scriptObject into pDepObject
   put empty into pDepObject
   put project_ConstructWalkArray (hArray, pDepObject, pSetName) into walkArray
   set the mainstack_WalkArray of scriptObject to walkArray
   return walkArray
end deps_ConstructDependencyArray

command deps_CreateMainStackOverlay scriptObject, graphStyle, pImageView, pDotCluster, pForceCreate
   set the cursor to watch
   put the mainStack_Hash of scriptObject into mainStackHash
   put the mainStack_ManifestArray of scriptObject into manifestArray
   put manifestArray ["sha1"] into storedHash
   if mainStackHash is not storedHash or pForceCreate is true then 
      deps_SaveMainstackAndExportArrays scriptObject, true
      put the result into mainStackMetaArray
      
      deps_ConstructDependencyArray scriptObject, true
      put the result into walkArray
      put walkArray ["hKeyArray"] into hKeyArray
   else
      put the mainstack_WalkArray of scriptObject into walkArray
      put walkArray ["hkeyArray"] into hkeyArray
   end if
   
   if hkeyArray is not an array then
      breakpoint
   end if
   
   put "Mainstack Structure" into overlayName
   put the project_OverlayFolder [false] of scriptObject into overlayFolder
   
   overlay_CreateGraph overlayFolder, hKeyArray, overlayName, scriptObject, graphStyle, pDotCluster
   put the result into overlayArrayOrError
   
   if overlayArrayOrError is not an array then  
      lcw_Notify "Problem creating overlay!", true
      put overlayArrayOrError
      return empty
   else
      put overlayArrayOrError into overlayArray
   end if
   
   if pImageView is empty then return overlayArray
   
   if exists (pImageView) is false then put empty into pImageView
   put the main_Stack of scriptObject into stackLabel
   display_Overlay overlayFolder, overlayName, pImageView, stackLabel
   put the result into displayView
   return displayView
end deps_CreateMainStackOverlay

command deps_SaveMainstackAndExportArrays scriptObject, pForceCreate
   put the main_Stack of scriptObject into mainStackObject
   save mainStackObject
   
   put the mainStack_Hash of mainStackObject into stackHash
   put the mainStack_ManifestArray of mainStackObject into manifestArray
   put manifestArray ["sha1"] into storedHash
   if stackHash = storedHash and pForceCreate is not true then
      put the mainstack_WalkArray of mainStackObject into mainStackHkeyWalkArray
      return mainStackHkeyWalkArray
   end if
   
   put true into pHashArrayBoolean
   put true into pUseCustomFolders
   put true into pExportHandlers
   
   mainStack_ExportAsFiles mainStackObject, pHashArrayBoolean, pExportHandlers, pUseCustomFolders, pForceCreate
   put the result into mainStackMetaArray
   return mainStackMetaArray
end deps_SaveMainstackAndExportArrays

command hArray_CreateDependencyGraph hKey, pGraphStyle, pOverlayName
   if pGraphStyle is empty then put "hierarchical" into pGraphStyle  
   
   put item 3 of hKey into hObject
   put the textStack_Folder of hObject into mainStackFolder
   put mainstack_FetchHarray (mainStackFolder) into hArray
   if hArray is an array then put hArray into hKeyWalkArray ["hArray"]
   
   put hkey_ConstructHarrayWalkArray (hKey, hArray, pDepObject) into hKeyWalkArray
   
   put hKeyWalkArray ["hKeyArray"] into hKeyArray
   library_CreateHkeyGraph hKey, hKeyArray, pGraphStyle, pOverlayName
   
   put the result into overlayArray
   return overlayArray
end hArray_CreateDependencyGraph

function stackArray_ConstructObjectFolder textStackFolder, objectBit, pSubStackName
   -- should update and rename to new folder conventions
   put "data" into dataOrMetadata
   set the itemdelimiter to "/"
   put item -1 of textStackFolder into mainstackName
   if pSubStackName is empty then
      put textStackFolder & dataOrMetadata & "/objects/" into stackFolder
   else
      put textStackFolder & dataOrMetadata & "/objects/substacks/" & pSubStackName & "/" into stackFolder
      -- put dataOrMetadata & "/objects/"  after stackFolder
   end if 
   put stackFolder & objectBit into objectFolder
   return objectFolder
end stackArray_ConstructObjectFolder


--> Deps | Props
-
/*
The main code has been moved to the script only library "lib_Deps.

Here we list all custom property definitions, so we can organise and rationalise them before moving them to a more appropriate place.
These custom properties are important as dependencies refer to an objects script.
This means that it is useful to standardise on calling custom properties, rather than directly functions and commands.

This will provide and interface to a new "model library" for LiveCode dependencies.
All handlers should interface with these custom properties and perhaps the commands and functions should be private.
The issue with that is that at the moment there are propblems with custom properties and the Livecode / revIgniter server I beleive.
*/

getprop mainStack_MetaArray [pHashArrayBoolean]
   local pLinkToViews, pExportHandlers, pDontDiff
   
   put the main_Stack of the target into mainStackObject
   
   if pHashArrayBoolean is empty then
      put pref_GetValue ("add object to hArray on export") is not false into createHarray
      put pref_GetValue ("Construct hashArray on stack export") is true into pHashArrayBoolean
   else
      put pHashArrayBoolean is true into pHashArrayBoolean
      pref_SetValue "Construct hashArray on stack export", pHashArrayBoolean
      if pHashArrayBoolean is true then
         pref_SetValue "Add object to hArray on stack export", true
         put true into createHarray
      else
         put pref_GetValue ("Add object to hArray on export") is not false into createHarray
      end if
   end if
   
   if createHarray and pHashArrayBoolean then
      -- only give option of constructing hkeyCalls handlerHashArray if we are also indexing a basic hArray
      put the textStack_Folder of the target into mainStackFolder
      put mainstack_FetchHandlerHashArray (mainStackFolder) into handlerHashArray
      if handlerHashArray is not an array then
         -- in cases where there is no previous index
         -- forces indexing of all hKeys in a new script
         put empty into hArray ["handlerHashArray"]["new"]
      else
         delete variable handlerHashArray ["actual"]
         delete variable handlerHashArray ["new"]
         put handlerHashArray into hArray ["handlerHashArray"]
      end if
   else
      put empty into hArray -- no "handlerHashArray" indexing of hKey calls, let's recreate the rest of hArray
   end if
   
   put true into pDontExport
   put false into pForceIndexHandlerCalls
   put mainstack_ConstructMetaArray (mainStackObject, hArray, pLinkToViews, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls) into metaArray
   return metaArray
end mainStack_MetaArray

getprop mainStack_Hash
   put the main_Stack of the target into mainStackObject
   put the filename of mainStackObject into someFile
   return file_Hash (someFile)
end mainStack_Hash

getprop object_HandlerHashArray
   put the rugged_ID of the target into rObject
   put the mainstack_HandlerHashArray of the target into mainStackHandlerHashArray
   
   put mainStackHandlerHashArray ["cached"] into cachedHashArray
   repeat for each key handlerHash in cachedHashArray
      put cachedHashArray [handlerHash]["hkey"] into emptyHkeyArray
      put keys(emptyHkeyArray) into hkey
      if item 3 of hkey = rObject then
         put cachedHashArray [handlerHash] into objectHandlerHashArray [handlerHash]
      end if
   end repeat
   return objectHandlerHashArray
end object_HandlerHashArray


--> Deps | Objects
-
getprop stack_BehaviorButton [bName]
   if bName is empty then put "Stack Handler Deps" into bName
   put the menu_SubStack of the target into menuSubStack
   if exists (btn bName of cd "Behaviors" of menuSubStack) is false then return empty
   return the long id of btn bName of cd "Behaviors" of menuSubStack
end stack_BehaviorButton

getprop stack_BehaviorButtonNames
   put the stack_BehaviorCard of the target into stackBehaviorCard
   if exists (stackBehaviorCard) is false then return empty
   repeat with btNum = 1 to the number of buttons of stackBehaviorCard
      put the short name of btn btNum of stackBehaviorCard & CR after stackBehaviorButtonNames
   end repeat
   delete char -1 of stackBehaviorButtonNames
   return stackBehaviorButtonNames
end stack_BehaviorButtonNames

getprop stack_BehaviorCard
   -- a default (overrride with a getprop handler in the stack script)
   put the menu_SubStack of the target into menuSubStack
   if exists (cd "Behaviors" of menuSubStack) is false then return empty
   return the long id of cd "Behaviors" of menuSubStack
end stack_BehaviorCard

getprop main_Stack
   put the defaultstack into stackObject
   put the mainstack of stackObject into mainStackName
   put the name of stack mainStackName into mainStackObject
   return mainStackObject
end main_Stack


--> Hkey | Deps | From Library
-
function library_HkeyDeps hKey, pAllcalls
   put library_HkeyCallArray (hKey, pAllcalls) into hKeyLinkArray
   put array_List (hKeyLinkArray) into hkeyDeps
   put item 1 to 2 of hKey into shortHkey
   line_Delete shortHkey, hkeyDeps
   sort hkeyDeps by item 1 of each
   return hkeyDeps
end library_HkeyDeps

function library_HkeyCallArray hKey, pAllcalls
   local hKeyLinkArray
   library_HandlerWalk hKey, empty, hKeyLinkArray, pAllcalls
   array_StripDeeperLevels hKeyLinkArray
   return hKeyLinkArray
end library_HkeyCallArray

function hArray_FindHkeyInHierarchy shortHkey, hObject, pHarray, pProjectName
   -- see also "hkey_Find"
   if exists (hObject) is false then return empty
   -- if pHarray is an array and pProjectName is empty then put "none" into pProjectName -- assume we only want to look in a mainstack
   
   put the script_Hierarchy [pProjectName] of hObject into pSearchHierarchy
   put hArray_GetFoundHkeyArray (shortHkey, pHarray) into hkeyArray
   
   -- also look for private handlers in the first object
   if hkeyArray is not an array and char 1 of item 2 of shortHkey is not "p" then
      put "p" before char 1 of item 2 of shortHkey
      put hArray_GetFoundHkeyArray (shortHkey, pHarray) into hkeyArray
   end if
   
   -- lets get the nearest hKey in the hierarchy
   -- ususally faster to get an indexed shortHkey and do this, than crawl a long hierarchy
   set the wholematches to true
   repeat for each key foundHkey in hkeyArray
      put item 3 of foundHkey into foundObject
      if item 4 of foundHkey > 1 then next repeat -- hack for now (should not be adding repeat hKeys to hKeyArray but using first / revAvailablehandler approach
      put lineOffset (foundObject, pSearchHierarchy) into lineNum
      put foundHkey into foundArray [lineNum]
   end repeat
   put item 2 of the extents of foundArray into maxLineNum
   return foundArray [maxLineNum]
end hArray_FindHkeyInHierarchy

function file_Hash someFile, pUseBinary
   if there is not a file someFile then return empty
   if pUseBinary is false then
      put url ("file:" & someFile) into someData
   else
      put url ("binfile:" & someFile) into someData
   end if
   return sha1_Hash (someData)
end file_Hash


--> Mainstack | Deps | Construct
-
command mainstack_ConstructHandlerHashArray hArray, mainStackFolder
   put hArray ["scriptArray"] into objectArray
   repeat for each key rObject in objectArray
      put objectArray [rObject] into scriptObjectArray
      put scriptObjectArray ["data"]["firstHkeyArray"] into firstHkeyArray
      repeat for each key firstShortHkey in firstHkeyArray
         put firstShortHkey,rObject,1 into hKey
         
         put hArray_GetHandler (hKey, hArray) into callHandler
         put sha1_Hash (callHandler) into handlerHash
         put hArray_GetShortCalls (handlerHash, hArray) into shortCalls
         
         -- it has not been indexed lets get the handler from the global index
         -- and extract the calls from the handler
         put hArray_GetHandler (hKey) into callHandler
         put handler_ExtractCalls (callHandler) into shortCalls
         
         put hArray_GetHandler (hKey, hArray) into callHandler
         put handler_ExtractCalls (callHandler) into shortCalls
         
      end repeat
   end repeat
end mainstack_ConstructHandlerHashArray


--> Main Stack | Export | Deps
-
command object_ExportAsFiles scriptObject, pUseCustomFolders, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   local objectPropArray, hArray
   object_GetPropertyArrays scriptObject, objectPropArray, hArray, pExportHandlers, pDontDiff, pDontExport, pForceIndexHandlerCalls
   
   put the checkout_Folder of scriptObject into objectFolder
   objectArray_ExportAsFiles objectPropArray, objectFolder, pUseCustomFolders, pExportHandlers, pDontExport
   return objectFolder
end object_ExportAsFiles


--> Deps | Create
-
command library_CreateStackDependencyButton pObject
   if pObject is empty then put the long id of the target into pObject
   put the stack_BehaviorButton ["Stack Handler Deps"] of pObject into libraryDepButton
   if exists (libraryDepButton) then return libraryDepButton
   
   put the main_Stack of pObject into mainStackObject
   put the uRIP ["name"] of mainStackObject into libraryName
   put libraryName && "Deps" into uripName
   behavior_CreateStackButton mainStackObject, "Stack Handler Deps", uripName, "deps"
   put the result into libraryDepButton
   return libraryDepButton
end library_CreateStackDependencyButton

command behavior_CreateStackButton someObject, bName, pUripName, pBehaviorType
   if pUripName is empty then put bName into pUripName
   if pBehaviorType is empty then put "behavior" into pBehaviorType
   
   put the stack_BehaviorButton [bName] of someObject into depBehaviorButton
   if exists (depBehaviorButton) is true then return depBehaviorButton
   
   put the defaultstack into oDefault
   --
   behavior_CreateSubStackCard someObject
   put the result into behaviorCard
   
   -- behaviorCard exists or has been created
   -- set the defaultstack to menuSubStack
   go invisible behaviorCard -- would be good to be able to create it on / in a card and not have to go???
   create button bName
   put it into createdButton
   
   put metadata_ConstructArray (pUripName, pBehaviorType) into uRipArray
   set the object_Metadata of createdButton to uRipArray
   return createdButton
end behavior_CreateStackButton

command behavior_CreateSubStackCard someObject
   put the menu_SubStack of someObject into menuSubStack
   switch
      case exists (menuSubStack) is false
         stack_CreateSubStack someObject, "OPN Stack Menus"
         put the result into menuSubStack
         set the name of cd 1 of menuSubStack to "Behaviors"
         return the long id of cd 1 of menuSubStack
      case there is a card "Behaviors" of menuSubStack
         return the long id of cd "Behaviors" of menuSubStack
      default
         -- stack exists but there is no named behavior card
         if word 1 to 2 of the short name of cd 1 of menuSubStack = "card id" then
            set the name of cd 1 of menuSubStack to "Behaviors"
            return the long id of cd 1 of menuSubStack
         else
            put the defaultstack into oDefault
            set the defaultstack to menuSubStack
            create card "Behaviors"
            set the defaultstack to oDefault
            return the long id of cd "Behaviors" of menuSubStack
         end if
   end switch
end behavior_CreateSubStackCard


--> Private
-
command hArray_FilterHkeyArray @hKeyArray, pHarray
   local alreadyDeleted
   repeat for each key hKey in hKeyArray
      if hkey_IsAuthored (hKey, pHarray) is false then
         linkArray_DeleteBranch hKeyArray, hKey, alreadyDeleted
         next repeat
      end if
      put hKeyArray [hKey] into hkeyLinks
      if hkeyLinks is an array then put keys (hkeyLinks) into hkeyLinks
      
      repeat for each line hkeyLink in hkeyLinks
         if hkey_IsAuthored (hkeyLink, pHarray) is false then
            linkArray_DeleteBranch hKeyArray, hkeyLink, alreadyDeleted
         end if
      end repeat
   end repeat
end hArray_FilterHkeyArray

-- command hArray_FilterHkeyArray @hKeyArray, pHarray
put keys (hKeyArray) into filteredKeys
hArray_FilterHkeys filteredKeys, pHarray
repeat for each line hKey in filteredKeys
   put hKeyArray [hKey] into hkeyLinks
   if hkeyLinks is an array then put keys (hkeyLinks) into hkeyLinks
   hArray_FilterHkeys hkeyLinks, pHarray
   put hkeyLinks into filteredHkeyArray [hKey]
end repeat
put filteredHkeyArray into hKeyArray
end hArray_FilterHkeyArray

command hArray_FilterHkeys @hKeys, pHarray
   repeat for each line hKey in hKeys
      if hkey_IsAuthored (hKey, pHarray) is true then
         put hKey & CR after goodHkeys
      end if
   end repeat
   delete char -1 of goodHkeys
   put goodHkeys into hKeys
end hArray_FilterHkeys

command stackArray_DeleteObjectFolder textStackFolder
   folder_Format textStackFolder
   
   -- hack
   set the itemdelimiter to "/"
   put textStackFolder & "objects/" into oldObjectsFolder
   revDeleteFolder oldObjectsFolder -- lets start again, but keep metadata and other folders
   -- end hack
   
   put textStackFolder & "data/" into dataFolder
   put dataFolder & "objects/" into objectsFolder
   
   revDeleteFolder dataFolder -- lets start again, but keep metadata and other folders
end stackArray_DeleteObjectFolder

-- private command stackArray_ExportAsFiles stackArray, textStackFolder, pUseCustomFolders, pExportHandlers, pDontExport
   /*
   This deletes the objects folder, but leaves the metadata folder untouched.
   It would be good to tidy the metadata folder so that any deleted objects also had their metadata folders removed?
   */
   
   stackArray_DeleteObjectFolder textStackFolder
   put the result into objectsFolder
   
   put stackArray ["objects"] into objectArray
   put stackArray ["manifest"] into manifestArray
   put manifestArray ["name"] into stackName
   put manifestArray ["object"] into stackObject
   
   mainStack_StoreManifestArray textStackFolder, manifestArray
   
   repeat for each key objectBit in objectArray
      if objectBit = "substacks" then next repeat
      
      put stackArray_ConstructObjectFolder (textStackFolder, objectBit, subStackName) into objectFolder
      
      if objectBit = "stack" then
         stackArray_ExportStackFiles objectFolder, stackArray
         stackArray_ExportVideoClips objectFolder, stackArray
         stackArray_ExportAudioClips objectFolder, stackArray
      end if
      
      folder_CreateNested objectFolder
      put objectArray [objectBit] into objectPropArray
      
      objectArray_ExportAsFiles objectPropArray, objectFolder, pUseCustomFolders, pExportHandlers, pDontExport
   end repeat
end stackArray_ExportAsFiles

command stackArray_ExportStackFiles objectFolder, objectPropArray
   put objectPropArray ["stackfiles"] into stackFileTable
   if stackFileTable is empty then return empty
   
   put meta_StackArrayFile (objectFolder, false) into someFile
   put stackFileTable into url ("binfile:" & someFile)
end stackArray_ExportStackFiles

command stackArray_ExportVideoClips objectFolder, objectPropArray

end stackArray_ExportVideoClips

command stackArray_ExportAudioClips objectFolder, objectPropArray
   
end stackArray_ExportAudioClips


--> Deps | Private
-
private command _AddVideoClips subStackName, mainStackName, @stackArray
   put the number of videoClips of stack subStackName of stack mainStackName into maxVclipNum
   repeat with clipNum = 1 to maxVclipNum
      put the object_PropertyArray of videoClip clipNum of stack subStackName of stack mainStackName into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of videoClip clipNum of stack subStackName of stack mainStackName into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxVclipNum = 1 then
         put "videoclip" into clipArrayKey
      else
         put "videoclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["videoclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["videoclips"][clipArrayKey]["name"]
   end repeat
end _AddVideoClips

private command _AddAudioClips subStackName, mainStackName, @stackArray
   put the number of audioClips of stack subStackName of stack mainStackName into maxAclipNum
   repeat with clipNum = 1 to maxAclipNum
      put the object_PropertyArray of audioClip clipNum of stack subStackName of stack mainStackName into objectPropertyArray
      put clipNum into objectPropertyArray ["rev"]["layer"]
      put the abbreviated id of audioClip clipNum of stack subStackName of stack mainStackName into aObject
      put object_ConvertAbbreviated (aObject) into aFolderName
      put objectPropertyArray into stackArray ["objects"][aFolderName]
      
      if maxAclipNum = 1 then
         put "audioclip" into clipArrayKey
      else
         put "audioclip[" & clipNum & "]" into clipArrayKey
      end if
      put aObject into stackArray ["manifest"]["audioclips"][clipArrayKey]["object"]
      put objectPropertyArray ["rev"]["name"] into stackArray ["manifest"]["audioclips"][clipArrayKey]["name"]
   end repeat
end _AddAudioClips
