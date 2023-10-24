script "Global | Trello | Board | List | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Board | List | Line | Menu
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


--> Global | Trello | Board | List | Line | Menu
-
on menu_DisplayList displayView
   put the selected_Line of displayView into listName
   --
   dispatch "mDoubleUp_TrelloList" to displayView with displayView,listName
end menu_DisplayList
