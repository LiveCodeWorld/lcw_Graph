script "Global | Dot | Edge | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Dot | Edge | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   return the arrow_View of tObject
end menu_Target


--> Global | Dot | Edge | Menu
-
on menu_EdgeArray edgeGraphic
   put the edge_Array of edgeGraphic into edgeArray
   display_Data edgeArray
end menu_EdgeArray

on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | Dot | Edge | Menu")
end submenu_Dev
