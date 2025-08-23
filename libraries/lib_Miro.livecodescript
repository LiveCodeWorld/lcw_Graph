script "lib_Miro"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_Miro
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Miro
-
on miro_Test
   /*
   curl --request POST \
   --url https://api.miro.com/v1/boards \
   --header 'authorization: Bearer 8f98b4c4-cca4-4fce-998b-dcad6fd6be37' \
   --header 'content-type: application/json' \
   --data '{"name":"Glitch Game","sharingPolicy":{"access":"comment","teamAccess":"edit"},"description":"A space to add metadata to glitches."}'
   */
   
   put miro_ConstructCreateBoardArray ("Test", "Some description...") into postArray
   put "https://api.miro.com/v1/boards" into restURL
   --
   miro_PostArray postArray, restURL
   put the result into rArray
   --
   display_Array rArray
end miro_Test


--> Miro
-
function miro_ListAllWidgets boardID
   -- boards/o9J_kr_Vbdg%3D/widgets/
   
   put "boards/" & boardID into restBit
   put "/widgets" after restBit
   --
   put miro_GetJsonRpcArray (restBit) into rArray
   return rArray
end miro_ListAllWidgets

function miro_GetCurrentUserBoards teamID
   -- teams/3074457348244556302/boards?limit=10&offset=0'
   
   put "teams/" & teamID into restBit
   put "/boards" after restBit
   -- put "?limit=10&offset=0" after restBit
   --
   put miro_GetJsonRpcArray (restBit) into rArray
   return rArray
end miro_GetCurrentUserBoards

function miro_GetTeam teamID
   -- teams/3074457348244556302
   
   put "teams/" & teamID into restBit
   put miro_GetJsonRpcArray (restBit) into rArray
   return rArray
end miro_GetTeam

on mDoubleUp_MiroAuthorization displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
end mDoubleUp_MiroAuthorization

command display_MiroAuthorization pDisplayView
   put miro_GetAuthorization() into rArray
   display_Data rArray, "Authorization", "Miro", pDisplayView
   put the result into displayView
   --
   display_SetMouseAndMenu displayView, "Miro | Authorization", "lib_Miro"
   return displayView
end display_MiroAuthorization

command display_MiroCurrentUser
   put miro_GetCurrentUser() into rArray
   display_Data rArray, "Current User", "Miro"
end display_MiroCurrentUser

function miro_GetAuthorization
   -- GET oauth-token
   put miro_GetJsonRpcArray ("oauth-token") into rArray
   return rArray
end miro_GetAuthorization

function miro_GetCurrentUser
   -- GET users/me
   put miro_GetJsonRpcArray ("users/me") into rArray
   return rArray
end miro_GetCurrentUser

function miro_ConstructCreateBoardJson boardName, boardDescription, pAccessPolicy, pTeamAccessPolicy
   put miro_ConstructCreateBoardArray (boardName, boardDescription, pAccessPolicy, pTeamAccessPolicy) into postArray
   --
   put json_FromArray (postArray) into postJSON
   return postJSON
end miro_ConstructCreateBoardJson

function miro_ConstructCreateBoardArray boardName, boardDescription, pAccessPolicy, pTeamAccessPolicy
   if pAccessPolicy is empty then
      put "comment" into pAccessPolicy
   end if
   if pTeamAccessPolicy is empty then
      put "edit" into pTeamAccessPolicy
   end if
   --
   put boardName into postArray ["name"]
   put boardDescription into postArray ["description"]
   --
   put pAccessPolicy into postArray ["sharingPolicy"]["access"]
   put pTeamAccessPolicy into postArray ["sharingPolicy"]["teamAccess"]
   --
   return postArray
end miro_ConstructCreateBoardArray


--> Deps
-
command miro_PostArray postArray, restURL
   put miro_GetAccessToken() into oAuthToken
   put json_FromArray (postArray) into someJSON
   --
   rest_SetJsonHeaders oAuthToken
   post someJSON to url restUrl
   put it into jsonResult
   --
   put json_ToArray (jsonResult) into rArray
   return rArray
end miro_PostArray

private function _RestUrl apiBit, pVersion
   if pVersion is empty then put "v1" into pVersion
   --
   put "https://api.miro.com/" into restUrl
   put pVersion & slash after restUrl
   --
   put apiBit after restURL
   return restURL
end _RestUrl

function miro_GetJsonRpcArray apiBit, pVersion
   put _RestUrl (apiBit, pVersion) into restURL
   --
   put miro_GetAccessToken() into oAuthToken
   put jsonrpc_GET (restURL, oAuthToken) into jsonResult
   --
   put json_ToArray (jsonResult) into rArray
   return rArray
end miro_GetJsonRpcArray


--> Display | V2
-
on mDoubleUp_MiroBoards displayView, boardName
   put the selected_LineNum of displayView into indexNum
   put the view_Data of displayView into boardData
   
   ## ID from line number
   put boardData [indexNum]["id"] into boardID
   put boardData [indexNum]["viewLink"] into viewLink
   
   ## ID from name is not reliable
   -- put indexArray_GetNamed (boardData, boardName, "id") into boardID
   -- put indexArray_GetNamed (boardData, boardName, "viewLink") into viewLink
   --
   display_MiroBoardItems boardID
   -- display_MiroBoard boardID
   -- launch url viewLink
