script "lib_HkeyStackArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_HkeyStackArray
type: library
version: 0.3


--> Props
-
setprop hkeyStackArray_ShowHow showHow
   put the data_View of the target into dView
   if exists (dView) is false then return false
   --
   put the uOPN ["hkey_Array"] of dView into hkeyArray
   put the uOPN ["displayed_Object"] of dView into sObject
   put the uOPN ["strip_MissingProps"] of dView into stripMissing
   --
   put hkeyArray_DisplayData (hkeyArray, showHow, stripMissing) into dData
   set the displayed_Data of dView to dData
   set the show_How of dView to showHow
   --
   set the hkeyStackArray_Menus of dView to showHow
end hkeyStackArray_ShowHow

setprop hkeyStackArray_Menus showHow
   put the data_View of the target into dView
   if exists (dView) is false then return false
   --
   put "Global | Script | Dep | Line | Menu" into mTitle
   if showHow = "hkeys" then
      put the index_Field of dView into indexField
      set the line_Menu of indexField to "Global | Script | Hkey | Line | Menu"
   else
      set the itemdelimiter to " | "
      put text_InitialCaps (showHow) into item 3 of mTitle
      put the tree_View of dView into arrayView
      set the line_Menu of arrayView to mTitle
   end if
   return true
end hkeyStackArray_Menus


--> Working on
-
function hkeyArray_CompactMissing hkeyArray, pSkipProps
   put "G missing_Hkeys of Missing" into fakeKey
   put hkeyArray_GetMissingKeys (hkeyArray) into missingHkeys
   --
   repeat for each line mKey in missingHkeys
      if pSkipProps is not false then
         if word 1 of mKey is not among the items of "G,S" then
            next repeat -- skip as it is not a prop
         end if
      end if
      
      hkeyArray_Replace hkeyArray, mKey, fakeKey
   end repeat
   return hkeyArray
end hkeyArray_CompactMissing

function hkeyArray_GetMissingKeys hkeyArray
   put hkeyStackArray_From (hkeyArray) into hkeyStackArray
   get hkeyStackArray ["Missing"]
   put keys (it) into missinHkeys
   hkeyIndex_Sort missinHkeys
   return missinHkeys
end hkeyArray_GetMissingKeys

command hkeyArray_Replace @hkeyArray, oldKey, newKey
   repeat for each key hKey in hkeyArray
      get hkeyArray [hKey]
      --
      if hKey = oldKey then
         delete variable hkeyArray [oldKey]
         put it into hkeyArray [newKey]
      end if
      
      repeat for each key childKey in it
         if childKey = oldKey then
            delete variable hkeyArray [hKey][oldKey]
            put "changed" into hkeyArray [hKey][newKey]
         end if
      end repeat 
   end repeat
end hkeyArray_Replace


--> Display
-
command display_HkeyStackArrayNode hkeyArray, stackObject
   local familyArray
   
   put hkeyArray_DisplayData (hkeyArray, "stacks") into stackDepArray
   put stackDepArray [stackObject] into subHkeyArray
   --
   repeat for each key toHkey in subHkeyArray
      put hkeyArray [toHkey] into fromKeyArray
      union familyArray with fromKeyArray
      
      get subHkeyArray [toHkey]
      repeat for each key fromKey in it
         put toHkey into familyArray [fromKey]
      end repeat
   end repeat
   -- put hkeyStackArray_To (familyArray) into fHkeyArray
   --
   display_Data familyArray, stackObject
   reDisplayGraph_HkeyArray familyArray, stackObject
end display_HkeyStackArrayNode


