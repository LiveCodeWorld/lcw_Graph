script "Global | Dot | Graph | Array | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Dot | Graph | Array | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
-- getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target


--> Global | Dot | Graph | Array | Menu
-
on menu_DotArrayJson displayView
   put the displayed_Data of displayView into dotArray
   put json_FromArray (dotArray, false, true) into dotText
   --
   display_Text dotText, "Dot Array JSON"
end menu_DotArrayJson

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment
