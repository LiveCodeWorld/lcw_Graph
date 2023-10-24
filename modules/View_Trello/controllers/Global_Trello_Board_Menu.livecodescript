script "Global | Trello | Board | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Board | Menu
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


--> Global | Trello | Board | Menu
-
on menu_PresentSlideShow displayView
   display_TrelloPresentation displayView
end menu_PresentSlideShow

private on _
end _

on menu_EditCardScript displayView
   put the card_Object of displayView into cardObject
   edit the script of cardObject
end menu_EditCardScript

on menu_ViewBehavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_ViewBehavior