--> Display
-
command display_HkeyDepTable hkeyArray, hKey, pDisplayView
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   if exists (hObject) is false then
      breakpoint
      return empty
   end if
   
   # Strip sObject + missing and Construct Table 
   put hKeyStackTable_Construct (hkeyArray, hObject) into hkeyTable
   
   # Sort
   set the itemdelimiter to tab
   sort numeric lines of hkeyTable by item 2 of each
   
   # Display
   lock screen
   if exists (pDisplayView) then
      set the displayed_Data [hObject] of pDisplayView to hkeyTable
   else
      # Display Table
      put shortHkey && "Table" into sTitle
      display_InvisibleTool hkeyTable, sTitle, "Hkey Dep Table"
      put the result into pDisplayView
   end if
   
   # Set menus and doubleClick_Message
   set the uOPN ["displayed_Hkey"] of pDisplayView to hKey
   set the uOPN ["hkey_Array"] of pDisplayView to hkeyArray
   
   # Set Menu
   set the menu_TitleBit ["lcw_Graph"] of pDisplayView to "HkeyArray | Table" -- "Hkey | Dep | Table"
   
   # Set Table Style
   put the index_View of pDisplayView into indexView
   set the tab_Stops  of indexView to 200
   set the field_Style of indexView to "multiselect"
   
   # Set Width and height
   put the formatted_Width of indexView into fWidth
   set the stack_Width of indexView to fWidth
   put the formatted_Height of indexView into fHeight
   set the stack_Height of indexView to fHeight
   --
   unlock screen
   put the stack_Name of pDisplayView into cStackName
   show stack cStackName
   
   return indexView
end display_HkeyDepTable

command display_ScriptDepTable hkeyArray, sObject, pDisplayView, pRectHow
   local toolContent
   if pRectHow is empty then put 40,100 into pRectHow
   
   -- put the dep_StackTable of sObject into hkeyTable
   # Strip sObject + missing and Construct Table 
   put hKeyStackTable_Construct (hkeyArray, sObject) into hkeyTable
   
   # Sort
   set the itemdelimiter to tab
   sort numeric lines of hkeyTable by item 2 of each
   
   if exists (pDisplayView) then
      set the displayed_Data of pDisplayView to hkeyTable
   else
      # Display Table
      display_StandardTool hkeyTable, sObject, "Script Dep Table", "simple", pRectHow
      put the result into pDisplayView  
   end if
   
   # Set menus and doubleClick_Message
   set the uOPN ["displayed_Object"] of pDisplayView to sObject
   set the uOPN ["hkey_Array"] of pDisplayView to hkeyArray
   set the uOPN ["stack_DepArray"] of pDisplayView to stackDepArray
   
   # Set Menu
   set the menu_TitleBit ["lcw_Graph"] of pDisplayView to "HkeyArray | Table"
   
   # Set Table Style
   put the index_View of pDisplayView into indexView
   set the tab_Stops  of indexView to 240
   set the field_Style of indexView to "multiselect"
   
   return indexView
end display_ScriptDepTable


--> HKeyStackTable
-
function hKeyStackTable_From hkeyArray
   repeat for each key parentKey in hkeyArray
      put hkeyArray [parentKey] into parentArray
      get the keys of parentArray
      put the number of lines of it into childKeyNum
      put parentKey & tab & childKeyNum & CR after hkeyTable
   end repeat
   delete char -1 of hkeyTable
   return hkeyTable
end hKeyStackTable_From

function hKeyStackTable_Construct hkeyArray, pStackObjects, pStripMissing
   get hKeyArray_Without (hkeyArray, pStackObjects, pStripMissing)
   put hKeyStackTable_From (it) into sHkeyTable
   return sHkeyTable
end hKeyStackTable_Construct


--> Working on
-
function hkeyStackArray_From hkeyArray
   local hkeyObjectArray
   -- hkeyArray_SetObjectArray hkeyObjectArray, hkeyArray
   
   repeat for each key hKey in hkeyArray
      set the cursor to busy
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      
      -- put revRuggedID (hObject) into hObject
      put hkeyArray [hKey] into parentArray
      put parentArray into hkeyObjectArray [hObject][hKey]
      
      repeat for each key hkeyCall in parentArray
         hkeyLine_Deconstruct hkeyCall, callName, callType, callObject
         -- put parentArray [hkeyCall] into hkeyObjectArray [callObject][hkeyCall]
         if hkeyObjectArray [callObject][hkeyCall] is empty then
            put empty into hkeyObjectArray [callObject][hkeyCall]
         else
            -- breakpoint -- could do a union?
         end if
      end repeat
      
   end repeat
   return hkeyObjectArray
