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

--> Audio
-
command trello_PlaySelectedAudio displayView
   send "trello_PlayRandomAudio" to me in 4 seconds
   -- put the selected_AudioFile of displayView into audioFile
   -- audio_Play audioFile
end trello_PlaySelectedAudio

command trello_PlayRandomAudio audioFiles
   -- put audio_GetRandomFile (audioFiles) into audioFile
   --
   -- audio_Play audioFile
   return audioFile
end trello_PlayRandomAudio

function trello_GetRandomAudio pAudioFiles
   if audioFiles is empty then
      put trello_ListModuleAssets() into pAudioFiles
   end if
   --
   return audio_GetRandomFile (pAudioFiles)
end trello_GetRandomAudio


--> Trello | Assets
-
function trello_ListModuleAssets pListShort
   put trello_GetAssetFolder() into audioFolder
   if pListShort is true then
      return file_ListShort (audioFolder)
   else
      return file_ListLong (audioFolder)
   end if
end trello_ListModuleAssets

function trello_GetAssetFolder
   put the module_AssetFolder of stack "View|Trello" into mFolder
   folder_CreateNested mFolder
   return mFolder
end trello_GetAssetFolder


--> Trello | Audio
-
function trello_GetFirstAudioURL cardData
   put trello_GetAudioArray (cardData) into audioArray
   put audioArray [1] into itemArray
   --
   put urldecode (itemArray ["name"]) into audioName
   put urldecode (itemArray ["filename"]) into shortFile
   put itemArray ["url"] into audioURL
   --
   return audioURL
end trello_GetFirstAudioURL

function trello_GetAudioArray cardData
   put cardData ["attachments"] into attachmentArray
   put item 2 of the extents of attachmentArray into maxNum
   --
   set the itemdelimiter to slash
   put 1 into audioNum
   repeat with itemNum = 1 to maxNum
      put attachmentArray [itemNum] into itemArray
      put itemArray ["mimetype"] into mimetype
      if item 1 of mimetype = "audio" then
         put itemArray into audioArray [audioNum] -- renumber
         add 1 to audioNum
      end if
   end repeat
   return audioArray
end trello_GetAudioArray


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

