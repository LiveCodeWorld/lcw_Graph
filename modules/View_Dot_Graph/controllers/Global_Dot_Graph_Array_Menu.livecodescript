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
on menu_DotTextEditor
   display_Text empty, "Dot Text", "Global | Dot | Text | Editor | Menu"
end menu_DotTextEditor

on menu_NodeShape gridView, defaultShape
   put "World" into linkArray ["Hello"]
   put "World" into linkArray ["Another"]
   put "Green" into linkArray ["World"]
   --
   put "Test Graph" into gTitle
   dotArray_Construct linkArray, dotArray, "fdp", gTitle, defaultShape
   put the result into dotText
   --
   display_GraphFromDotArray dotArray, dotText
   --
   display_DotArray dotArray
   display_DotText dotText, gTitle
end menu_NodeShape

on menu_TestCoda graphView
   display_MotiGraph
end menu_TestCoda

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