end hkeyStackArray_From

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
         put revRuggedID (hObject) into hObject
         if the keys of hkeyObjectArray [hObject] is empty then
            put empty into hkeyObjectArray [hObject][hKey]
         else
            -- put empty into hkeyObjectArray [hObject][hKey]["top"]
         end if
         break
      default
         put revRuggedID (hObject) into hObject
         put empty into hkeyObjectArray [hObject][hKey][parentHkey]
   end switch
end _AddToObjectArray

function hkeyStackArray_To hkeyStackArray
local hkeyArray

repeat for each element stackHkeyArray in hkeyStackArray
   union hkeyArray with stackHkeyArray -- recursively
end repeat
return hkeyArray

/*
repeat for each key stackObject in hkeyStackArray
   put hkeyStackArray [stackObject] into subHkeyArray
   union hkeyArray with subHkeyArray
end repeat
*/
end hkeyStackArray_To

function hKeyArray_Without hkeyArray, pStackObjects, pStripMissing
   put hkeyStackArray_From (hkeyArray) into stackDepArray
   
   # Delete Missing
   if pStripMissing is not false then
      delete variable stackDepArray ["Missing"]
   end if
   
   # Delete sObject
   repeat for each line stackObject in pStackObjects
      delete variable stackDepArray [stackObject]
   end repeat
   --
   return stackDepArray
end hKeyArray_Without

function hkeyArray_ListWithout hkeyArray, sObject
   put array_ListKeys (hkeyArray) into hKeys -- includes sObject deps
   
   # Filter
   filter hKeys without ("*" && sObject)
   return hKeys
end hkeyArray_ListWithout

function hKeyStackArray_ListHkeys stackArray
   put hkeyStackArray_To (stackArray) into hkeyArray
   -- put hkeyArray_ListHkeys (hkeyArray, pFirstKey, pStripMissing)
   put array_List (hkeyArray) into hKeys
   return hKeys
end hKeyStackArray_ListHkeys

function hKeyArray_Without hkeyArray, pStackObjects, pStripMissing
   put hkeyStackArray_From (hkeyArray) into stackDepArray
   
   # Delete Missing
   if pStripMissing is not false then
      delete variable stackDepArray ["Missing"]
   end if
   
   # Delete sObject
   repeat for each line stackObject in pStackObjects
      delete variable stackDepArray [stackObject]
   end repeat
   --
   return stackDepArray
end hKeyArray_Without

function hKeyStackArray_FilterConvert stackDepArray, stackDepTable
   get hkeyStackArray_Filter (stackDepArray, stackDepTable)
   put hkeyStackArray_To (it) into hkeyArray
   return hkeyArray
end hKeyStackArray_FilterConvert

function hkeyStackArray_Filter stackDepArray, stackDepTable
   -- strips out stacks (creates new stackArray based on thos listed in stackDepTable)
   set the itemdelimiter to tab
   repeat for each line tLine in stackDepTable
      put item 1 of tLine into stackObject
      put stackDepArray [stackObject] into newStackDepArray [stackObject]
   end repeat
   return newStackDepArray
end hkeyStackArray_Filter

function hkeyStackArray_ListHkeys hkeyStackArray
   put hkeyStackArray_To (hkeyStackArray) into hkeyArray
   put array_List (hkeyArray) into hkeys
   hkeyIndex_Sort hKeys
end hkeyStackArray_ListHkeys


--> Deps
-
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

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function array_List someArray
   -- unique index of all elements and keys in an array (not for nested arrays)
   local indexArray
   repeat for each key someKey in someArray
      put empty into indexArray [someKey]
      put someArray [someKey] into keyElements
      if keyElements is an array then
         repeat for each key keyElement in keyElements
            if word 1 to -1 of keyElement is empty then next repeat
            put empty into indexArray [keyElement]
         end repeat
      else if keyElements is not empty then
         repeat for each line keyElement in keyElements
            if word 1 to -1 of keyElement is empty then next repeat
            put empty into indexArray [keyElement]
         end repeat
      end if
   end repeat
   return keys (indexArray)
end array_List

function env_FolderFromPath sPath, pRootName
   -- works for any stack within the LiveCodeWorld repo
   if pRootName is empty then put "LivecodeWorld" into pRootName
   
   set the itemdelimiter to slash
   put itemOffset (pRootName, sPath) into itemNum
   if itemNum = 0 then return empty
   put item 1 to itemNum of sPath & slash into envFolder
   return envFolder
