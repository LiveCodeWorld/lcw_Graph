script "Global | Dot | Graph | Style | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Dot | Graph | Style | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop checked_BrowserVisible [graphView]
   put the browser_Visible of graphView into oBoolean
   return oBoolean
end checked_BrowserVisible

getprop checked_AutoScale [graphView]
   put the auto_Scale of graphView into oBoolean
   return oBoolean
end checked_AutoScale

getprop checked_ShowNodes [graphView]
   put the show_Nodes of graphView into oBoolean
   return oBoolean
end checked_ShowNodes

getprop checked_ShowNames [graphView]
   put the show_Names of graphView into oBoolean
   return oBoolean
end checked_ShowNames

getprop checked_ShowNodeLabels [graphView]
   put the show_NodeLabels of graphView into oBoolean
   return oBoolean
end checked_ShowNodeLabels

getprop checked_ShowEdges [graphView]
   put the show_Edges of graphView into oBoolean
   return oBoolean
end checked_ShowEdges

getprop checked_TransparentBackground [graphView]
   put the opaque of graphView into oBoolean
   return oBoolean is false
end checked_TransparentBackground

getprop checked_TopDown [graphView]
   put the top_Down of graphView into oBoolean
   return oBoolean
end checked_TopDown

getprop edgeWidth_Param [graphView]
   put the edge_Width of graphView into edgeWidth
   return edgeWidth
end edgeWidth_Param

getprop edgeWidth_Params
   return "0,-,1,2,3,4"
end edgeWidth_Params

getprop scaleGroup_Params
   return "0.5,0.75,1,1.5,2"
end scaleGroup_Params


--> Global | Dot | Graph | Style | Menu
-
on menu_TransparentBackground graphView
   put the opaque of graphView into sBoolean
   set the opaque of graphView to (sBoolean is false)
end menu_TransparentBackground

on menu_AutoScale graphView
   put the auto_Scale of graphView into sBoolean
   set the auto_Scale of graphView to (sBoolean is false)
end menu_AutoScale

on menu_TopDown graphView
   put the top_Down of graphView into oBoolean
   set the top_Down of graphView to (oBoolean is false)
end menu_TopDown

on menu_ShowNodes graphView
   put the show_Nodes of graphView into oBoolean
   set the show_Nodes of graphView to (oBoolean is false)
end menu_ShowNodes

on menu_ShowNames graphView
   put the show_Names of graphView into oBoolean
   set the show_Names of graphView to (oBoolean is false)
end menu_ShowNames 

on menu_ShowNodeLabels graphView
   put the show_NodeLabels of graphView into oBoolean
   set the show_NodeLabels of graphView to (oBoolean is false)
end menu_ShowNodeLabels

on menu_BrowserVisible graphView, sBoolean
   put the browser_Visible of graphView into oBoolean
   set the browser_Visible of graphView to (oBoolean is false)
end menu_BrowserVisible

on menu_ShowEdges graphView
   put the show_Edges of graphView into oBoolean
   set the show_Edges of graphView to (oBoolean is false)
end menu_ShowEdges

on menu_EdgeWidth graphView, edgeWidth
   set the edge_Width of graphView to edgeWidth
end menu_EdgeWidth

on menu_ScaleGroup graphView, someScale
   set the graph_Scale of graphView to someScale
end menu_ScaleGroup

