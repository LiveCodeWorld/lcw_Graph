script "Global | Trello | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Trello | Dev | Menu
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


--> Global | Trello | Dev | Menu
-
on menu_TrelloOrganisations displayView
   put trello_ListOrgs() into restData
   --
   set the index_Array ["displayName"] of displayView to restData
   set the mouse_DoubleUp of displayView to "mDoubleUp_TrelloOrganisation"
end menu_TrelloOrganisations

on menu_TrelloOrgBoards displayView
   put trello_ListOrgBoards (orgID) into restData
   put trello_ListOrgs() into restData
   --
   set the index_Array of displayView to restData
   set the display_Interactions of displayView to "Trello | Boards"
   --
   return displayView
end menu_TrelloOrgBoards

on menu_TrelloPalette
   display_TrelloOrganisations
end menu_TrelloPalette

on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Trello | Dev | Menu"
end menu_MenuEdit
