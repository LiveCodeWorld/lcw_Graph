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
on submenu_TrelloList
   return "Global | Trello | List | Menu"
end submenu_TrelloList

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

on subMenu_Dev
   return menu_DevTitle()
end subMenu_Dev
