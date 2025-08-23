script "Global | Trello | Card | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Card | Menu
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

getprop checked_ShowNumbers [displayView]
   put the show_Numbers of displayView into sBoolean
   return sBoolean
end checked_ShowNumbers

-- getprop disabled_ScaleProportionally [displayView]
put the card_Object of displayView into cardObject
put the right_View of cardObject into rightView
if exists (rightView) then
   return false
else
   return true
end if
end disabled_ScaleProportionally

getprop checked_ScaleProportionally [displayView]
   put the card_Object of displayView into cardObject
   put the right_View of cardObject into rightView
   put the scale_Proportionally of rightView into sBoolean
   return sBoolean
end checked_ScaleProportionally


--> Global | Trello | Card | Menu
-
on menu_DisplayRocketBook leftView
   display_TrelloRocketBook leftView
end menu_DisplayRocketBook

on menu_TrelloOrganisations displayView
   display_TrelloOrganisations displayView
end menu_TrelloOrganisations

private on _
end _

on menu_PresentSlideShow displayView
   display_TrelloPresentation displayView
end menu_PresentSlideShow

on menu_PlayAudioSeries displayView
   put the audio_Files of displayView into audioFiles
   --
   audio_Play audioFiles
end menu_PlayAudioSeries

private on __
end __

on subMenu_Audio
   return "Global | Audio | Record | Menu"
end subMenu_Audio

on subMenu_Saved
   return "Global | Trello | Saved | Menu"
end subMenu_Saved

private on ___
end ___

on menu_ScaleProportionally displayView
   put the card_Object of displayView into cardObject
   put the right_View of cardObject into rightView
   _Exit rightView
   --
   put the scale_Proportionally of rightView into sBoolean
   set the scale_Proportionally of rightView to (sBoolean is false)
end menu_ScaleProportionally

on submenu_Card
   return "Global | Card | Menu"
end submenu_Card

on submenu_Dev
   return menu_DevTitle ("Global | Trello | Card | Menu")
end submenu_Dev
