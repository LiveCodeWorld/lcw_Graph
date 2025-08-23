script "lib_DisplayHkeyArray"
--> MetaData
-
license: GPLv3
name: lib_DisplayHkeyArray
type: library
version: 0.3


--> Move
-
command mDouble_DisplayHkeyTreeArray dView, someValue, hKey
   hkey_Edit hKey
end mDouble_DisplayHkeyTreeArray

on mDouble_DisplayObjectHkeyArray dView, someValue, pathItems
   put 1 into hNum
   set the itemdelimiter to slash
   put item 1 of pathItems into hObject
   put item 2 of pathItems into shortHkey
   put hKeyLine_AddObject (shortHkey, hObject) into hKey
   
   hkey_Edit hKey
end mDouble_DisplayObjectHkeyArray


--> Display | HkeyArray
-
command display_HandlerHkeyArray hKey, pHkeyArray, pLabel, pShowHow, pStripMissing
   if pHkeyArray is not an array then
      put walk_ConstructHkeyArray (hKey) into pHkeyArray
   end if
   if pShowHow is empty then
      put "stacks" into pShowHow
   end if
   if pLabel is empty then
      put word 1 to 2 of hKey into pLabel
   end if
   --
   put hkeyArray_DisplayData (pHkeyArray, pShowHow, pStripMissing, hKey) into dData
   --
   display_Tool dData, pLabel, "HkeyArray"
   put the result into dView
   set the tool_Context of dView to "lcw_Graph"
   --
   set the show_How of dView to pShowHow
   set the displayed_Hkey of dView to hKey
   set the displayed_HkeyArray of dView to pHkeyArray
   --
   return dView
end display_HandlerHkeyArray

command display_HkeyLinkArray hkey, pGraphStyle
   put hKey_GetArray (hkey) into hkeyArray
   --
   display_LinkArray hkeyArray, hKey, "Hkey LinkArray"
   put the result into dView
   --
   set the displayed_Hkey of dView to hKey
   set the displayed_GraphStyle of dView to pGraphStyle
   set the link_Array of dView to hkeyArray
   --
   return dView
end display_HkeyLinkArray


--> Working on
-
command display_ScriptFromHkeys hKeys, pTitle
   put script_CollectFromObjects (hKeys, false) into newScript
   display_Script newScript
   return the result
end display_ScriptFromHkeys
 

--> Display | HkeyArray | Script
-
command display_HkeyDepScript hKey
   put walk_ConstructHkeyArray (hKey) into hkeyArray
   put "Deps for" && hKey into pTitle
   display_ScriptFromHkeyArray hkeyArray, pTitle, hKey
   return the result
end display_HkeyDepScript

command display_ScriptFromHkeyArray hkeyArray, pTitle, pFirstKey
   put hkeyArray_ListHkeys (hkeyArray, pFirstKey) into hKeys
   display_ScriptFromHkeys hKeys, pTitle
   return the result
end display_ScriptFromHkeyArray


--> Display | Deps
-
command display_HkeyDepArray hKey, pOverlayName
   -- Fetch stored hKeyArray for hkey and turn it into a depObjectArray
   put hkey_GetHkeyArray (hKey, pOverlayName) into hkeyArray
   --
   -- display_ObjectDepArray hkey, hkeyArray
   display_HkeyTreeArray hKeyArray, hKey
   --
   put the result into dView
   set the hkey_Array of dView to hkeyArray
   return dView
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
   
   display_Script newScript, someTitle
   --
   return someArray
end display_HkeyArrayDependencyScript


--> Display | Graph | Array
-
command display_OverlayData overlayFolder, pTitle
   put overlay_GetData (overlayFolder) into overlayData 
   
   display_Array overlayData, pTitle
   put the result into dView
   display_SetInteractions dView, "Script | Graph", ""
   --
   set the displayed_OverlayFolder of dView to overlayFolder
   set the displayed_OverlayName of dView to pOverlayName
   return dView
end display_OverlayData


--> Display | Script
-
command display_ScriptTools sObject
   put the script_SuiteArray of sObject into scriptArray
   --
   put the name of sObject into someTitle
   display_Data scriptArray, someTitle, "Script"
   put the result into dView
   set the displayed_ScriptArray of dView to scriptArray
   --
   set the displayed_Object of dView to sObject
   display_SetInteractions dView, "Script | Tree", "mDoubleUp_DisplayShortHkey"
   --   
   return dView
end display_ScriptTools

command display_ScriptArray scriptObject
   put the walk_HkeyArray of scriptObject into hKeyArray
   --
   graph_CreateFromScriptHkeyArray hkeyArray, scriptObject
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
   
   put hkeyStackArray_From (hkeyArray) into objectHKeyArray
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
   put the result into dView
   --
   -- may want to use "Global | HkeyArray | Tree | Filter | Menu"
   display_SetInteractions dView, "HkeyArray", "mDouble_DisplayHkeyTreeArray"
   set the displayed_Object of dView to hObject
   set the displayed_Hkey of dView to hKey
   return dView
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
   put the result into dView
   display_SetInteractions dView, "HkeyArray | Tree | Deps", "mouse_EditHkey"
   set the displayed_Object of dView to displayedObject
   return dView
end _DisplayHkeyArray
