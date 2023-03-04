script "Global | Dot | Edge | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Dot | Edge | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-


--> Global | Dot | Edge | Menu
-
on menu_TestEdge displayView
   put the name of displayView
end menu_TestEdge

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


--> Deps
-
