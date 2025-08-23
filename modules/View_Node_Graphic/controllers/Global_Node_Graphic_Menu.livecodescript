script "Global | Node | Graphic | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Node | Graphic | Menu
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
   put the graph_Node of tObject into gView
   return gView
end menu_Target

getprop shape_Param [gView]
   put the style of gView into someShape
   if someShape is "regular" then
      put the polysides of gView - 2 into itemNum
      return item itemNum of "triangle,diamond,pentagon,hexagon"
   else
      return someShape
   end if
end shape_Param

getprop shape_Params [gView]
   return "rectangle,roundrect,oval,-,triangle,diamond,pentagon,hexagon,-,line,curve,polygon"
end shape_Params

getprop dotShape_Params
   return dot_AllShapes()
end dotShape_Params


--> Global | Node | Graphic | Menu
-
on menu_ObjectInspector sNode
   display_ObjectProperties sNode
end menu_ObjectInspector

on menu_Shape gView, someShape
   lock screen
   switch someShape
      case "triangle"
         set the style of gView to regular
         set the polysides of gView to 3
         set the angle of gView to 270
         break
      case "diamond"
         set the style of gView to regular
         set the polysides of gView to 4
         set the angle of gView to 0
         break
      case "pentagon"
         set the style of gView to regular
         set the polysides of gView to 5
         set the angle of gView to 53
         break
      case "hexagon"
         set the style of gView to regular
         set the polysides of gView to 6
         set the angle of gView to 0
         break
      default
         set the style of gView to someShape
   end switch
   unlock screen
end menu_Shape

private on _
end _

on menu_DeleteNode gView
   put the to_Arrows of gView into toArrows
   repeat for each line aView in toArrows
      if exists (aView) is false then next repeat
      put the to_Object of aView into toObject
      if exists (toObject) is false then next repeat
      set the remove_FromArrow of toObject to aView
      object_Delete aView
   end repeat
   
   put the from_Arrows of gView into fromArrows
   repeat for each line aView in fromArrows
      if exists (aView) is false then next repeat
      put the from_Object of aView into fromObject
      if exists (fromObject) is false then next repeat
      set the remove_ToArrow of fromObject to aView
      object_Delete aView
   end repeat
   
   object_Delete gView
end menu_DeleteNode

on menu_NodeBehavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_NodeBehavior

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Node | Graphic | Menu")
end submenu_Dev

