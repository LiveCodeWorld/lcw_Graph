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
   put hkeyArray_GetStackDepArray (hkeyArray) into depArray
   put depArray ["Missing"] into missingArray
   put hkeyArray_TidyMissing (missingArray) into prettyMissingArray
   --
   display_Data prettyMissingArray, "prettyMissingArray"
end menu_ConstructMissing

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | HkeyArray | Tree | Dev | Menu"
end menu_MenuEdit
