script "Global | Trello | Board | List | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Board | List | Menu
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

getprop displayBoard_Param [leftView]
   -- not always a list
   put the title_Text of leftView into titleText
   return titleText
end displayBoard_Param

getprop displayBoard_Params [leftView]
   put the saved_BoardNames of leftView into listNames
   return listNames
end displayBoard_Params

getprop disabled_DisplayBoard [leftView]
   put the saved_BoardNames of leftView into listNames
   return listNames is empty
end disabled_DisplayBoard

getprop displayList_Param [leftView]
   put the title_Text of leftView into listName
   return listName
end displayList_Param

getprop displayList_Params [leftView]
   put the saved_ListNames of leftView into listNames
   return listNames
end displayList_Params

getprop disabled_DisplayList [leftView]
   put the saved_ListNames of leftView into listNames
   return listNames is empty
end disabled_DisplayList


--> Global | Trello | Board | List | Menu
-
on menu_DisplayList leftView, listName
   put the saved_CardData [listName] of leftView into cardData
   --
   display_TrelloCardData cardData, listName, leftView
   put the result into displayView
end menu_DisplayList

on menu_DisplayBoard leftView, boardName
   put the saved_ListData [boardName] of leftView into listData
   --
   display_TrelloListData listData, boardName, leftView
   put the result into displayView
end menu_DisplayBoard

on menu_RemeberBoard leftView
   put the title_Text of leftView into boardName
   put the view_Data of leftView into listData
   --
   set the saved_ListData [boardName] of leftView to listData
end menu_RemeberBoard

private on _
end _

on menu_DisplayToDo leftView
   put "To Do" into listName
   --
   dispatch "mDoubleUp_TrelloList" to leftView with leftView,listName
end menu_DisplayToDo

private on __
end __

on menu_DisplayOrganisations leftView
   display_TrelloOrganisations leftView
end menu_DisplayOrganisations

