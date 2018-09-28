script "lib_DisplayHkeyArray"
--> MetaData
-
license: GPLv3
name: lib_DisplayHkeyArray
type: library
version: 0.3

/*
command display_ScriptHkeyArray hkeyArray, scriptObject
put hkeyArray_ConstructObjectArray (hkeyArray) into objectHKeyArray
--
put hkeyArray_TidyObjectArray (objectHKeyArray) into objectTreeArray
put "script" into hName
put hName,scriptObject into displayTitle

put "mDouble_DisplayObjectHkeyArray" into pDoubleUpCommand
put empty into mUpCommand

put "Global | HkeyArray | Script | Tree | Menu" into treeMenu
put "Global | HkeyArray | Script | Tree | Line | Menu" into lineMenu
-- put "Global | HkeyArray | Menu" into treeMenu
-- put "Global | HkeyArray | Line | Menu" into lineMenu

display_Array objectTreeArray, displayTitle, treeMenu, lineMenu, mUpCommand, pDoubleUpCommand
put the result into treeView

set the displayed_Object of treeView to scriptObject
set the displayed_HkeyArray of treeView to hKeyArray
set the displayed_ObjectHKeyArray of treeView to objectTreeArray

return treeview
end display_ScriptHkeyArray
*/


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

command display_ObjectDepArray hObject, hkeyArray
   -- think hObject can be hkey or Object
   if hkeyArray is empty then
      put the projectOverlay_Array ["processedHkey.array"] of hObject into hkeyArray
   end if
   
   put hkeyArray_ConstructObjectArray (hkeyArray) into objectHKeyArray
   put hkeyArray_TidyObjectArray (objectHKeyArray) into objectTreeArray
   --
   display_HkeyTreeArray objectTreeArray, hObject, "mDouble_DisplayObjectHkeyArray"
   --
   put the result into treeView
   set the view_Data of treeView to hKeyArray
   return treeview
end display_ObjectDepArray

command display_HkeyTreeArray treeArray, hkeyOrObject, pDoubleUpCommand
   -- _setObjectTitleHkey hkeyOrObject, hKey, hObject, displayTitle
   switch
      case exists (hkeyOrObject)
         put "script" into hName
         put hkeyOrObject into hObject
         put empty into hKey
         put hName,hObject into displayTitle
         break
      case the number of items of hkeyOrObject = 4
         put hkeyOrObject into hKey
         put item 1 of hKey into hName
         put item 3 of hKey into hObject
         put hName,hObject into displayTitle
         break
      default
         put "hKeyArray" into displayTitle
         put empty into hKey
         put empty into hObject
   end switch
   
   if pDoubleUpCommand is empty then put "mDouble_DisplayHkeyTreeArray" into pDoubleUpCommand
   put "Global | HkeyArray | Menu"into treeMenu
   put "Global | HkeyArray | Line | Menu" into lineMenu
   -- may want to use "Global | HkeyArray | Tree | Filter | Menu"
   put empty into mUpCommand
   
   display_Array treeArray, displayTitle, treeMenu, lineMenu, mUpCommand, pDoubleUpCommand
   put the result into treeView
   
   set the displayed_Object of treeView to hObject
   set the displayed_Hkey of treeView to hKey
   return treeview
end display_HkeyTreeArray

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

command display_Dot dotText, pStyleOrDotArray, pImageView, pStackLabel, pDotFile, pResizeStyle
   if exists (pImageView) is false then
      if pResizeStyle is empty then put "fit inside frame" into pResizeStyle
      if pStackLabel is empty then put "Dot" into pStackLabel
      display_Image empty, true, pStackLabel, true
      put the result into pImageView
   end if
   
   if pStyleOrDotArray is an array then
      set the overlay_Array of pImageView to pStyleOrDotArray
   else
      set the overlay_Style of pImageView to pStyleOrDotArray
   end if
   
   set the image_File of pImageView to ""
   set the uOPN ["dot_File"] of pImageView to pDotFile
   set the dot_Text of pImageView to dotText 
   
   object_GoTo pImageView, true
   return pImageView
end display_Dot


--> Display | Graph | Array
-
command display_HKeyArray hKeyArray, hkeyOrObject
   local pDoubleUpCommand
   
   put hkeyArray_ConstructTreeArray (hkeyArray) into treeArray
   display_HkeyTreeArray treeArray, hkeyOrObject, pDoubleUpCommand
   put the result into treeView
   set the view_Data of treeView to hKeyArray
   return treeview
end display_HKeyArray

