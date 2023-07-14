script "Global | Trello | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Trello | Menu
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

private on _
end _

on menu_ReplaceLeftView displayView
   put the left_View of displayView into leftView
   display_ReplaceWithModule leftView
end menu_ReplaceLeftView

on menu_ReplaceRightView displayView
   put the right_View of displayView into rightView
   display_ReplaceWithModule rightView
end menu_ReplaceRightView

private on __
end __

on menu_TrelloPalette
   display_TrelloOrganisations
end menu_TrelloPalette
