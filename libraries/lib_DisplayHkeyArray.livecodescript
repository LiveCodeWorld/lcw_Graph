script "lib_DisplayHkeyArray"
--> MetaData
-
license: GPLv3
name: lib_DisplayHkeyArray
type: library
version: 0.3

--> Working on
-


--> Display | HkeyArray | Script
-
command display_HkeyDepScript hKey
   put walk_GetHkeyArray (hKey) into hkeyArray
   put "Deps for" && hKey into pTitle
   display_ScriptFromHkeyArray hkeyArray, pTitle, hKey
   return the result
end display_HkeyDepScript

command display_ScriptFromHkeyArray hkeyArray, pTitle, pFirstKey
   put hkeyArray_ListHkeys (hkeyArray, pFirstKey) into hKeys
   display_ScriptFromHkeys hKeys, pTitle
   return the result
end display_ScriptFromHkeyArray

command display_ScriptFromHkeys hKeys, pTitle
   put hkey_CollectFromObjects (hKeys, false) into newScript
   --
   display_Text newScript, pTitle
   put the result into displayView
   return displayView
end display_ScriptFromHkeys


--> Display | HkeyArray
-
command display_HKeyArray hKey, pHkeyArray, pLabel, pShowHow, pStripMissing
   if pHkeyArray is not an array then
      put walk_GetHkeyArray (hKey) into pHkeyArray
   end if
   if pShowHow is empty then
      put "hkeyArray" into pShowHow
   end if
   --
   put hkeyArray_DisplayData (pHkeyArray, pShowHow, pStripMissing, hKey) into dData
   --
   display_Data dData, hKey, "HkeyArray"
   put the result into displayView
   set the data_MenuBit of displayView to "HkeyArray"
   --
   set the show_How of displayView to pShowHow
   set the displayed_Hkey of displayView to hKey
   set the displayed_HkeyArray of displayView to pHkeyArray
   --
   return displayView
end display_HKeyArray

function hkeyArray_DisplayData hkeyArray, pShowHow, pStripMissing, pFirstHkey
   switch pShowHow
      case "hKeys"
         return hkeyArray_ListHkeys (hkeyArray, pFirstHkey)
      case "stacks"
         return hkeyArray_GetStackDepArray (hkeyArray)
      case "projects"
         return hkeyArray_GetProjectDepArray (hkeyArray, pStripMissing)
      default 
         return hkeyArray
   end switch
end hkeyArray_DisplayData


--> Display | Events
-
command mDoubleUp_HkeyArray displayView, someValue, sPath
   if the optionKey is "Down" then breakpoint
   --
   switch 
      case line 1 of sPath = "Missing"
         --  put line 4 of sPath into hKey
         put someValue into hKey
         break
      default
         put line 3 of sPath into hKey
   end switch
   --
   hkey_Edit hKey
end mDoubleUp_HkeyArray

command mDouble_DisplayHkeyTreeArray displayView, someValue, hKey
   hkey_Edit hKey
end mDouble_DisplayHkeyTreeArray

on mDouble_DisplayObjectHkeyArray displayView, someValue, pathItems
   put 1 into hNum
   set the itemdelimiter to slash
   put item 1 of pathItems into hObject
   put item 2 of pathItems into shortHkey
   put hKeyLine_AddObject (shortHkey, hObject) into hKey
   
   hkey_Edit hKey
end mDouble_DisplayObjectHkeyArray


--> Display | HkeyArray
-
command display_ScriptHkeyArray hKeyArray, sObject
   display_Data hKeyArray, hKey, "hKeyArray"
   put the result into displayView
   --
   display_SetInteractions displayView, "HkeyArray | Script | Tree", "mDouble_DisplayHkeyTreeArray"
   --
   set the displayed_Object of displayView to hObject
   return displayView
end display_ScriptHkeyArray


--> Display | Deps
-
command display_HkeyDepArray hKey
   -- Fetch stored hKeyArray for hkey
   -- Turn it into a depObjectArray
   
   put hkey_FetchOverlayData (hKey) into overlayData
   put keys (overlayData) into projectName
   put overlayData [projectName] into hArray
   put hArray ["data"]["linkArray"] into hKeyArray
   --
   display_ObjectDepArray hkey, hkeyArray
   --
   put the result into displayView
   set the hkey_Array of displayView to hkeyArray
   return displayView
end display_HkeyDepArray

command display_HkeyArrayDependencyScript hkeyArray, pScriptObject, pStripObjects, pStripProps, pMakePrivate
   local depSuite, missingHkeys
   hkeyArray_ConstructDependencySuite hkeyArray, pScriptObject, depSuite, pStripObjects, pStripProps, pMakePrivate
   put the result into someArray
   put someArray ["missingHkeys"] into missingHkeys
   
   if exists (pScriptObject) then
      put the name of pScriptObject into prettyObject
      put merge ("Deps for [[prettyObject]]") into someTitle
   else
      put "Dependency Suite" into someTitle
   end if
   
   -- put depSuite
   display_Lines depSuite, someTitle
   
   return someArray
