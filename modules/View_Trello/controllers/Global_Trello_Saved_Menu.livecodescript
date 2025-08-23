script "Global | Trello | Saved | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Saved | Menu
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

getprop disabled_RememberList [leftView]
   return false
end disabled_RememberList


--> Global | Trello | Saved | Menu
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

on menu_DisplayOrganisations displayView
   display_TrelloOrganisations displayView
end menu_DisplayOrganisations

on _
end _

on menu_RememberList leftView
   put the title_Text of leftView into listName
   put the view_Data of leftView into cardData
   --
   set the saved_CardData [listName] of leftView to cardData
end menu_RememberList