end env_FolderFromPath

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

function env_GetRepoFolder
   put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   delete item -1 of pLcwFolder
   return pLcwFolder
end env_GetRepoFolder

function hkeyArray_DisplayData hkeyArray, pShowHow, pStripMissing, pFirstHkey
   switch pShowHow
      case "depKeys"
         put hkeyArray_ListHkeys (hkeyArray, pFirstHkey, pStripMissing) into hKeys
         filter hKeys with ("*Deps" & quote)
         return hKeys
         break
      case "hKeys"
         return hkeyArray_ListHkeys (hkeyArray, pFirstHkey, pStripMissing)
      case "stacks"
         return hkeyStackArray_From (hkeyArray)
      case "projects"
         return hkeyArray_GetProjectDepArray (hkeyArray, pStripMissing)
      default 
         return hkeyArray
   end switch
end hkeyArray_DisplayData

function hkeyArray_GetProjectDepArray hkeyArray, pStripProps
   put hkeyStackArray_From (hkeyArray) into sArray
   --
   put sArray ["Missing"] into missingArray
   delete variable sArray ["Missing"]
   --
   repeat for each key sObject in sArray
      if exists (sObject) is false then
         put sArray [sObject] into dArray ["Still Missing"][sObject]
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

function hkeyArray_ListHkeys hkeyArray, pFirstKey, pStripMissing
   local hKeys
   put array_List (hkeyArray) into hKeys
   if pFirstKey is not empty then
      set the wholematches to true
      put lineOffset (pFirstKey, hKeys) into lineNum
      delete line lineNum of hKeys
   end if
   hkeyIndex_Sort hKeys
   if pFirstKey is not empty then
      put pFirstKey & CR before hKeys
   end if
   if pStripMissing is true then
      filter hKeys without "* of Missing"
   end if
   return word 1 to -1 of hKeys
end hkeyArray_ListHkeys

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

command hkeyIndex_Sort @hKeys
   sort hKeys by word 1 of each
   sort hKeys by word -1 of each
   sort hKeys by word 2 of each
end hkeyIndex_Sort

function hKeyStackArray_ListHkeys stackArray
   put hkeyStackArray_To (stackArray) into hkeyArray
   -- put hkeyArray_ListHkeys (hkeyArray, pFirstKey, pStripMissing)
   put array_List (hkeyArray) into hKeys
   return hKeys
end hKeyStackArray_ListHkeys

setprop hkeyStackArray_ShowHow showHow
   put the data_View of the target into dView
   if exists (dView) is false then return false
   --
   put the displayed_HkeyArray of dView into hkeyArray
   put the displayed_Object of dView into sObject
   put the strip_MissingProps of dView into stripMissing
   --
   put hkeyArray_DisplayData (hkeyArray, showHow, stripMissing) into dData
   set the displayed_Data of dView to dData
   set the show_How of dView to showHow
   --
   set the hkeyStackArray_Menus of dView to showHow
end hkeyStackArray_ShowHow

getprop project_Folder
   -- latest simplest version based on naming conventions and folder structure
   -- does not allow projects outside of the LCW reop folder  
   
   put the effective filename of the defaultstack into stackPath
   if stackPath is empty then return empty
   put project_FolderFromPath (stackPath) into projectFolder
   return projectFolder
end project_Folder

function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath

getprop project_Name
   -- assume folder name = project name
   set the itemdelimiter to slash
   put the project_Folder of the target into projectFolder
   return item -1 of projectFolder
end project_Name

function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower(word wordNum of someText) into someWord
      put toupper(char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps


--> Private
-
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
         put revRuggedID (hObject) into hObject
         if the keys of hkeyObjectArray [hObject] is empty then
            put empty into hkeyObjectArray [hObject][hKey]
         else
            -- put empty into hkeyObjectArray [hObject][hKey]["top"]
         end if
         break
      default
         put revRuggedID (hObject) into hObject
         put empty into hkeyObjectArray [hObject][hKey][parentHkey]
   end switch
end _AddToObjectArray

