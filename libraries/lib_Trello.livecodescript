script "lib_Trello"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Trello
type: library
version: 0.1

/*Some help*/


--> Working on
-
command audio_Play audioFiles   
   put view_GetTemplateObject ("View|Audio") into audioView
   if exists (audioView) then
      set the play_List [true] of audioView to audioFiles
   else
      -- breakpoint
   end if
end audio_Play

command audio_Pause
   put view_GetTemplateObject ("View|Audio") into audioView
   set the audio_Playing of audioView to false
end audio_Pause

command audio_Stop
   put view_GetTemplateObject ("View|Audio") into audioPlayer
   put "stop" && audioPlayer into doScript
   do doScript
end audio_Stop


--> Display | Card
-
on mDoubleUp_TrelloCard displayView
   trello_PlaySelectedAudio displayView
   display_TrelloSelectedCard displayView
end mDoubleUp_TrelloCard

command display_TrelloSelectedCard displayView
   put the selected_ID of displayView into cardID
   display_TrelloCard cardID, displayView
   return the result
end display_TrelloSelectedCard

command trello_PlaySelectedAudio displayView
   put the selected_AudioFile of displayView into audioFile
   audio_Play audioFile
end trello_PlaySelectedAudio

command display_TrelloCard cardID, pDisplayView
   -- right_View is hard wired
   put trello_GetCard (cardID) into cardData
   --
   put cardData ["name"] into cardName
   put cardData ["labels"] into labelData
   put cardData ["attachments"][1]["url"] into bigURL
   -- put cardData ["attachments"][1]["previews"][1]["url"] into thumbURL
   --
   if exists (pDisplayView) then
      put the right_View of pDisplayView into rightView
      set the displayed_Data of rightView to bigURL
      return rightView
   else
      display_Image bigURL, cardName, "Trello Card"
      return the result
   end if
end display_TrelloCard

command display_TrelloCardData cardData, pListName, pDisplayView
   put indexArray_GetNumbered (cardData) into numArray
   display_Data numArray, pListName, "Trello List", pDisplayView
   put the result into displayView
   set the view_Data of pDisplayView to cardData
   
   display_SetInteractions displayView, "Trello | List", "mDoubleUp_TrelloCard", "lib_Trello"
   return displayView
   
   display_ArrayIndex cardData, "name", pListName, "Trello Cards", pDisplayView
   put the result into displayView
   display_SetInteractions displayView, "Trello | List", "mDoubleUp_TrelloCard", "lib_Trello"
   return displayView
end display_TrelloCardData


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
      _PlayAndWait
   end repeat
   --
   set the coloured_Lines of displayView to empty
end display_TrelloPresentation

command _PlayAndWait
   wait 3 seconds
end _PlayAndWait


--> Display | Events
-
on mDoubleUp_TrelloBoard displayView, boardName
   breakpoint
   mDoubleUp_TrelloBoards displayView, boardName
end mDoubleUp_TrelloBoard

on mDoubleUp_TrelloList displayView, listName
   put the view_Data of displayView into listData
   --
   put array_IndexFind (listData, "name", listName) into indexNum
   put listData [indexNum]["id"] into listID
   --
   display_TrelloList listID, listName, displayView
end mDoubleUp_TrelloList

on mDoubleUp_TrelloBoards displayView, boardName
   put the view_Data of displayView into vData
   --
   put array_IndexFind (vData, "name", boardName) into indexNum
   put vData [indexNum]["id"] into boardID
   --
   display_TrelloBoardLists boardID, boardName, displayView
end mDoubleUp_TrelloBoards

on mDoubleUp_TrelloOrganisation displayView, orgName
   put the view_Data of displayView into vData
   put array_IndexFind (vData, "displayName", orgName) into indexNum
   --
   put vData [indexNum]["id"] into orgID
   put vData [indexNum]["displayName"] into orgName
   --
   display_TrelloOrgBoards orgID, orgName, displayView
end mDoubleUp_TrelloOrganisation


--> Display
-
command display_TrelloList listID, pListName, pDisplayView
   if pListName is empty then put listID into pListName
   ---
   put trello_GetListCards (listID) into cardData
   --
   display_TrelloCardData cardData, pListName, pDisplayView
   put the result into displayView
   return displayView
end display_TrelloList

command display_TrelloBoardCards listID, pBoardName, pDisplayView
   if pBoardName is empty then put boardID into pBoardName
   --
   put trello_ListBoardGards (boardID) into cardData
   --
   display_TrelloCardData cardData, pBoardName, pDisplayView
   put the result into displayView
   return displayView
end display_TrelloBoardCards

command display_TrelloBoardLists boardID, pBoardName, pDisplayView
   put trello_GetBoardLists (boardID) into listData
   display_TrelloListData listData, pBoardName, pDisplayView
   put the result into displayView
   return displayView
end display_TrelloBoardLists