end mDoubleUp_MiroBoards

command display_MiroBoards pDisplayView
   put miro_ListBoards() into rArray
   
   ## Check for errors
   if rArray ["type"] is not "list" then
      -- "type": "error"
      breakpoint
      return empty
   end if
   
   if rArray ["total"] > rArray ["limit"] then
      -- needs pagination
      put rArray ["self"] into paginationURL
      breakpoint
   end if
   
   put rArray ["data"] into boardData
   
   ## Display
   -- display_Data rArray, "Boards", "Miro", pDisplayView
   display_IndexArray boardData, "Boards", "Miro", false, "name", pDisplayView
   put the result into displayView
   --
   display_SetMouseAndMenu displayView, "Miro | Boards", "lib_Miro"
   return displayView
end display_MiroBoards

command display_MiroBoardItems boardID, pDisplayView
   put miro_GetBoardItems (boardID) into rArray
   
   ## Check for errors
   if rArray ["type"] is "error" then
      -- "type": "cursor-list"
      breakpoint
      return empty
   end if
   
   ## Display Board Data
   display_Data rArray, "Board Items", "Miro", pDisplayView
   put the result into displayView
   --
   -- display_SetMouseAndMenu displayView, menuBit, "lib_Miro"
end display_MiroBoardItems

command display_MiroBoard boardID, pDisplayView
   put miro_GetBoard (boardID) into rArray
   
   ## Check for errors
   if rArray ["type"] is not "board" then
      -- "type": "error"
      breakpoint
      return empty
   end if
   
   ## Display Board Data
   display_Data rArray, "Board", "Miro", pDisplayView
   put the result into displayView
   --
   -- display_SetMouseAndMenu displayView, menuBit, "lib_Miro"
end display_MiroBoard


--> Miro | V2
-
function miro_GetBoardItems boardID, pType, pLimit
   -- https://api.miro.com/v2/boards/o9J_lFTBaXY/items?limit=50&type=sticky_note
   if pLimit is empty then put 50 into pLimit -- ma, min = 10
   --
   put "boards/" & boardID into apiBit
   put "/items" after apiBit
   put "?" after apiBit
   put "limit=" & pLimit after apiBit
   --
   if pType is not empty then
      put "&type=" & pType after apiBit
   end if
   --
   put miro_GetJsonRpcArray (apiBit, "v2") into rArray
   return rArray
end miro_GetBoardItems

function miro_GetBoard boardID
   -- https://api.miro.com/v2/boards/board_id
   put "boards/" & boardID into apiBit
   put miro_GetJsonRpcArray (apiBit, "v2") into rArray
   return rArray
end miro_GetBoard

function miro_ListBoards
   --url https://api.miro.com/v2/boards \
   put miro_GetJsonRpcArray ("boards", "v2") into rArray
   return rArray
end miro_ListBoards


--> Miro | Tokens
-
function miro_GetAccessToken   
   return "f6b20c04-390a-42d6-8bd2-62429946c2db" -- for Media Garden
   -- return "8f98b4c4-cca4-4fce-998b-dcad6fd6be37" -- for Dev Team
end miro_GetAccessToken

function miro_GetAuthToken
   if the environment = "server" then
      put gConfig["miroAuthToken"] into dropBoxAuthToken
   else
      put pref_FetchValue ("miroAuthToken", "rest") into miroAuthToken
   end if
   return miroAuthToken
end miro_GetAuthToken

command miro_SetAuthToken miroAuthToken
   if the environment = "server" then
      rigSetConfigItem "miroAuthToken", miroAuthToken
   else
      pref_SaveValue "miroAuthToken", miroAuthToken, "rest"
   end if
end miro_SetAuthToken

function miro_GetClientID
   if the environment = "server" then
      put gConfig["miroClientID"] into miroClientID
   else
      put pref_FetchValue ("miroClientID", "rest") into miroClientID
   end if
   return miroClientID
end miro_GetClientID

command miro_SetClientID miroClientID
   if the environment = "server" then
      -- need to figure out how best to store configs (maybe a json file)
      rigSetConfigItem "miroClientID", miroClientID
   else
      -- secret_Set "miroClientID", miroClientID
      pref_SaveValue "miroClientID", miroClientID, "rest"
   end if
end miro_SetClientID

function miro_GetClientSecret
   if the environment = "server" then
      put gConfig["miroClientSecret"] into dropBoxAuthToken
   else
      put secret_Get ("miroClientSecret", "rest") into miroClientSecret
      put pref_FetchValue ("miroClientSecret", "rest") into miroClientSecret
   end if
   return miroClientSecret
end miro_GetClientSecret

command miro_SetClientSecret miroClientSecret
   if the environment = "server" then
      -- this is only temporary
      -- need to figure out how best to store configs (maybe a json file)
      -- rigSetConfigItem "miroClientSecret", miroClientSecret
   else
      pref_SaveValue "miroClientSecret", miroClientSecret, "rest"
   end if
end miro_SetClientSecret


--> Deps
-
-- function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get
