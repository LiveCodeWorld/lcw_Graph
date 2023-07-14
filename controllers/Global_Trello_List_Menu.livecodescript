script "Global | Trello | List | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | List | Menu
type: controller
version: 0.1

/*
A Trello list is a list of cards.
Basically a Kanban column of cards.
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


--> Global | Trello | List | Menu
-
on menu_PresentSlideShow displayView
   display_TrelloPresentation displayView
end menu_PresentSlideShow

on menu_PlayAudioSeries dView
   put the found_AudioFiles of dView into audioFiles
   --
   audio_Play audioFiles
end menu_PlayAudioSeries

private on _
end _

on subMenu_Audio
   return "Global | Audio | Record | Menu"
end subMenu_Audio

on subMenu_Saved
   return "Global | Trello | Saved | Menu"
end subMenu_Saved

private on __
end __

on menu_EditCardScript displayView
   put the card_Object of displayView into cardObject
   edit the script of cardObject
end menu_EditCardScript

on menu_ViewBehavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_ViewBehavior

private on ___
end ___

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
