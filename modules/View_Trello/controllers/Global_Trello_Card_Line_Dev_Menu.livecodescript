script "Global | Trello | Card | Line | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Trello | Card | Line | Dev | Menu
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


--> Global | Trello | Card | Line | Dev | Menu
-
on menu_DisplayedObject displayView
   put the displayed_Object of displayView
end menu_DisplayedObject

on menu_UpdateCardData displayView
   put the selected_ID of displayView into cardID
   --
   display_UpdateTrelloCardData displayView, cardID
   --
   menu_DisplayViewData displayView
end menu_UpdateCardData

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

on menu_DisplayViewData displayView
   put the view_Data of displayView into viewData
   --
   display_Data viewData, "view_Data"
end menu_DisplayViewData

on menu_DisplayCardData displayView
   put the selected_CardData of displayView into cardData
   --
   put cardData ["name"] into cardName
   display_Data cardData, cardName, "Trello Card Data"
end menu_DisplayCardData