end display_HkeyArrayDependencyScript


--> Display | Graph | Array
-
command display_OverlayData overlayFolder, pTitle
   put overlay_GetData (overlayFolder) into overlayData 
   
   display_Array overlayData, pTitle
   put the result into displayView
   display_SetInteractions displayView, "Script | Graph", ""
   --
   set the displayed_OverlayFolder of displayView to overlayFolder
   set the displayed_OverlayName of displayView to pOverlayName
   return displayView
end display_OverlayData


--> Display | Script
-
command display_Script sObject
   put the script_SuiteArray of sObject into scriptArray
   --
   put the name of sObject into someTitle
   display_Data scriptArray, someTitle, "Script"
   put the result into displayView
   --
   set the displayed_Object of displayView to sObject
   display_SetInteractions displayView, "Script | Tree", "mDoubleUp_DisplayShortHkey"
   --   
   return displayView
end display_Script

command display_ScriptArray scriptObject
   put the walk_HkeyArray of scriptObject into hKeyArray
   --
   graph_CreateScriptObjectHkeyArray hkeyArray, scriptObject
   put the result into imageFile
   display_HandlerSVG imageFile
   --
   put the name of scriptObject into objectName
   --
   _DisplayHkeyArray hKeyArray, objectName, display_ScriptArray, stackObject
   return the result
end display_ScriptArray

command display_StackDeps stackObject
   -- Not fully working
   put the project_Name of stackObject into projectName   
   put the walk_HkeyArray of stackObject into depArray
   --
   _DisplayHkeyArray depArray, stackObject, projectName, stackObject
   return indexView
end display_StackDeps


--> Deps
-
command hkeyArray_Graph hkeyArray, graphStyle, graphSize
   -- simple graphing of any hkeyArray
   
   put hkeyArray_ConstructDot (hkeyArray, empty, graphStyle, graphSize) into dotText
   
   if the optionkey is "Down" then
      put dotText
   else
      if graphStyle is empty then put the overlay_Style of me into graphStyle
      if the flatten_Hierarchy of me is true then
         display_Dot dotText, graphStyle
      else
         display_Dot dotText, graphStyle
      end if
      object_GoTo treeView
   end if
end hkeyArray_Graph


--> hkeyTreeArray
-
command display_ObjectDepArray hObject, hkeyArray
   -- think hObject can be hkey or Object
   if hkeyArray is empty then
      put the projectOverlay_Array ["processedHkey.array"] of hObject into hkeyArray
   end if
   
   put hkeyArray_GetStackDepArray (hkeyArray) into objectHKeyArray
   put hkeyArray_TidyObjectArray (objectHKeyArray) into objectTreeArray
   --
   display_HkeyTreeArray objectTreeArray, hObject, "mDouble_DisplayObjectHkeyArray"
   --
   put the result into treeView
   set the view_Data of treeView to hKeyArray
   return treeview
end display_ObjectDepArray

command display_HkeyTreeArray hKeyArray, hKey
   put hkeyArray_ConstructTreeArray (hkeyArray) into hkeyTreeArray
   --
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   --
   display_Data hkeyTreeArray, hKey, "hkeyTreeArray"
   put the result into displayView
   --
   -- may want to use "Global | HkeyArray | Tree | Filter | Menu"
   display_SetInteractions displayView, "HkeyArray", "mDouble_DisplayHkeyTreeArray"
   set the displayed_Object of displayView to hObject
   set the displayed_Hkey of displayView to hKey
   return displayView
end display_HkeyTreeArray

function hkeyArray_ConstructTreeArray hKeyArray
   local treeArray
   
   put keys (hKeyArray) into sortedHkeys
   sort sortedHkeys by item 1 of each
   repeat for each line sortedHkey in sortedHkeys
      _addToDepKeyArray treeArray, sortedHkey, hKeyArray
   end repeat
   return treeArray
end hkeyArray_ConstructTreeArray


--> Private
-
private command _addToDepKeyArray @treeArray, hKey, hKeyArray
   put the keys of hKeyArray [hKey] into depHkeys
   sort depHkeys by word 2 of each
   repeat for each line depHkey in depHkeys
      hkey_Deconstruct depHkey, hName, hType, hObject, hNum
      put the result into shortHkey
      
      put hName into treeArray [hKey][shortHkey]["hName"]
      put hType into treeArray [hKey][shortHkey]["hType"]
      put hObject into treeArray [hKey][shortHkey]["hObject"]
   end repeat
end _addToDepKeyArray

private command _DisplayHkeyArray depArray, someTitle, stackLabel, displayedObject
   -- put "Global | HkeyArray | Menu" into mLineTitle
   display_Array depArray, someTitle, stackLabel
   put the result into displayView
   display_SetInteractions displayView, "HkeyArray | Tree | Deps", "mouse_EditHkey"
   set the displayed_Object of displayView to displayedObject
   return displayView
end _DisplayHkeyArray
