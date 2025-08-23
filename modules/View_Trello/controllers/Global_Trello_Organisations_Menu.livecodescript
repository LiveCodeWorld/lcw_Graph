script "Global | Trello | Organisations | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Organisations | Menu
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


--> Global | Trello | Organisations | Menu
-
on subMenu_Saved
   return "Global | Trello | Saved | Menu"
end subMenu_Saved

on menu_DisplayMyOrgs leftView
   put "David Bovill's workspace" into orgName
   --
   dispatch "mDoubleUp_TrelloOrganisation" to leftView with leftView,orgName
end menu_DisplayMyOrgs

private on _
end _

on menu_DisplayRocketBook leftView
   -- display_TrelloRocketBook pDisplayView
   
   put "Rocketbook" into boardName
   dispatch "mDoubleUp_TrelloBoards" to leftView with leftView,boardName
end menu_DisplayRocketBook

on menu_DisplayOrganisations leftView
   display_TrelloOrganisations leftView
end menu_DisplayOrganisations
