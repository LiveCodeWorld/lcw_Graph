script "Global | Trello | Boards | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Boards | Line | Menu
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


--> Global | Trello | Boards | Line | Menu
-
on menu_DisplayBoard displayView
   put the selected_Line of displayView into boardName
   dispatch "mDoubleUp_TrelloBoards" to displayView with displayView, boardName
end menu_DisplayBoard
