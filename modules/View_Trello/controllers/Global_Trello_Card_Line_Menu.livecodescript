script "Global | Trello | Card | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Card | Line | Menu
type: controller
version: 0.1

/*
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


--> Global | Trello | Card | Line | Menu
-
on menu_UpdateCardData displayView
   breakpoint
   put the selected_ID of displayView into cardID
   --
   display_UpdateTrelloCardData displayView, cardID
   --
   menu_DisplayViewData displayView
end menu_UpdateCardData

on submenu_Audio
   return "Global | Audio | Record | Menu"
end submenu_Audio

private on _
end _

on menu_DisplayCard displayView
   put the selected_Line of displayView into cardName
   --
   dispatch "mDoubleUp_TrelloCard" to displayView with displayView,cardName
end menu_DisplayCard

private on __
end __

getprop disabled_LaunchTrelloAudioUrl [displayView]
   put the selected_FirstAudioUrl of displayView into audioURL
   return audioURL is empty
end disabled_LaunchTrelloAudioUrl

on menu_UploadAudio displayView
   
end menu_UploadAudio

on menu_LaunchTrelloAudioUrl displayView
   put the selected_FirstAudioUrl of displayView into audioURL
   launch url audioURL
end menu_LaunchTrelloAudioUrl

on menu_LaunchTrello displayView
   put the selected_CardData of displayView into cardData
   put cardData ["url"] into trelloURL
   launch url trelloURL
end menu_LaunchTrello

on submenu_Dev
   return menu_DevTitle ("Global | Trello | Card | Line | Menu")
end submenu_Dev
