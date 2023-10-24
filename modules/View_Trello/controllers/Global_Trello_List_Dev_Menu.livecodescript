script "Global | Trello | List | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Trello | List | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
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

getprop checked_ShowNumbers [displayView]
   put the show_Numbers of displayView into sBoolean
   return sBoolean
end checked_ShowNumbers


--> Global | Trello | List | Dev | Menu
-
on menu_ShowNumbers displayView
   put the show_Numbers of displayView into sBoolean
   set the show_Numbers of displayView to (sBoolean is false)
end menu_ShowNumbers

on menu_TrimChars displayView
   put the trim_Num of displayView into sNum
   put lcw_Ask ("Set the charsToTrimFromKey...", sNum, "trim_Num", displayView) into sNum
   set the trim_Num of displayView to sNum
end menu_TrimChars

on menu_File displayView
   -- put the constructed_ShortAudioFile of displayView -- into audioFile
   -- put the constructed_AudioFile of displayView -- into audioFile
   put the selected_CardDataShortFile of displayView
end menu_File

on menu_DisplayViewData displayView
   put the view_Data of displayView into viewData
   --
   display_Data viewData, "view_Data"
end menu_DisplayViewData

private on _
end _

on menu_EditCardScript displayView
   put the card_Object of displayView into cardObject
   edit the script of cardObject
end menu_EditCardScript

on menu_ViewBehavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_ViewBehavior

private on __
end __

on menu_Numbered displayView
   put the view_Data of displayView into indexArray
   put indexArray_GetNumbered (indexArray) into numArray
   --
   set the displayed_Data of displayView to numArray
end menu_Numbered

on menu_ViewData displayView
   put the view_Data of displayView into indexArray
   --
   set the displayed_Data of displayView to indexArray
end menu_ViewData

on menu_Refresh displayView
   put the view_Data of displayView into indexArray
   --
   set the index_Array of displayView to indexArray
end menu_Refresh

on menu_DisplayCardData displayView
   put the view_Data of displayView into vData
   --
   display_Data vData
end menu_DisplayCardData

private on ____
end ____

on menu_MenuEdit displayView
   menu_Edit "Global | Trello | List | Dev | Menu"
end menu_MenuEdit

