script "Global | Trello | Boards | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Boards | Menu
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


--> Global | Trello | Boards | Menu
-
on menu_DisplayRocketBook leftView
   display_TrelloRocketBook leftView
end menu_DisplayRocketBook

private on _
end _

on menu_DisplayOrganisations leftView
   display_TrelloOrganisations leftView
end menu_DisplayOrganisations