command display_TrelloListData listData, pBoardName, pDisplayView
   display_ArrayIndex listData, "name", pBoardName, "Trello List", pDisplayView
   put the result into displayView
   display_SetInteractions displayView, "Trello | Board | List", "mDoubleUp_TrelloList", "lib_Trello"
   return displayView
end display_TrelloListData

command display_TrelloOrgBoards orgID, pOrgName, pDisplayView
   put trello_ListOrgBoards (orgID) into restData
   --
   display_ArrayIndex restData, "name", pOrgName, "Trello Board", pDisplayView
   put the result into displayView
   --
   display_SetInteractions displayView, "Trello | Boards", "mDoubleUp_TrelloBoards", "lib_Trello"
   return displayView
end display_TrelloOrgBoards

command display_TrelloOrganisations pDisplayView
   put trello_ListOrgs() into restData
   --
   display_ArrayIndex restData, "displayName", "Organisations", "Trello", pDisplayView
   put the result into displayView
   --
   display_SetInteractions displayView, "Trello | Organisations", "mDoubleUp_TrelloOrganisation", "lib_Trello"
   return displayView
end display_TrelloOrganisations


--> Trello
-
function trello_GetCard cardID
   put "attachments=true" into pFieldBit
   put "cards/" & cardID into restBit
   put trello_GetJsonRpcArray (restBit, pFieldBit) into listData
   return listData
end trello_GetCard

function trello_GetListCards listID
   put merge ("lists/[[listID]]/cards") into restBit
   put trello_GetJsonRpcArray (restBit) into restData
   return restData
end trello_GetListCards

function trello_GetList listID, pFieldBit
   put "lists/" & listID into restBit
   put trello_GetJsonRpcArray (restBit, pFieldBit) into listData
   return listData
end trello_GetList

function trello_ListOrgs
   put "members/me/organizations" into restBit
   put trello_GetJsonRpcArray (restBit) into restData
   return restData
end trello_ListOrgs

function trello_ListOrgBoards orgID
   put merge ("organizations/[[orgID]]/boards") into restBit
   put trello_GetJsonRpcArray (restBit) into restData
   return restData
end trello_ListOrgBoards

function trello_ListBoards pFieldBit
   -- put "fields=name,url" into pFieldBit
   put "members/me/boards" into restBit
   put trello_GetJsonRpcArray (restBit, pFieldBit) into restData
   return restData
end trello_ListBoards

function trello_GetBoard boardID, pFieldBit
   put "boards/" & boardID into restBit
   put trello_GetJsonRpcArray (restBit, pFieldBit) into restData
   return restData
end trello_GetBoard

function trello_GetBoardLists boardID
   put merge ("boards/[[boardID]]/lists") into restBit
   put trello_GetJsonRpcArray (restBit, pFieldBit) into restData
   return restData
end trello_GetBoardLists

function trello_ListBoardGards boardID
   put merge ("boards/[[boardID]]/cards") into restBit
   put trello_GetJsonRpcArray (restBit, pFieldBit) into restData
   return restData
end trello_ListBoardGards


--> Deps
-
function trello_GetJsonRpcArray restBit, pAndBit
   put trello_ConstructRestUrl (restBit, pAndBit) into restURL
   put jsonrpc_GetArray (restURL) into restData
   return restData
end trello_GetJsonRpcArray

command trello_PostArray postArray, restURL
   put trello_GetAccessToken() into oAuthToken
   put json_FromArray (postArray) into someJSON
   --
   rest_SetJsonHeaders oAuthToken
   post someJSON to url restUrl
   put it into jsonResult
   --
   put json_ToArray (jsonResult) into resultArray
   return resultArray
end trello_PostArray

function trello_ConstructRestUrl restBit, pAndBit
   put trello_GetApiKey() into yourKey
   put trello_GetAccessToken() into yourToken
   --
   put "https://api.trello.com/1/" into restURL
   put restBit after restURL
   put merge ("?key=[[yourKey]]&token=[[yourToken]]") after restURL
   --
   if restURL is not empty then
      put "&" & pAndBit after restURL
   end if
   return restURL
end trello_ConstructRestUrl

function trello_GetApiKey
   return secret_Get ("Trello ApiKey")
end trello_GetApiKey

command trello_SetApiKey sApiKey
   secret_Set "Trello ApiKey", sApiKey
   return the result
end trello_SetApiKey

function trello_GetSecret
   -- https://trello.com/power-ups/64adb64babb4d544ec61f8be/edit/api-key
   return secret_Get ("Trello Secret")
end trello_GetSecret

command trello_SetSecret someSecret
   secret_Set "Trello Secret", someSecret
   return the result
end trello_SetSecret

function trello_GetAccessToken
   return secret_Get ("Trello Token")
end trello_GetAccessToken

command trello_SetAccessToken sToken
   secret_Set "Trello Token", sToken
   return the result
end trello_SetAccessToken