command display_HkeyTreeArray treeArray, hkeyOrObject, pDoubleUpCommand
   -- _setObjectTitleHkey hkeyOrObject, hKey, hObject, displayTitle
   switch
      case exists (hkeyOrObject)
         put "script" into hName
         put hkeyOrObject into hObject
         put empty into hKey
         put hName,hObject into displayTitle
         break
      case the number of items of hkeyOrObject = 4
         put hkeyOrObject into hKey
         put item 1 of hKey into hName
         put item 3 of hKey into hObject
         put hName,hObject into displayTitle
         break
      default
         put "hKeyArray" into displayTitle
         put empty into hKey
         put empty into hObject
   end switch
   
   if pDoubleUpCommand is empty then put "mDouble_DisplayHkeyTreeArray" into pDoubleUpCommand
   put "Global | HkeyArray | Menu"into treeMenu
   put "Global | HkeyArray | Line | Menu" into lineMenu
   -- may want to use "Global | HkeyArray | Tree | Filter | Menu"
   put empty into mUpCommand
   
   display_Array treeArray, displayTitle, treeMenu, lineMenu, mUpCommand, pDoubleUpCommand
   put the result into treeView
   
   set the displayed_Object of treeView to hObject
   set the displayed_Hkey of treeView to hKey
   return treeview
end display_HkeyTreeArray

command display_OverlayData overlayFolder, pTitle
   put overlay_GetData (overlayFolder) into overlayData 
   
   display_Array overlayData, pTitle, "Global | Script | Graph | Menu", "Global | Script | Graph | Line | Menu"
   put the result into treeView
   set the displayed_OverlayFolder of treeView to overlayFolder
   set the displayed_OverlayName of treeView to pOverlayName
end display_OverlayData

command mDouble_DisplayHkeyTreeArray treeWidget, someValue, pathItems
   put item 1 of pathItems into someThing
   replace slash with comma in someThing
   switch
      case exists (someThing)
         edit the script of someThing
         break
      case the number of items of someThing = 4
         hkey_Edit someThing
         break
      default
         put someThing
   end switch
end mDouble_DisplayHkeyTreeArray

on mDouble_DisplayObjectHkeyArray treeWidget, someValue, pathItems
   put 1 into hNum
   set the itemdelimiter to slash
   put item 1 of pathItems into hObject
   put item 2 of pathItems into shortHkey
   put hkeyLine_Construct (shortHkey, hObject) into hKey
   
   hkey_Edit hKey
end mDouble_DisplayObjectHkeyArray


--> Deps
-
command hkeyArray_ConstructDependencySuite hkeyArray, pStripScriptObject, @depSuite, pStripObjects, pStripProps, pMakePrivate
   local depScript
   
   put array_AllNodes (hkeyArray) into allCalls
   hkey_StripDuplicates allCalls
   put the result into duplicateHkeyArray
   
   put hkey_ConstructDepArray (allCalls, pMakePrivate) into depArray
   
   if exists (pStripScriptObject) is true then
      -- strip the nodes from the scriptObject whose hkeyArray we are processing
      hkey_SimpleStripObject allCalls, pStripScriptObject
      put the result into strippedKeys
   end if
   
   if pStripProps is true then
      -- this does not do a network walk (does this matter?)
      hkey_StripGetProps allCalls
      line_Add the result, strippedKeys
      
      hkey_StripSetProps allCalls
      line_Add the result, strippedKeys
   end if
   
   -- now let's recursively strip the nodes from the objects in pStripObjects we don't want
   repeat for each line stripObject in pStripObjects
      -- take care that the object name is fromatted correctly
      if exists(stripObject) is false then
         put merge ("Cannot find [[stripObject]]!") into someMessage
         lcw_Notify someMessage, true
         next repeat
      end if
      
      -- lets get rid of any calls to the objects we are stripping
      -- hkeyArray_RemoveObjectLinks hkeyArray, stripObject
      hkey_SimpleStripObject allCalls, stripObject
      line_Add the result, strippedKeys
   end repeat
   
   put strippedKeys into depArray ["strippedKeys"]
   put depArray ["depSuite"] into depSuite
   
   -- put script_ConstructDependencySuite (allCalls) into depSuite
   return depArray
end hkeyArray_ConstructDependencySuite

function hkey_ConstructDepArray allCalls, pMakePrivate
   local depScript, missingHkeys

   sort allCalls
   hkey_StripDuplicates allCalls
   put the result into duplicateHkeyArray
   
   script_FetchFromHkeys allCalls, depScript, missingHkeys, pMakePrivate
   put script_ConstructSuite ("Deps", depScript) into depSuite
   put depSuite into depArray ["depSuite"]
   
   put allCalls into depArray ["uniqueHkeys"]
   put missingHkeys into depArray ["missingHkeys"]
   put duplicateHkeyArray into depArray ["duplicateHkeyArray"]
   return depArray
end hkey_ConstructDepArray


--> HkeyArray | Graph
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


