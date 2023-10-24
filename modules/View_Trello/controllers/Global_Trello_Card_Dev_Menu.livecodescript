script "Global | Trello | Card | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Trello | Card | Dev | Menu
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

getprop menu_IsSimple
   return true
end menu_IsSimple


--> Global | Trello | Card | Dev | Menu
-
on menu_DisplayAudioCards displayView
   put the audio_Cards of displayView into audioCards
   --
   set the coloured_Lines ["dark green"] of displayView to audioCards
end menu_DisplayAudioCards

on menu_ShowNumbers displayView
   put the show_Numbers of displayView into sBoolean
   set the show_Numbers of displayView to (sBoolean is false)
end menu_ShowNumbers

private on _
end _

on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior
