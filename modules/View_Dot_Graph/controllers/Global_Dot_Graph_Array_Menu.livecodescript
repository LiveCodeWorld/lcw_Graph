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
getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

getprop nodeShape_Param [nodeObject]
   put the node_Shape of nodeObject into nShape
   if nShape is empty then
      put "ellipse" into nShape
   end if
   return nShape
end nodeShape_Param

getprop nodeShape_Params
   return dot_NodeShapes()
end nodeShape_Params


--> Global | Dot | Graph | Array | Menu
-
on submenu_DotArray
   return "Global | DotArray | Menu"
end submenu_DotArray

on submenu_Save
   return menu_CreateTitle ("Global | Dot | Save | Menu")
end submenu_Save

private command _
end _

on menu_DotTextEditor displayView
   put the dot_File of displayView into dotFile
   if there is a file dotFile then
      display_DotText dotFile
   else
      -- put url ("binfile:" & textFile) into utf8Text
      -- put textDecode (utf8Text, "UTF-8") into someText
      put the displayed_Data of displayView into dotArray
      put dot_FromArray (dotArray) into dotText
      --
      display_DotText dotText
   end if
end menu_DotTextEditor

private command __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Dot | Graph | Array | Menu")
end submenu_Dev
