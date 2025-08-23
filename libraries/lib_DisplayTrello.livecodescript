script "lib_DisplayTrello"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayTrello
type: library
version: 0.1

/*
A library to display Trello data.
*/

function trello_RocketLists
   put trello_GetBoardLists ("64aa88f3a4df035aabba896e") into listData
   put indexArray_List (listData) into listNames
   return listNames
end trello_RocketLists

function trello_RocketCardNames pListName
   if pListName is empty then put "Inbox" into pListName
   put trello_FetchCardArray (pListName, "64aa88f3a4df035aabba896e") into cardArray
   --
   put indexArray_List (cardArray) into rocketCardNames
   return rocketCardNames
end trello_RocketCardNames
   
function trello_FetchCardArray listName, boardID
   put trello_GetBoardLists (boardID) into listData
   --
   put indexArray_Find (listData, "name", listName) into indexNum
   put listData [indexNum]["id"] into listID
   --
   put trello_GetListCards (listID) into cardArray
   return cardArray
end trello_FetchCardArray


--> Working on
-
command display_TrelloRocketBook pDisplayView
   display_TrelloBoardLists "64aa88f3a4df035aabba896e", "Rocketbook", pDisplayView
   return the result
end display_TrelloRocketBook

command display_TrelloSelectedCard displayView
   put the selected_ID of displayView into cardID
   --
   if cardID is empty then
      -- not View|Trello|Card
      put the view_Data of displayView into listData
      --
      -- put indexArray_Find (listData, "name", cardName) into indexNum
      -- put the selected_Line of displayView into cardName
      
      put the selected_LineNum of displayView into indexNum
      put listData [indexNum]["id"] into cardID
   end if
   --
   display_TrelloCard cardID, displayView
   return the result
end display_TrelloSelectedCard

command display_TrelloCard cardID, pDisplayView
   put trello_GetCard (cardID) into cardData
   --
   put cardData ["name"] into cardName
   put cardData ["labels"] into labelData
   put cardData ["attachments"][1]["url"] into bigURL
   -- put cardData ["attachments"][1]["previews"][1]["url"] into thumbURL
   --
   if exists (pDisplayView) then
      put the displayed_Object of pDisplayView into rightView
      -- put the right_View of pDisplayView into rightView
      if exists (rightView) then
         set the displayed_Data of rightView to bigURL
         return rightView
      end if
   end if
   
   display_Image bigURL, cardName, "Trello Card"
   return the result
end display_TrelloCard

command display_UpdateTrelloCardData displayView, cardID
   breakpoint
   put the view_Data of displayView into viewData
   --
   put trello_GetCard (cardID) into cardData
   put indexArray_Find (viewData, "id", cardID) into indexNum
   put cardData into viewData [indexNum]
   --
   set the view_Data of displayView to viewData
end display_UpdateTrelloCardData


--> Display | Trello | Presntation
-
command display_TrelloPresentation displayView
   put the view_Data of displayView into vData
   put the displayed_Index of displayView into someIndex
   put the number of lines of someIndex into maxNum
   --
   repeat with lineNum = 1 to maxNum
      if the shiftKey is "Down" then
         display_Spin maxNum, displayView, "dark green"
         --
         put vData [maxNum]["id"] into cardID
         display_TrelloCard cardID, displayView
         --
         exit repeat
      end if
      
      display_Spin lineNum, displayView, "dark green"
      put vData [lineNum]["id"] into cardID
      --
      display_TrelloCard cardID, displayView
      --
      wait 3 seconds
   end repeat
   --
   set the coloured_Lines of displayView to empty
end display_TrelloPresentation


--> Display | Events
-
on mDoubleUp_TrelloOrganisation displayView, orgName
   put the view_Data of displayView into vData
   put indexArray_Find (vData, "displayName", orgName) into indexNum
   --
   put vData [indexNum]["id"] into orgID
   put vData [indexNum]["displayName"] into orgName
   --
   display_TrelloOrgBoards orgID, orgName, displayView
end mDoubleUp_TrelloOrganisation

on mDoubleUp_PlaySound displayView, shortFile
   put the audio_Folder of displayView into audioFolder
   put audioFolder & shortFile into audioFile
   --
   -- audio_Play audioFile -- causes crash when combined with tree widget messaging.
end mDoubleUp_PlaySound

