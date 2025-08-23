script "Global | Dot | Graph | Geometry | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dot | Graph | Geometry | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tOject]
   return the graph_View of tOject
end menu_Target

getprop checked_TopDown [graphView]
   put the top_Down of graphView into oBoolean
   return oBoolean
end checked_TopDown

getprop edgeWidth_Params
   return "0,-,1,2,3,4"
end edgeWidth_Params

getprop ScaleGraph_Param [graphView]
   put the graph_Scale of graphView into gScale
   put min (gScale) into pScale
   put round (pScale, 1) into mScale
   return mScale
end ScaleGraph_Param

getprop ScaleGraph_Params
   return "0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,-,1.5,2.0"
end ScaleGraph_Params

getprop templateMargin_Param [graphView]
   return the template_Margin of graphView
end templateMargin_Param

getprop templateMargin_Params [graphView]
   put "0,-,4,8,10,30" into sMenu
   get the template_Margin of graphView
   if it is not among the items of sMenu then
      put ",-," & it after sMenu
   end if
   return sMenu
end templateMargin_Params


--> Global | Dot | Graph | Geometry | Menu
-
on menu_ScaleGraph graphView, someScale
   put the graph_Scale of graphView
   set the graph_Scale of graphView to someScale
end menu_ScaleGraph

on menu_AutoScale graphView
   put the auto_Scale of graphView into sBoolean
   set the auto_Scale of graphView to (sBoolean is false)
end menu_AutoScale

private on _
end _

on menu_TemplateMargin graphView, tMargin
   set the template_Margin of graphView to tMargin
end menu_TemplateMargin

on menu_TopDown graphView
   put the top_Down of graphView into oBoolean
   set the top_Down of graphView to (oBoolean is false)
end menu_TopDown


