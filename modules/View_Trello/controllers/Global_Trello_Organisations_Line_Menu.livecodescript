script "Global | Trello | Organisations | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Trello | Organisations | Line | Menu
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


--> Global | Trello | Organisations | Line | Menu
-
on menu_DisplayOrgBoards displayView
   put the selected_Line of displayView into orgName
   --
   dispatch "mDoubleUp_TrelloOrganisation" to displayView with displayView,orgName
   
   /*
   put the view_Data of displayView into vData
   put indexArray_Find (vData, "DisplayName", orgName) into indexNum
   put vData [indexNum]["id"] into orgID
   -- put vData [indexNum]["displayName"] into orgName
   --
   display_TrelloOrgBoards orgID, orgName
   */
end menu_DisplayOrgBoards

private on _
end _

on menu_DisplayedObject displayView
   put the displayed_Object of displayView
end menu_DisplayedObject