on mDoubleUp_TrelloList displayView, listName
   put the view_Data of displayView into listData
   --
   put indexArray_Find (listData, "name", listName) into indexNum
   put listData [indexNum]["id"] into listID
   --
   display_TrelloList listID, listName, displayView
end mDoubleUp_TrelloList

on mDoubleUp_TrelloBoards displayView, boardName
   put the view_Data of displayView into boardData
   --
   put indexArray_Find (boardData, "name", boardName) into indexNum
   put boardData [indexNum]["id"] into boardID
   --
   display_TrelloBoardLists boardID, boardName, displayView
end mDoubleUp_TrelloBoards

on mDoubleUp_TrelloCard displayView
   trello_PlaySelectedAudio displayView
   display_TrelloSelectedCard displayView
end mDoubleUp_TrelloCard


--> Display | Card
-
command display_TrelloOrganisations pDisplayView, pRightView
   put trello_ListOrgs() into indexArray
   if indexArray is false then
      beep
      return false
   end if
   --
   display_IndexArray indexArray, "Organisations", "Trello", false, "displayName", pDisplayView
   display_SetInteractions the result, "Trello | Organisations", "mDoubleUp_TrelloOrganisation", "lib_Trello"
   put the result into displayView
   --
   if exists (pRightView) is false then
      put the right_View of default_FirstStackControl ("View|Trello") into pRightView
   end if
   set the displayed_Object of displayView to pRightView
   --
   return displayView
end display_TrelloOrganisations

command display_TrelloOrgBoards orgID, pOrgName, pDisplayView
   put trello_ListOrgBoards (orgID) into indexArray
   if indexArray is false then
      beep
      return false
   end if
   --
   _DisplayIndexOrArray indexArray, pOrgName, "Trello | Boards", pDisplayView
   --
   put the result into displayView
   return displayView
end display_TrelloOrgBoards

command display_TrelloCardData cardData, listName, pDisplayView
   _DisplayIndexOrArray cardData, listName, "Trello | Card", pDisplayView
   put the result into displayView
   return displayView
end display_TrelloCardData

command display_TrelloSounds
   put trello_ListModuleAssets (true) into audioFiles
   --
   display_Data audioFiles, "Sounds", "Trello"
   put the result into displayView
   display_SetInteractions displayView, "Audio", "mDoubleUp_PlaySound", "lib_Trello"
   --
   put trello_GetAssetFolder() into audioFolder
   set the audio_Folder of displayView to audioFolder
   put default_FirstStackControl ("View|Audio") into audioPlayer
   set the displayed_Object of displayView to audioPlayer
   --
   return displayView
end display_TrelloSounds


--> Display
-
command display_TrelloList listID, pListName, pDisplayView
   if pListName is empty then put listID into pListName
   ---
   put trello_GetListCards (listID) into indexArray
   if indexArray is false then
      beep
      return false
   end if
   --
   display_TrelloCardData indexArray, pListName, pDisplayView
   return the result
end display_TrelloList

command display_TrelloBoardCards listID, pBoardName, pDisplayView
   if pBoardName is empty then put boardID into pBoardName
   --
   put trello_ListBoardGards (boardID) into indexArray
   if indexArray is false then
      beep
      return false
   end if
   --
   display_TrelloCardData indexArray, pBoardName, pDisplayView
   return the result
end display_TrelloBoardCards

command display_TrelloBoardLists boardID, pBoardName, pDisplayView
   put trello_GetBoardLists (boardID) into listData
   if listData is false then
      beep
      return false
   end if
   display_TrelloListData listData, pBoardName, pDisplayView
   return the result
end display_TrelloBoardLists

command display_TrelloListData listData, pBoardName, pDisplayView
   _DisplayIndexOrArray listData, pBoardName, "Trello | List", pDisplayView
   return the result
end display_TrelloListData


--> Private
-
command _DisplayIndexOrArray indexArray, titleText, menuBit, pDisplayView
   if the tree_View of pDisplayView is empty then
      put indexArray_List (indexArray) into boardNames
      display_Data boardNames, titleText, menuBit, pDisplayView
      put the result into displayView
      set the view_Data of displayView to indexArray
   else
      display_IndexArray indexArray, titleText, menuBit, true, "name", pDisplayView
      put the result into displayView
   end if
   --
   display_SetMouseAndMenu displayView, menuBit, "lib_Trello"
   return displayView
end _DisplayIndexOrArray
