script "Global | HkeyArray | Tree | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | HkeyArray | Tree | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the displayed_Object of dView into sObject
   put the displayed_HkeyArray of dView into hkeyArray
   --
   put hkeyArray into LocalArray ["hkeyArray"]
   put dView into LocalArray ["dView"]
   --
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return true
end menu_CheckTarget

getprop checked_FoundButOutside [dView]
   put the missing_FoundButOutsideArray of dView into foundButOutsideArray -- add dependency to index
   return the keys of foundButOutsideArray is not empty
end checked_FoundButOutside

getprop checked_InShortHkeys [dView]
   put the missing_InShortArray of dView into inShortArray -- should be fine
   return the keys of inShortArray is not empty
end checked_InShortHkeys

getprop checked_MissingKeys [dView]
   get the missing_Array of dView
   return keys (it) is not empty
end checked_MissingKeys

getprop disabled_ListCallsOutsideScript [dView]
   put the displayed_Object of dView into sObject
   return exists (sObject) is false
end disabled_ListCallsOutsideScript


--> Global | HkeyArray | Tree | Menu
-
on menu_ListCallsOutsideScript dView
   put the displayed_HkeyArray of dView into hkeyArray
   put the displayed_Object of dView into sObject
   
   put array_List (hkeyArray) into hKeys
   put hkeyIndex_FilterOutside (hKeys, sObject, true) into outsideKeys
   
   # List
   display_Data outsideKeys, sObject, "Outside Deps"
   
   # Collect
   put "Deps of" && sObject into sTitle
   display_CollectedHkeys outsideKeys, sTitle
end menu_ListCallsOutsideScript

on menu_CallsOutsideScript dView
   put the show_How of dView into sHow
   put the displayed_Hkey of dView into hKey
   put the displayed_HkeyArray of dView into hkeyArray
   put the displayed_Object of dView into sObject
   
   # Search Hierarcy
   if sObject is empty then
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put hObject into sObject
   end if
   
   display_CallsOutside hkeyArray, sObject, hKey -- uses collection
end menu_CallsOutsideScript

private on __
end __

on menu_FoundButOutside dView
   put the missing_FoundButOutsideArray of dView into foundButOutsideArray -- add dependency to index
   --
   _DisplayMissing "Found but Outside", missingPlaceArray, dView
end menu_FoundButOutside

on menu_InShortHkeys dView
   put the missing_InShortArray of dView into inShortArray -- should be fine
   --
   _DisplayMissing "In short hKeys", inShortArray, dView
end menu_InShortHkeys

on menu_MissingKeys dView
   put the missing_Array of dView into missingArray -- bad
   --
   _DisplayMissing "Missing Hkeys", missingArray, dView
end menu_MissingKeys

private on ___
end ___

private on ____
end ____

on menu_Recreate dView
   put the displayed_Object of dView into sObject
   --
   ask_CreateDepHkeyArray sObject, dView
   
   # Display
   put the script_HkeyArray of sObject into hKeyArray
   put the name of sObject into sTitle
   set the displayed_Array of dView to hkeyArray
end menu_Recreate

on menu_Refresh dView
   if the shiftKey is "down" then
      put the script_HkeyArray of sObject into hKeyArray
   else
      put the displayed_HkeyArray of dView into hkeyArray
   end if
   put the displayed_Object of dView into sObject
   --
   put the name of sObject into sTitle
   set the displayed_Array of dView to hkeyArray
end menu_Refresh

on submenu_Dev
   return "Global | HkeyArray | Missing | Dev | Menu"
end submenu_Dev
