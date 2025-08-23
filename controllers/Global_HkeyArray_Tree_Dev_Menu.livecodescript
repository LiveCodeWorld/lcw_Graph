script "Global | HkeyArray | Tree | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Tree | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | HkeyArray | Tree | Dev | Menu
-
on menu_ConstructMissing dView
   put the displayed_HkeyArray of dView into hkeyArray
   --
   put hkeyStackArray_From (hkeyArray) into depArray
   put depArray ["Missing"] into missingArray
   put hkeyArray_TidyMissing (missingArray) into prettyMissingArray
   --
   display_Data prettyMissingArray, "prettyMissingArray"
end menu_ConstructMissing

on menu_TestDeps dView
   put the show_How of dView into sHow
   put the displayed_Hkey of dView into hKey
   put the displayed_HkeyArray of dView into hkeyArray
   put the displayed_Object of dView into sObject
   
   menu_DisplayHkeyIndex dView
   put the result into hKeys
   -- put the displayed_Index of dView into hKeys
   
   # Search Hierarcy
   if sObject is empty then
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put hObject into sObject
   end if
   put the walk_Hierarchy [hKey] of sObject into searchObjects
   
   # Missing
   put hkey_ConstructMissingData (hKeys, sObject, searchObjects, dView) into missingData
   --
   put missingData ["foundArray"] into foundArray -- fine
   put missingData ["inShortArray"] into inShortArray -- should be fine
   --
   put missingData ["foundButOutsideArray"] into foundButOutsideArray -- add dependency to index
   put missingData ["missingArray"] into missingArray -- bad
   
   # Store arrays
   set the missing_FoundArray of dView to foundArray -- fine
   set the missing_InShortArray of dView to inShortArray -- should be fine
   --
   set the missing_FoundButOutsideArray of dView to foundButOutsideArray -- add dependency to index
   set the missing_Array of dView to missingArray -- bad
   
   # Display
   if keys (missingArray) is empty then
      # Display Missing but Found
      _DisplayMissing "Found but Outside", foundButOutsideArray, dView
   else
      _DisplayMissing "Missing", missingArray, dView
   end if
   
   # Collect Script
   if keys (foundButOutsideArray) is not empty then
      put array_ListKeys (foundButOutsideArray) into foundButOutsideKeys
      put the name of sObject into sTitle
      display_CollectedHkeys foundButOutsideKeys, sTitle
   end if
end menu_TestDeps

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | HkeyArray | Tree | Dev | Menu"
end menu_MenuEdit
