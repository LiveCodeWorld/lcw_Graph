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

This menu is renamed "Global | Trello | Card | Menu"
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

getprop rocketRecordings_Params [displayView]
   put trello_RocketLists() into rocketLists
   return rocketLists
end rocketRecordings_Params

getprop checked_EditMode[dgView]
   put the dgEditMode of dgView into sBoolean
   return sBoolean
end checked_EditMode


--> Global | Trello | List | Menu
-
on menu_RocketRecordings dgView, listName
   -- display_RocketRecordings listName
   
   put trello_FetchCardArray (listName, "64aa88f3a4df035aabba896e") into cardArray
   -- display_Data cardArray, listName, "Rocket Recordings"
   set the dgData of dgView to cardArray
end menu_RocketRecordings

on menu_EditMode dgView
   put the dgEditMode of dgView is false into newBoolean
   set the dgEditMode of dgView to newBoolean
end menu_EditMode

private on _
end _

on menu_DisplayRocketBook leftView
   display_TrelloRocketBook leftView
end menu_DisplayRocketBook

on menu_TrelloOrganisations displayView
   display_TrelloOrganisations displayView
end menu_TrelloOrganisations

private on __
end __

on menu_PresentSlideShow displayView
   display_TrelloPresentation displayView
end menu_PresentSlideShow

on menu_PlayAudioSeries dView
   put the audio_Files of dView into audioFiles
   --
   audio_Play audioFiles
end menu_PlayAudioSeries

on menu_DisplayAudioCards displayView
   put the audio_Cards of displayView into sNames
   set the coloured_Lines ["red"] of displayView to sNames
end menu_DisplayAudioCards

private on __
end __

on menu_ShowNumbers displayView
   put the show_Numbers of displayView into sBoolean
   set the show_Numbers of displayView to (sBoolean is false)
end menu_ShowNumbers

on subMenu_Audio
   return "Global | Audio | Record | Menu"
end subMenu_Audio

on subMenu_Saved
   return "Global | Trello | Saved | Menu"
end subMenu_Saved

private on ___
end ___

on subMenu_Dev
   put menu_DevTitle() into mTitle
   return mTitle
end subMenu_Dev
