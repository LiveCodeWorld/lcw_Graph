script "Global | Dot | Graph | Test | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Dot | Graph | Test | Menu
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
   return the node_Object of tObject
end menu_Target


--> Global | Dot | Graph | Test | Menu
-
on menu_DisplayNodeData nodeObject
   put the name of nodeObject
end menu_DisplayNodeData

on menu_NodeProperties nodeObject
   display_ObjectProperties nodeObject
end menu_NodeProperties

on menu_ReplaceWithPlaceholder nodeObject
   put the short name of nodeObject into oName
   set the control_Type [oName] of nodeObject to "placeHolder"
   put the result into newView
end menu_ReplaceWithPlaceholder

