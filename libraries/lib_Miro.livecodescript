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
   put the result into resultArray
   --
   display_Array resultArray
end miro_Test


--> Miro
-
function miro_ListAllWidgets boardID
   -- boards/o9J_kr_Vbdg%3D/widgets/
   
   put "boards/" & boardID into restBit
   put "/widgets" after restBit
   --
   put miro_GetJsonRpcArray (restBit) into resultArray
   return resultArray
end miro_ListAllWidgets

function miro_GetCurrentUserBoards teamID
   -- teams/3074457348244556302/boards?limit=10&offset=0'
   
   put "teams/" & teamID into restBit
   put "/boards?limit=10&offset=0" after restBit
   --
   put miro_GetJsonRpcArray (restBit) into resultArray
   return resultArray
end miro_GetCurrentUserBoards

function miro_GetTeam teamID
   -- teams/3074457348244556302
   
   put "teams/" & teamID into restBit
   put miro_GetJsonRpcArray (restBit) into resultArray
   return resultArray
end miro_GetTeam

function miro_GetAuthorization
   -- GET oauth-token
   put miro_GetJsonRpcArray ("oauth-token") into resultArray
   return resultArray
end miro_GetAuthorization

function miro_GetCurrentUser
   -- GET users/me
   put miro_GetJsonRpcArray ("users/me") into resultArray
   return resultArray
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
   put json_ToArray (jsonResult) into resultArray
   return resultArray
end miro_PostArray

function miro_ConstructRestUrl restBit
   put "https://api.miro.com/v1/" into apiStem
   --
   put apiStem & restBit into restURL
   return restURL
end miro_ConstructRestUrl

function miro_GetJsonRpcArray restBit
   put miro_ConstructRestUrl (restBit) into restURL
   --
   put miro_GetAccessToken() into oAuthToken
   put jsonrpc_GET (restURL, oAuthToken) into jsonResult
   --
   put json_ToArray (jsonResult) into resultArray
   return resultArray
end miro_GetJsonRpcArray

function miro_GetAccessToken
   return "f6b20c04-390a-42d6-8bd2-62429946c2db" -- for Media Garden
   -- return "8f98b4c4-cca4-4fce-998b-dcad6fd6be37" -- for Dev Team
end miro_GetAccessToken
