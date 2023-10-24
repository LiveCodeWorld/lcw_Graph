script "Global | Trello | List | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | List | Line | Menu
type: controller
version: 0.1

/*
Renamed "Global | Trello | Card | Line | Menu"

The technical specifications of the recording are determined by the settings of the 
recordCompression 
recordChannels
recordRate 
recordSampleSize 
recordFormat
properties.

Note: If you choose to record to a file that already exists, the record sound command will overwrite the existing file, 
it will not append the new recording to the end.

These capabilities are now available using the answer record command and the recordRate and recordCompression properties.
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

command display_UpdateTrelloCardData displayView, cardID
   put the view_Data of displayView into viewData
   --
   put trello_GetCard (cardID) into cardData
   put indexArray_Find (viewData, "id", cardID) into indexNum
   put cardData into viewData [indexNum]
   --
   set the view_Data of displayView to viewData
end display_UpdateTrelloCardData


--> Global | Trello | List | Line | Menu
-
on menu_DisplayedObject displayView
   put the displayed_Object of displayView
end menu_DisplayedObject

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

on menu_DisplayCardData displayView
   put the selected_CardData of displayView into cardData
   --
   put cardData ["name"] into cardName
   display_Data cardData, cardName, "Trello Card Data"
end menu_DisplayCardData

private on __
end __

on menu_LaunchAudioUrl displayView
   put the selected_FirstAudioUrl of displayView into audioURL
   launch url audioURL
end menu_LaunchAudioUrl

on menu_DownloadCardAudio displayView
   put the selected_FirstAudioUrl of displayView into audioURL
   put the selected_ShortFile of displayView into shortFile
   --
   put trello_GetAssetFolder() & shortFile into audioFile
   --
   put url audioURL into url ("binfile:" & audioFile)
   finder_Reveal audioFile
end menu_DownloadCardAudio

private on ___
end ___

on menu_File displayView
   -- put the constructed_ShortAudioFile of displayView -- into audioFile
   -- put the constructed_AudioFile of displayView -- into audioFile
   put the selected_CardDataShortFile of displayView
end menu_File

on menu_LaunchTrello displayView
   put the selected_CardData of displayView into cardData
   put cardData ["url"] into trelloURL
   launch url trelloURL
end menu_LaunchTrello

on menu_DisplayViewData displayView
   put the view_Data of displayView into viewData
   --
   display_Data viewData, "view_Data"
end menu_DisplayViewData
